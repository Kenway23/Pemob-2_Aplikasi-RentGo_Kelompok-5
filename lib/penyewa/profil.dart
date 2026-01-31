import 'package:flutter/material.dart';

class ProfilePenyewa extends StatelessWidget {
  const ProfilePenyewa({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);
  final Color shadowColor = const Color(0xFFB0C4DE);

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
        title: const Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          const Text(
            'GoRent',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 24, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    // Avatar & Nama
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: Icon(Icons.account_circle, size: 100, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Xyz',
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF103667)
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Menu Tombol Informasi
                    _buildInfoButton('xyz@gmail.com'),
                    _buildInfoButton('No. telp'),
                    _buildInfoButton('alamat'), // Sesuai file image_044d57.png

                    const SizedBox(height: 20),

                    // Row Statistik (Total, Aktif, Selesai)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSmallStatCard('Total Sewa'),
                        _buildSmallStatCard('Sewa Aktif'),
                        _buildSmallStatCard('Sewa Selesai'),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Tombol Log Out
                    _buildInfoButton('Log Out', isLogout: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoButton(String text, {bool isLogout = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isLogout ? Colors.black87 : const Color(0xFF2F5586),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(String title) {
    return Container(
      width: 100,
      height: 75,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.bold, 
            color: Color(0xFF103667)
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.home_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.purple), 
            onPressed: () {}
          ),
        ],
      ),
    );
  }
}