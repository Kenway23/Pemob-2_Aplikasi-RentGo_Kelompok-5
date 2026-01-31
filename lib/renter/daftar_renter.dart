import 'package:flutter/material.dart';

class DaftarRental extends StatelessWidget {
  const DaftarRental({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);
  final Color cardBg = const Color(0xFFD2E3F1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan back dan waktu
            _buildHeader(context),
            
            // Body dengan daftar rental
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildBodyContent(context),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Header dengan back button dan waktu
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          
          // Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF2F5586),
                ),
                const SizedBox(width: 6),
                Text(
                  '20:00',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Body content
  Widget _buildBodyContent(BuildContext context) {
    return Column(
      children: [
        // Title
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            'Daftar Rental',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF103667),
            ),
          ),
        ),
        
        // Filter/Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari kendaraan...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F5586),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Grid items - FIX OVERFLOW
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: constraints.maxWidth > 400 ? 0.68 : 0.72,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: 4, // Sesuai gambar: 4 item
                itemBuilder: (context, index) {
                  return _buildRentalCard(index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRentalCard(int index) {
    final List<Map<String, dynamic>> vehicleData = [
      {
        'name': 'Tesla Model S',
        'location': 'Chicago, USA',
        'status': 'Permintaan disewa',
        'statusColor': Colors.green,
        'isCar': true,
        'price': '\$100/Day',
      },
      {
        'name': 'Honda Beat',
        'location': 'Jakarta, IDN',
        'status': 'Sedang disewa',
        'statusColor': Colors.blue,
        'isCar': false,
        'price': '\$25/Day',
      },
      {
        'name': 'Ferrari LaFerrari',
        'location': 'Washington DC',
        'status': 'Permintaan disewa',
        'statusColor': Colors.green,
        'isCar': true,
        'price': '\$150/Day',
      },
      {
        'name': 'Yamaha NMAX',
        'location': 'Bandung, IDN',
        'status': 'Sedang disewa',
        'statusColor': Colors.blue,
        'isCar': false,
        'price': '\$30/Day',
      },
    ];

    final data = vehicleData[index];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigasi ke detail rental
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Area - FIXED HEIGHT
              Container(
                height: 110, // Diperkecil untuk menghindari overflow
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        data['isCar'] ? Icons.directions_car : Icons.motorcycle,
                        size: 55, // Diperkecil
                        color: primaryBlue,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: (data['statusColor'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (data['statusColor'] as Color).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: data['statusColor'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              data['status'] as String,
                              style: TextStyle(
                                fontSize: 8, // Diperkecil
                                fontWeight: FontWeight.w600,
                                color: data['statusColor'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Info Area - FIXED PADDING
              Padding(
                padding: const EdgeInsets.all(10), // Diperkecil dari 12
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // Diperkecil dari 14
                        color: Color(0xFF103667),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6), // Diperkecil dari 8
                    
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 11, // Diperkecil
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3), // Diperkecil
                        Expanded(
                          child: Text(
                            data['location'] as String,
                            style: const TextStyle(
                              fontSize: 10, // Diperkecil dari 11
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6), // Diperkecil dari 8
                    
                    // Rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(6), // Diperkecil
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 9, // Diperkecil
                                color: Colors.white,
                              ),
                              SizedBox(width: 2),
                              Text(
                                '5.0',
                                style: TextStyle(
                                  fontSize: 9, // Diperkecil
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4), // Diperkecil
                        const Text(
                          '★',
                          style: TextStyle(
                            fontSize: 10, // Diperkecil
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8), // Diperkecil dari 12
                    
                    // Price and Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['price'] as String,
                          style: TextStyle(
                            fontSize: 12, // Diperkecil dari 14
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        Container(
                          height: 28, // Diperkecil dari 30
                          width: 60, // Diperkecil dari 65
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F5586),
                            borderRadius: BorderRadius.circular(12), // Diperkecil
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2F5586).withOpacity(0.3),
                                blurRadius: 3, // Diperkecil
                                offset: const Offset(0, 1), // Diperkecil
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'SEE',
                              style: TextStyle(
                                fontSize: 10, // Diperkecil
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Daftar active
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2F5586),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Input Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Daftar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/input-data');
              break;
            case 2:
              // Already on daftar rental
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/riwayat');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profil');
              break;
          }
        },
      ),
    );
  }
}