import 'package:flutter/material.dart';
import 'dart:convert';

class DetailRental extends StatelessWidget {
  final Map<String, dynamic> vehicleData;
  final String vehicleId;

  static const Color primaryBlue = Color(0xFF2F5586);

  const DetailRental({
    super.key,
    required this.vehicleData,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    // Ekstrak data dari vehicleData
    final name =
        vehicleData['namaKendaraan']?.toString() ?? 'Nama tidak tersedia';
    final jenis = vehicleData['jenis']?.toString() ?? 'Mobil';
    final merk = vehicleData['merk']?.toString() ?? '';
    final tahun = vehicleData['tahun']?.toString() ?? '';
    final plat = vehicleData['plat']?.toString() ?? '';
    final lokasi = vehicleData['lokasi']?.toString() ?? 'Lokasi tidak tersedia';
    final hargaPerHari = vehicleData['hargaPerhari']?.toString() ?? '0';
    final hargaPerJam = vehicleData['hargaPerjam']?.toString() ?? '0';
    final fitur = vehicleData['fitur']?.toString() ?? '';

    // Format harga
    final formattedHargaPerHari = _formatRupiah(hargaPerHari);
    final formattedHargaPerJam = _formatRupiah(hargaPerJam);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    _carInfo(name, merk, tahun),
                    const SizedBox(height: 16),
                    _features(
                      jenis,
                      plat,
                      formattedHargaPerHari,
                      formattedHargaPerJam,
                      lokasi,
                      fitur,
                    ),
                    const SizedBox(height: 16),
                    _renterInfo(),
                    const Spacer(),
                    _actionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Text('Kembali', style: TextStyle(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Detail Kendaraan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildVehicleImage(),
      ],
    );
  }

  Widget _buildVehicleImage() {
    // Cek jika ada gambar base64
    if (vehicleData.containsKey('fotoBase64') &&
        vehicleData['fotoBase64'] != null) {
      try {
        final base64Image = vehicleData['fotoBase64'].toString();
        if (base64Image.isNotEmpty) {
          return Container(
            height: 160,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.memory(
                base64Decode(base64Image),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultImage(),
              ),
            ),
          );
        }
      } catch (e) {
        print('Error loading base64 image: $e');
      }
    }

    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    final jenis = vehicleData['jenis']?.toString() ?? 'Mobil';
    IconData icon;

    switch (jenis.toLowerCase()) {
      case 'motor':
        icon = Icons.motorcycle;
        break;
      case 'bus':
        icon = Icons.directions_bus;
        break;
      default:
        icon = Icons.directions_car;
    }

    return Container(
      height: 140,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, size: 80, color: Colors.white),
    );
  }

  // ================= CAR INFO =================
  Widget _carInfo(String name, String merk, String tahun) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$merk${merk.isNotEmpty && tahun.isNotEmpty ? ' • ' : ''}$tahun',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        // Rating (jika ada di data)
        if (vehicleData.containsKey('rating') && vehicleData['rating'] != null)
          Row(
            children: [
              Text(
                vehicleData['rating'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.orange, size: 18),
              const SizedBox(width: 4),
              Text(
                '(${vehicleData['reviewCount']?.toString() ?? '0'} Reviews)',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
      ],
    );
  }

  // ================= FEATURES =================
  Widget _features(
    String jenis,
    String plat,
    String hargaPerHari,
    String hargaPerJam,
    String lokasi,
    String fitur,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Kendaraan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF103667),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            _FeatureItem('Jenis', jenis, Icons.category),
            _FeatureItem(
              'Plat',
              plat.isNotEmpty ? plat : '-',
              Icons.confirmation_number,
            ),
            _FeatureItem('Lokasi', lokasi, Icons.location_on),
            _FeatureItem('Harga/Hari', hargaPerHari, Icons.attach_money),
            _FeatureItem('Harga/Jam', hargaPerJam, Icons.access_time),
            _FeatureItem('Status', 'Tersedia', Icons.check_circle),
          ],
        ),

        // Fitur tambahan jika ada
        if (fitur.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Fitur Tambahan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF103667),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              fitur,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ],
    );
  }

  // ================= RENTER INFO =================
  Widget _renterInfo() {
    // Ekstrak data lokasi dari vehicleData
    final lokasiKendaraan =
        vehicleData['lokasi']?.toString() ?? 'Lokasi tidak tersedia';

    // Cek apakah ada data penyewa
    final hasRenter =
        vehicleData.containsKey('penyewaId') &&
        vehicleData['penyewaId'] != null &&
        vehicleData['penyewaId'].toString().isNotEmpty;

    if (!hasRenter) {
      return Container(); // Kosong jika tidak ada penyewa
    }

    final penyewaNama = vehicleData['penyewaNama']?.toString() ?? 'Penyewa';
    final totalHarga = vehicleData['totalHarga']?.toString() ?? '0';
    final durasi = vehicleData['durasi']?.toString() ?? '1';

    // Gunakan lokasi penyewa jika ada, jika tidak gunakan lokasi kendaraan
    final lokasiPenyewa =
        vehicleData['lokasiPenyewa']?.toString() ?? lokasiKendaraan;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF2F5586),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  penyewaNama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatRupiah(totalHarga)} / $durasi Hari',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 18),
              const SizedBox(width: 4),
              Text(
                lokasiPenyewa,
                style: const TextStyle(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ACTION BUTTONS =================
  Widget _actionButtons(BuildContext context) {
    final status =
        vehicleData['status']?.toString()?.toLowerCase() ?? 'tersedia';

    if (status == 'pending') {
      // Jika status pending, tampilkan tombol tolak/setujui
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // TODO: Handle tolak
                _showConfirmationDialog(
                  context,
                  'Tolak Penyewaan',
                  'Apakah Anda yakin menolak penyewaan ini?',
                );
              },
              child: const Text(
                'Tolak',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // TODO: Handle setujui
                _showConfirmationDialog(
                  context,
                  'Setujui Penyewaan',
                  'Apakah Anda yakin menyetujui penyewaan ini?',
                );
              },
              child: const Text(
                'Setujui',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Jika status lain, tampilkan tombol edit/hapus
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // TODO: Navigasi ke halaman edit
                Navigator.pop(context);
              },
              child: const Text(
                'Edit Kendaraan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final confirmed = await _showDeleteConfirmationDialog(context);
                if (confirmed == true) {
                  // TODO: Handle delete
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Hapus Kendaraan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }
  }

  // ================= HELPER METHODS =================
  String _formatRupiah(String value) {
    try {
      final number = int.tryParse(value) ?? 0;
      return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } catch (e) {
      return 'Rp $value';
    }
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement action
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kendaraan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kendaraan ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ================= FEATURE ITEM =================
class _FeatureItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _FeatureItem(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: DetailRental.primaryBlue, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF103667),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
