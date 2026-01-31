import 'package:flutter/material.dart';

class BusPage extends StatelessWidget {
  const BusPage({super.key});

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
            'GoRent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Search Bar & Filter Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text('Search your dream car.....', 
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.tune, color: primaryBlue, size: 20),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Putih Panel Utama
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Category Filter Bar (Bus selected)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          _buildCategoryItem('ALL', Icons.all_inclusive, false),
                          _buildCategoryItem('Bus', Icons.directions_bus, true),
                          _buildCategoryItem('Mobil', Icons.directions_car, false),
                          _buildCategoryItem('Motor', Icons.pedal_bike, false),
                        ],
                      ),
                    ),
                  ),
                  
                  // Grid Daftar Bus
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: 4, // Sesuai gambar
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemBuilder: (context, index) {
                        return _buildBusCard();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8EBAE8) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(
            fontSize: 12, 
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          )),
        ],
      ),
    );
  }

  Widget _buildBusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Center(
                  child: Image.network(
                    'https://via.placeholder.com/120x80', // Ganti dengan asset bus
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Positioned(
                top: 8, right: 8,
                child: CircleAvatar(
                  radius: 12, backgroundColor: Colors.white,
                  child: Icon(Icons.favorite_border, color: Colors.red, size: 14),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tesla Model S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 2),
                Row(children: const [
                  Text('5.0', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Icon(Icons.star, color: Colors.orange, size: 10),
                ]),
                const SizedBox(height: 2),
                Row(children: const [
                  Icon(Icons.location_on, color: Colors.red, size: 10),
                  Text(' Chicago, USA', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('\$100/Day', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF8EBAE8), borderRadius: BorderRadius.circular(10)),
                      child: const Text('Book now', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
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

  Widget _buildBottomNav() {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E9F2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.home_outlined, color: Colors.grey),
          Icon(Icons.search, color: Colors.blue),
          Icon(Icons.info_outline, color: Colors.grey),
          Icon(Icons.person_outline, color: Colors.grey),
        ],
      ),
    );
  }
}