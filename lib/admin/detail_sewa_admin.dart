import 'package:flutter/material.dart';

class DetailSewaAdminPage extends StatelessWidget {
  const DetailSewaAdminPage({super.key});

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
            'Car Details',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Gambar Kendaraan Besar
          Center(
            child: Image.network(
              'https://via.placeholder.com/300x150', // Ganti dengan asset mobil putih
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          // Panel Putih Detail
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tesla Model S', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          children: const [
                            Text('5.0', style: TextStyle(fontWeight: FontWeight.bold)),
                            Icon(Icons.star, color: Colors.orange, size: 20),
                          ],
                        ),
                      ],
                    ),
                    const Text('Sedang menunggu persetujuan', 
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('(100+ Reviews)', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ),
                    
                    const SizedBox(height: 20),
                    const Text('Car features', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    
                    // Grid Fitur Kendaraan
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        _buildFeatureItem(Icons.event_seat, 'Capacity', '5 Seats'),
                        _buildFeatureItem(Icons.bolt, 'Engine Out', '670 HP'),
                        _buildFeatureItem(Icons.speed, 'Max Speed', '250km/h'),
                        _buildFeatureItem(Icons.settings_input_component, 'Advance', 'Autopilot'),
                        _buildFeatureItem(Icons.ev_station, 'Single Charge', '405 Miles'),
                        _buildFeatureItem(Icons.timer, 'Time', '1 Day'),
                        _buildFeatureItem(Icons.payments, 'Price', 'IDR XXXXX'),
                        _buildFeatureItem(Icons.check_circle, 'Available', '✓', isGreen: true),
                      ],
                    ),

                    const SizedBox(height: 25),
                    // Info Penyewa
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Text('Penyewa', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5),
                        Icon(Icons.verified, color: Colors.blue.shade400, size: 16),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    // Bar Harga & Lokasi
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('IDR XXXXX / 3 Day', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: const [
                              Icon(Icons.location_on, color: Colors.red, size: 16),
                              Text(' Chicago, USA', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    // Tombol Aksi
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton('Tolak', const Color(0xFFABC9EB), Colors.black),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildActionButton('Setuju', const Color(0xFF8EBAE8), Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String value, {bool isGreen = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: isGreen ? Colors.green : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isGreen ? Colors.green : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, Color textColor) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}