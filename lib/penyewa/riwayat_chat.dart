import 'package:flutter/material.dart';

class RiwayatChatPenyewa extends StatelessWidget {
  const RiwayatChatPenyewa({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          // Ornamen grafis bintang di pojok kanan atas sesuai gambar
          Positioned(
            top: 60,
            right: 10,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.star_outline, size: 120, color: Colors.white),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom Header: Tombol Back & Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Back',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Chats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // List of Chats
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 6, // Sesuai dengan jumlah Admin 1-6 di gambar
                    itemBuilder: (context, index) {
                      return _buildChatTile(index + 1);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(int index) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF2F5586), size: 35),
          ),
          title: Text(
            'Admin $index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            // Logika masuk ke detail chat
          },
        ),
        // Garis pemisah tipis sesuai gambar
        const Divider(
          color: Colors.white54,
          thickness: 1,
          indent: 75, // Menjorok agar sejajar dengan teks
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}