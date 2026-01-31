import 'package:flutter/material.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue, // Latar belakang atas biru sesuai gambar
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
              fontSize: 28,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Grid (Total User, Total Transaksi, etc.)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      children: [
                        _buildInfoCard('Total User', Icons.people_outline),
                        _buildInfoCard('Total Transaksi', Icons.money_outlined),
                        _buildInfoCard('Total Kendaraan', Icons.directions_car_filled_outlined),
                        _buildInfoCard('Logout', Icons.logout),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    // Header Daftar Rental
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daftar Rental', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2F5586))),
                        Text('View All', 
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Grid Daftar Kendaraan
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 2, // Sesuai baris pertama di gambar
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemBuilder: (context, index) {
                        return _buildRentalCard(index);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAdminBottomNav(),
    );
  }

  // Card untuk Ringkasan Admin (Total User, dll)
  Widget _buildInfoCard(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2F5586))),
          const SizedBox(height: 10),
          Icon(icon, size: 35, color: Colors.black87),
        ],
      ),
    );
  }

  // Card untuk Item Kendaraan
  Widget _buildRentalCard(int index) {
    bool isCar = index == 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFC7D9EF), // Biru muda background gambar
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Center(
              child: Icon(isCar ? Icons.directions_car : Icons.pedal_bike, size: 50, color: Colors.black54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tesla Model S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.circle, size: 8, color: isCar ? Colors.green : Colors.grey),
                  const SizedBox(width: 4),
                  Text(isCar ? 'Sedang Disewa' : 'Permintaan disewa', 
                    style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ]),
                const SizedBox(height: 4),
                Row(children: const [
                  Icon(Icons.location_on, color: Colors.red, size: 10),
                  Text(' Chicago, USA', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('\$100/Day', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2F5586))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8EBAE8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('SEE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // Bottom Nav Khusus Admin sesuai Gambar
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
          Icon(Icons.home_outlined, color: Colors.blue), // Home Aktif
          Icon(Icons.people_outline, color: Colors.grey),
          Icon(Icons.account_balance_wallet_outlined, color: Colors.grey),
          Icon(Icons.directions_car_outlined, color: Colors.grey),
          Icon(Icons.logout, color: Colors.black),
        ],
      ),
    );
  }
}