import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_penyewa.dart'; // ✅ Import file chat_penyewa.dart

class RiwayatChatPenyewa extends StatefulWidget {
  const RiwayatChatPenyewa({super.key});

  @override
  State<RiwayatChatPenyewa> createState() => _RiwayatChatPenyewaState();
}

class _RiwayatChatPenyewaState extends State<RiwayatChatPenyewa> {
  final Color primaryBlue = const Color(0xFF2F5586);
  bool _isIndexBuilding = false;
  bool _useManualSort = false;

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

                    return _buildChatList(user);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: _useManualSort
          ? FirebaseFirestore.instance
                .collection('chatRooms')
                .where('participants', arrayContains: user.uid)
                .snapshots()
          : FirebaseFirestore.instance
                .collection('chatRooms')
                .where('participants', arrayContains: user.uid)
                .orderBy('lastMessageTime', descending: true)
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryBlue));
        }

        if (snapshot.hasError) {
          final error = snapshot.error.toString();

          // Cek jika error adalah "requires an index"
          if (error.contains('requires an index') ||
              error.contains('failed-precondition')) {
            return _buildIndexErrorState();
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    error.length > 100
                        ? '${error.substring(0, 100)}...'
                        : error,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyChatState();
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        // Jika menggunakan manual sort, urutkan berdasarkan waktu
        if (_useManualSort) {
          docs.sort((a, b) {
            final aTime =
                (a.data() as Map<String, dynamic>)['lastMessageTime']
                    as Timestamp?;
            final bTime =
                (b.data() as Map<String, dynamic>)['lastMessageTime']
                    as Timestamp?;

            final aMillis = aTime?.millisecondsSinceEpoch ?? 0;
            final bMillis = bTime?.millisecondsSinceEpoch ?? 0;

            return bMillis.compareTo(aMillis); // Descending
          });
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildChatTile(data, doc.id, user);
          },
        );
      },
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

    // Cari user lain (pemilik kendaraan)
    String? otherUserId;
    String? otherUserName;

    for (var participant in participants) {
      if (participant != user.uid) {
        otherUserId = participant;
        otherUserName = participantNames[participant] ?? 'Pemilik';
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
                  otherUserName ?? 'Pemilik',
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatRoomId: chatRoomId,
                    otherUserId: otherUserId!,
                    otherUserName: otherUserName!,
                    vehicleId: data['vehicleId'] ?? '',
                    vehicleName: vehicleName,
                  ),
                ),
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
              "Mulai percakapan dengan pemilik kendaraan untuk bertanya atau konfirmasi booking",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
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

  Widget _buildIndexErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              "Index Database Dibutuhkan",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Firebase memerlukan index untuk query ini. Index sedang dibangun (mungkin 1-5 menit).",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_isIndexBuilding)
              Column(
                children: [
                  CircularProgressIndicator(color: primaryBlue),
                  const SizedBox(height: 16),
                  Text(
                    "Index sedang dibangun...",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ElevatedButton(
              onPressed: () {
                // Buka link untuk membuat index
                _openIndexLink();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Buat Index di Firebase Console",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _useManualSort = true;
                });
              },
              child: Text(
                "Gunakan mode sementara (tanpa sort)",
                style: TextStyle(color: primaryBlue),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _useManualSort = false;
                  _isIndexBuilding = true;
                });

                // Coba lagi setelah 10 detik
                Future.delayed(const Duration(seconds: 10), () {
                  setState(() {
                    _isIndexBuilding = false;
                  });
                });
              },
              child: Text("Coba Kembali", style: TextStyle(color: primaryBlue)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Petunjuk:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "1. Klik tombol 'Buat Index' di atas\n"
                    "2. Login ke Firebase Console\n"
                    "3. Klik 'Create Index'\n"
                    "4. Tunggu 1-5 menit\n"
                    "5. Klik 'Coba Kembali'",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openIndexLink() {
    const indexUrl =
        "https://console.firebase.google.com/v1/r/project/gorent-62a6a/firestore/indexes?create_composite=Ck5wcm9qZWNocy9nb3JlbnQ2MmE2YS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvY2hhdFJvb21zL2luZGV4ZXMvLS9wYXJ0aWNpcGFudHMvQVJSQVlfQ09OVEFJTlMvbGFzdE1lc3NhZ2VUaW1lL0RFU0NFTkRJTkc";

    // Anda bisa menggunakan url_launcher package untuk membuka link
    // Atau tampilkan link untuk copy
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Link Firebase Console"),
        content: SelectableText(indexUrl, style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
