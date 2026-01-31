import 'package:flutter/material.dart';

class DetailKendaraanPenyewa extends StatelessWidget {
  const DetailKendaraanPenyewa({super.key});

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
          const SizedBox(height: 20),
          Center(
            child: Image.network(
              'https://via.placeholder.com/300x150', 
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(),
                    const SizedBox(height: 20),
                    const Text('Car features', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildFeatureGrid(),
                    const SizedBox(height: 25),
                    _buildOwnerInfo(),
                    const SizedBox(height: 30),
                    // Tombol Sewa Sekarang yang akan memicu Modal
                    _buildMainButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan Modal Booking sesuai image_0445fc.png
  void _showBookingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            // Info Harga Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('IDR XXXXX / 1 Day', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('3 unit tersedia', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Form Fields
            _buildModalField('Unit'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildModalField('Price')),
                const SizedBox(width: 10),
                Expanded(child: _buildModalField('Day')),
              ],
            ),
            const SizedBox(height: 10),
            _buildModalField('Location'),
            const Spacer(),
            // Tombol Booking Akhir
            _buildActionButton('Booking', const Color(0xFF8EBAE8), () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Berhasil!')));
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildModalField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Center(child: Text(hint, style: TextStyle(color: Colors.blue.shade300, fontSize: 13))),
    );
  }

  Widget _buildMainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _buildActionButton('SEWA SEKARANG', const Color(0xFF8EBAE8), () {
        _showBookingModal(context);
      }),
    );
  }

  // Widget pendukung lainnya (Header, Grid, dll)
  Widget _buildHeaderInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tesla Model S', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('A car with high specs at affordable price', style: TextStyle(color: Colors.grey, fontSize: 10)),
        ]),
        Row(children: const [
          Text('5.0', style: TextStyle(fontWeight: FontWeight.bold)),
          Icon(Icons.star, color: Colors.orange, size: 18),
        ]),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: [
        _buildFeatureItem(Icons.airline_seat_recline_normal, 'Capacity', '5 Seats'),
        _buildFeatureItem(Icons.settings_input_component, 'Engine Out', '670 HP'),
        _buildFeatureItem(Icons.speed, 'Max Speed', '250km/h'),
        _buildFeatureItem(Icons.psychology, 'Advance', 'Autopilot'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 20, color: Colors.black54),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildOwnerInfo() {
    return Row(children: const [
      CircleAvatar(radius: 18, child: Icon(Icons.person)),
      SizedBox(width: 10),
      Text('GoRent Official', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      SizedBox(width: 4),
      Icon(Icons.verified, color: Colors.blue, size: 14),
    ]);
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(label, style: const TextStyle(color: Color(0xFF103667), fontWeight: FontWeight.bold)),
      ),
    );
  }
}