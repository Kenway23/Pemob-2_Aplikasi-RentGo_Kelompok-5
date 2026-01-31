import 'package:flutter/material.dart';

class RiwayatTransaksiAdmin extends StatelessWidget {
  const RiwayatTransaksiAdmin({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      // Stack digunakan untuk menambahkan motif latar belakang di pojok kanan atas
      body: Stack(
        children: [
          // Motif Bintang/Ornamen di latar belakang (seperti di gambar)
          Positioned(
            top: 40,
            right: -20,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.star_outline, size: 150, color: Colors.white.withOpacity(0.5)),
            ),
          ),
          Column(
            children: [
              // Custom AppBar sesuai gambar
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Daftar Transaksi
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildTransactionCard();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildAdminBottomNav(),
    );
  }

  Widget _buildTransactionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          _buildRowInfo('Nama Penyewa :', 'Customer 1'),
          const SizedBox(height: 8),
          _buildRowInfo('Jenis Kendaraan :', 'Mobil'),
          const SizedBox(height: 8),
          _buildRowInfo('Durasi Sewa :', '3 Hari'),
          const SizedBox(height: 8),
          _buildRowInfo('Tanggal Transaksi :', '5 Januari 2026'),
        ],
      ),
    );
  }

  // Widget pembantu untuk menyelaraskan teks kunci dan nilai seperti tabel
  Widget _buildRowInfo(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  // Bottom Nav melayang sesuai desain Admin di gambar
  Widget _buildAdminBottomNav() {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8), // Warna latar belakang nav yang sangat terang
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.home_outlined, color: Colors.grey),
          Icon(Icons.people_outline, color: Colors.grey),
          Icon(Icons.money_outlined, color: Colors.black), // Aktif: Riwayat Transaksi
          Icon(Icons.directions_car_outlined, color: Colors.grey),
          Icon(Icons.logout, color: Colors.black),
        ],
      ),
    );
  }
}