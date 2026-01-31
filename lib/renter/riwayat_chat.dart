import 'package:flutter/material.dart';

class RiwayatChat extends StatelessWidget {
  const RiwayatChat({super.key});

  final Color primaryBlue = const Color(0xFF2F5586); // Warna biru dasar desain

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Back',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          // Dekorasi bintang di pojok kanan atas (opsional, sesuai gambar)
          Positioned(
            top: 0,
            right: 10,
            child: Opacity(
              opacity: 0.2,
              child: Icon(Icons.auto_awesome, size: 100, color: Colors.white),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Chats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  itemCount: 6, // Sesuai desain Customer 1 - 6
                  itemBuilder: (context, index) {
                    return _buildChatItem('Customer ${index + 1}');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(String name) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Avatar User
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF2F5586),
                ),
              ),
              const SizedBox(width: 20),
              // Nama Customer
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Garis Pemisah (Divider) sesuai desain
        const Divider(
          color: Colors.white54,
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }
}