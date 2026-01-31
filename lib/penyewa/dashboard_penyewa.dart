import 'package:flutter/material.dart';

class DashboardOwner extends StatelessWidget {
  const DashboardOwner({super.key});

  final Color primaryBlue = const Color(0xFF103667); // Biru Tua Header
  final Color backgroundBlue = const Color(0xFF2F5586); // Biru Latar Belakang
  final Color accentBlue = const Color(0xFF6A94C9); // Biru Tombol SEE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          const Text(
            'GoRent',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner: Ayo Rental kan Kendaraanmu
                    _buildPromotionBanner(),
                    const SizedBox(height: 25),

                    // Statistik: Total Sewa, Sewa Aktif, Sewa Selesai
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard('Total Sewa'),
                        _buildStatCard('Sewa Aktif'),
                        _buildStatCard('Sewa Selesai'),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Section Riwayat
                    _buildSectionHeader('Riwayat'),
                    _buildRiwayatCard(),
                    const SizedBox(height: 25),

                    // Section Daftar Rental
                    _buildSectionHeader('Daftar Rental'),
                    _buildRentalGrid(),
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

  Widget _buildPromotionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Text(
            'Ayo Rental kan Kendaraanmu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              minimumSize: const Size(220, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Mulai sewakan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title) {
    return Container(
      width: 100,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
          const Text('View All', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          // Gambar Vespa (Placeholder)
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/80'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vespa Primavera 150', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.calendar_month, size: 14, color: Colors.black54),
                  SizedBox(width: 4),
                  Text('23 Januari 2026', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Text('Status : ', style: TextStyle(fontSize: 12)),
                  Icon(Icons.circle, size: 10, color: Colors.red),
                  Text(' Selesai Disewa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRentalGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        bool isCar = index == 0;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFD2E3F1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Icon(isCar ? Icons.directions_car : Icons.motorcycle, size: 60, color: backgroundBlue),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tesla Model S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: isCar ? Colors.green : Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isCar ? 'Sedang Disewa' : 'Permintaan disewa', 
                            style: const TextStyle(fontSize: 9),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.location_on, size: 12, color: Colors.red),
                        Text(' Chicago, USA', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$100/Day', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryBlue)),
                        SizedBox(
                          height: 25,
                          width: 55,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBlue,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('SEE', style: TextStyle(fontSize: 9, color: Colors.white)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
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
          _navIcon(Icons.home_outlined, false),
          _navIcon(Icons.chat_bubble_outline, false),
          _navIcon(Icons.add_circle_outline, true),
          _navIcon(Icons.info_outline, false),
          _navIcon(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, bool isCenter) {
    return Icon(icon, color: isCenter ? Colors.purple : Colors.black54, size: 28);
  }
}