import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

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
        title: const Text(
          'Back',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          // Gambar Background Watermark (Bus/Mobil transparan)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://via.placeholder.com/400', // Ganti dengan asset kendaraanmu
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Text(
                  'GoRent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Deskripsi Aplikasi
                _buildSectionTitle('Deskripsi Aplikasi'),
                _buildOutlineBox(
                  'GoRent adalah aplikasi penyewaan kendaraan berbasis mobile yang menyediakan berbagai pilihan kendaraan seperti mobil, motor, dan bus.',
                ),

                // Tujuan Aplikasi
                _buildSectionTitle('Tujuan Aplikasi'),
                _buildOutlineBox(
                  '• Memudahkan pengguna dalam mencari dan menyewa kendaraan\n'
                  '• Menyediakan informasi kendaraan secara lengkap dan informatif\n'
                  '• Menjadi media pembelajaran dalam pengembangan aplikasi mobile',
                ),

                // Fitur Utama
                _buildSectionTitle('Fitur Utama Aplikasi'),
                _buildOutlineBox(
                  '• Login & Register Pengguna\n'
                  '• List dan Pencarian Kendaraan\n'
                  '• Detail Informasi Kendaraan\n'
                  '• Input Data Informasi Kendaraan\n'
                  '• Dashboard Ringkasan Data\n'
                  '• Navigasi (Bottom Navigation / Sidebar)',
                ),

                // Tim Pengembang
                _buildSectionTitle('Tim Pengembang'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '1.Rifki Muhamad Fauzi\n2.Akmal Yusril Fani.\n3.Riki Gusti\n4.Natalia Margaretha\n5.Nisa Silva Triana',
                          style: TextStyle(color: Colors.white, height: 1.5),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white54,
                            style: BorderStyle.none,
                          ), // Placeholder kotak foto
                          color: Colors.white10,
                        ),
                        child: const Icon(
                          Icons.qr_code_2,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOutlineBox(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        content,
        style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.home_outlined, color: Colors.grey),
          Icon(Icons.search, color: Colors.grey),
          Icon(Icons.info, color: Colors.blue), // Icon Info aktif
          Icon(Icons.person_outline, color: Colors.grey),
        ],
      ),
    );
  }
}
