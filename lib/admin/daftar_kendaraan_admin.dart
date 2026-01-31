import 'package:flutter/material.dart';

class DaftarKendaraanAdmin extends StatelessWidget {
  const DaftarKendaraanAdmin({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);

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
            'Daftar Kendaraan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Panel Putih Utama
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72, // Disesuaikan agar muat info & tombol
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildVehicleCard(index);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAdminBottomNav(),
    );
  }

  Widget _buildVehicleCard(int index) {
    // Simulasi perbedaan status sesuai gambar
    bool isRented = index % 2 != 0; 
    bool isBike = index == 0 || index == 3 || index == 4;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Atas (Latar Biru Muda untuk Gambar)
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFC7D9EF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Center(
              child: Icon(
                isBike ? Icons.pedal_bike : Icons.directions_car,
                size: 50,
                color: Colors.black54,
              ),
            ),
          ),
          // Bagian Bawah (Informasi)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tesla Model S', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 4),
                // Status Indikator
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: isRented ? Colors.green : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      isRented ? 'Sedang Disewa' : 'Permintaan disewa',
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Lokasi
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.red, size: 10),
                    Text(' Chicago, USA', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                // Harga & Tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBike ? '\$50/Day' : '\$100/Day',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8EBAE8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('SEE', 
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBottomNav() {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E9F2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.home_outlined, color: Colors.grey),
          Icon(Icons.people_outline, color: Colors.grey),
          Icon(Icons.account_balance_wallet_outlined, color: Colors.grey),
          Icon(Icons.directions_car, color: Colors.blue), // Aktif
          Icon(Icons.logout, color: Colors.black),
        ],
      ),
    );
  }
}