import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_renter.dart';

class RiwayatChatRenter extends StatefulWidget {
  const RiwayatChatRenter({super.key});

  @override
  State<RiwayatChatRenter> createState() => _RiwayatChatRenterState();
}

class _RiwayatChatRenterState extends State<RiwayatChatRenter> {
  final Color primaryBlue = const Color(0xFF2F5586);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Riwayat Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // Search chat
                    },
                  ),
                ],
              ),
            ),

            // LIST CHAT
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, authSnapshot) {
                    if (authSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      );
                    }

                    final user = authSnapshot.data;

                    if (user == null) {
                      return _buildLoginRequiredState();
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chatRooms')
                          .where('participants', arrayContains: user.uid)
                          .orderBy('lastMessageTime', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: primaryBlue,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyChatState();
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 20),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            return _buildChatTile(data, doc.id, user);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(
    Map<String, dynamic> data,
    String chatRoomId,
    User user,
  ) {
    final participants = List<String>.from(data['participants'] ?? []);
    final participantNames = Map<String, String>.from(
      data['participantNames'] ?? {},
    );
    final lastMessage = data['lastMessage'] ?? '';
    final lastMessageTime = data['lastMessageTime'] as Timestamp?;
    final vehicleName = data['vehicleName'] ?? '';
    final unreadCount = Map<String, int>.from(data['unreadCount'] ?? {});

    // Cari user lain (penyewa)
    String? otherUserId;
    String? otherUserName;

    for (var participant in participants) {
      if (participant != user.uid) {
        otherUserId = participant;
        otherUserName = participantNames[participant] ?? 'Penyewa';
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
    final userUnread = unreadCount[user.uid] ?? 0;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: primaryBlue,
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  otherUserName ?? 'Penyewa',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
              const SizedBox(height: 4),
              if (vehicleName.isNotEmpty)
                Text(
                  vehicleName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lastMessage.isNotEmpty ? lastMessage : 'Belum ada pesan',
                      style: TextStyle(
                        color: Colors.grey[600],
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
            if (otherUserId != null && otherUserName != null) {
              Navigator.pushNamed(
                context,
                '/renter/chat',
                arguments: {
                  'chatRoomId': chatRoomId,
                  'otherUserId': otherUserId!,
                  'otherUserName': otherUserName!,
                  'vehicleId': data['vehicleId'] ?? '',
                  'vehicleName': vehicleName,
                },
              );
            }
          },
        ),
        const Divider(color: Colors.grey, height: 1, indent: 20, endIndent: 20),
      ],
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Belum ada percakapan",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Penyewa akan muncul di sini saat mengirim pesan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Kembali", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequiredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Silakan Login",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Anda perlu login untuk melihat riwayat chat",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
