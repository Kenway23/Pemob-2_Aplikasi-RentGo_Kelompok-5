import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatRenter extends StatefulWidget {
  final String? chatRoomId;
  final String? otherUserId;
  final String? otherUserName;
  final String? vehicleId;
  final String? vehicleName;

  const ChatRenter({
    super.key,
    this.chatRoomId,
    this.otherUserId,
    this.otherUserName,
    this.vehicleId,
    this.vehicleName,
  });

  @override
  State<ChatRenter> createState() => _ChatRenterState();
}

class _ChatRenterState extends State<ChatRenter> {
  final Color primaryBlue = const Color(0xFF2F5586);
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late ScrollController _scrollController;

  // Untuk menampilkan daftar chat rooms jika tidak ada chatRoomId
  bool _showChatList = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Jika ada chatRoomId, langsung masuk ke chat room
    if (widget.chatRoomId != null && widget.chatRoomId!.isNotEmpty) {
      _showChatList = false;
      _markMessagesAsRead();
    }
  }

  void _markMessagesAsRead() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || widget.chatRoomId == null) return;

    await _firestore.collection('chatRooms').doc(widget.chatRoomId).update({
      'unreadCount.${currentUser.uid}': 0,
    });
  }

  Future<void> _sendMessage() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null ||
        widget.chatRoomId == null ||
        _messageController.text.trim().isEmpty)
      return;

    final messageText = _messageController.text.trim();
    final now = Timestamp.now();

    // Tambah pesan ke subcollection messages
    await _firestore
        .collection('chatRooms')
        .doc(widget.chatRoomId!)
        .collection('messages')
        .add({
          'text': messageText,
          'senderId': currentUser.uid,
          'senderName': currentUser.displayName ?? 'Renter',
          'timestamp': now,
          'type': 'text',
          'readBy': [currentUser.uid],
        });

    // Update last message di chat room
    await _firestore.collection('chatRooms').doc(widget.chatRoomId!).update({
      'lastMessage': messageText,
      'lastMessageTime': now,
      'unreadCount.${widget.otherUserId}': FieldValue.increment(1),
    });

    _messageController.clear();

    // Scroll ke bawah
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: _showChatList
            ? const Text('Chat Customer', style: TextStyle(color: Colors.white))
            : Text(
                widget.otherUserName ?? 'Customer',
                style: const TextStyle(color: Colors.white),
              ),
        leading: !_showChatList
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _showChatList = true;
                  });
                },
              )
            : null,
      ),
      body: _showChatList ? _buildChatList() : _buildChatScreen(),
    );
  }

  // TAMPILAN DAFTAR CHAT ROOMS
  Widget _buildChatList() {
    final currentUser = _auth.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: currentUser != null
          ? _firestore
                .collection('chatRooms')
                .where('participants', arrayContains: currentUser.uid)
                .orderBy('lastMessageTime', descending: true)
                .snapshots()
          : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryBlue));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada percakapan',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer akan muncul di sini saat mengirim pesan',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildChatListItem(data, doc.id);
          },
        );
      },
    );
  }

  Widget _buildChatListItem(Map<String, dynamic> data, String chatRoomId) {
    final participants = List<String>.from(data['participants'] ?? []);
    final participantNames = Map<String, String>.from(
      data['participantNames'] ?? {},
    );
    final lastMessage = data['lastMessage'] ?? '';
    final lastMessageTime = data['lastMessageTime'] as Timestamp?;
    final vehicleName = data['vehicleName'] ?? '';
    final unreadCount = Map<String, int>.from(data['unreadCount'] ?? {});
    final currentUser = _auth.currentUser;

    // Cari customer (user lain)
    String? otherUserId;
    String? otherUserName;

    for (var participant in participants) {
      if (participant != currentUser?.uid) {
        otherUserId = participant;
        otherUserName = participantNames[participant] ?? 'Customer';
        break;
      }
    }

    // Format waktu
    String formatTime(Timestamp? timestamp) {
      if (timestamp == null) return '';
      final now = DateTime.now();
      final messageDate = timestamp.toDate();

      if (now.difference(messageDate).inDays == 0) {
        return DateFormat('HH:mm').format(messageDate);
      } else if (now.difference(messageDate).inDays == 1) {
        return 'Kemarin';
      } else if (now.difference(messageDate).inDays < 7) {
        return DateFormat('EEE').format(messageDate);
      } else {
        return DateFormat('dd/MM/yy').format(messageDate);
      }
    }

    // Hitung pesan belum dibaca
    final userUnread = currentUser != null
        ? unreadCount[currentUser.uid] ?? 0
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: primaryBlue,
          child: Icon(Icons.person, color: Colors.white, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherUserName ?? 'Customer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),
            if (lastMessageTime != null)
              Text(
                formatTime(lastMessageTime),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicleName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                vehicleName,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    lastMessage.isNotEmpty ? lastMessage : 'Belum ada pesan',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
                if (userUnread > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      userUnread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _showChatList = false;
          });
          // Update widget dengan data chat room
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                // You might want to use a different approach here
                // Since we can't modify widget properties, we'll use a different screen
                // or pass data differently
              });
            }
          });

          // Navigasi ke chat screen renter dengan parameter
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRenter(
                chatRoomId: chatRoomId,
                otherUserId: otherUserId,
                otherUserName: otherUserName,
                vehicleId: data['vehicleId'],
                vehicleName: vehicleName,
              ),
            ),
          );
        },
      ),
    );
  }

  // TAMPILAN CHAT SCREEN
  Widget _buildChatScreen() {
    if (widget.chatRoomId == null) {
      return Center(
        child: Text(
          'Tidak dapat memuat chat',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      children: [
        // INFO KENDARAAN
        Container(
          padding: const EdgeInsets.all(12),
          color: primaryBlue.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.directions_car, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicleName ?? 'Kendaraan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    Text(
                      'Chat dengan: ${widget.otherUserName ?? 'Customer'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // CHAT AREA
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('chatRooms')
                .doc(widget.chatRoomId!)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Mulai percakapan",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Balas pesan dari customer",
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(
                    _scrollController.position.maxScrollExtent,
                  );
                }
              });

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return _buildMessageBubble(data);
                },
              );
            },
          ),
        ),

        // MESSAGE INPUT
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: "Ketik balasan...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          maxLines: null,
                          onSubmitted: (value) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file, color: primaryBlue),
                        onPressed: () {
                          // Attach file/photo
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data) {
    final currentUser = _auth.currentUser;
    final isCurrentUser = data['senderId'] == currentUser?.uid;
    final messageText = data['text'] ?? '';
    final senderName = data['senderName'] ?? 'User';
    final timestamp = data['timestamp'] as Timestamp?;

    // Format waktu
    String formatTime(Timestamp? timestamp) {
      if (timestamp == null) return '';
      return DateFormat('HH:mm').format(timestamp.toDate());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryBlue,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Text(
                    senderName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? primaryBlue : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isCurrentUser
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: isCurrentUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    messageText,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatTime(timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
