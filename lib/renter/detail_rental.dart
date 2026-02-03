import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailRental extends StatefulWidget {
  final Map<String, dynamic> vehicleData;
  final String vehicleId;

  static const Color primaryBlue = Color(0xFF2F5586);

  const DetailRental({
    super.key,
    required this.vehicleData,
    required this.vehicleId,
  });

  @override
  State<DetailRental> createState() => _DetailRentalState();
}

class _DetailRentalState extends State<DetailRental> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Map<String, dynamic> vehicleData;

  @override
  void initState() {
    super.initState();
    vehicleData = widget.vehicleData;
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG: Print data untuk melihat struktur
    print('=== DEBUG VEHICLE DATA ===');
    print('Vehicle ID: ${widget.vehicleId}');
    print('All keys: ${vehicleData.keys.toList()}');
    print('=== END DEBUG ===');

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
      backgroundColor: DetailRental.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
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
                        const SizedBox(height: 20),
                        _actionButtons(context),
                      ],
                    ),
                  ),
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
                _handleTolakPenyewaan(context);
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
                backgroundColor: DetailRental.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                _handleSetujuiPenyewaan(context);
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
                backgroundColor: DetailRental.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                _showEditModal(context);
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
                _handleHapusKendaraan(context);
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

  // ================= FUNGSI EDIT (Modal) =================
  Future<void> _showEditModal(BuildContext context) async {
    // Cek apakah user adalah pemilik kendaraan
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showErrorDialog(context, 'Anda harus login terlebih dahulu');
      return;
    }

    // Cari field pemilik - dicoba berbagai kemungkinan
    String ownerId = '';
    final possibleFields = [
      'ownerId',
      'pemilikId',
      'userId',
      'pemilik',
      'owner',
      'uid',
    ];

    for (var field in possibleFields) {
      if (vehicleData.containsKey(field) && vehicleData[field] != null) {
        ownerId = vehicleData[field].toString();
        break;
      }
    }

    print('DEBUG - Owner ID found: $ownerId');
    print('DEBUG - Current User UID: ${currentUser.uid}');

    // Jika ownerId tidak ditemukan, beri pilihan untuk lanjut edit
    if (ownerId.isEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Data pemilik tidak ditemukan. Lanjutkan edit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lanjutkan'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    } else if (ownerId != currentUser.uid) {
      _showErrorDialog(context, 'Anda bukan pemilik kendaraan ini');
      return;
    }

    // Kontroller untuk form edit
    final namaController = TextEditingController(
      text: vehicleData['namaKendaraan']?.toString() ?? '',
    );
    final jenisController = TextEditingController(
      text: vehicleData['jenis']?.toString() ?? 'Mobil',
    );
    final merkController = TextEditingController(
      text: vehicleData['merk']?.toString() ?? '',
    );
    final tahunController = TextEditingController(
      text: vehicleData['tahun']?.toString() ?? '',
    );
    final platController = TextEditingController(
      text: vehicleData['plat']?.toString() ?? '',
    );
    final lokasiController = TextEditingController(
      text: vehicleData['lokasi']?.toString() ?? '',
    );
    final hargaPerHariController = TextEditingController(
      text: vehicleData['hargaPerhari']?.toString() ?? '0',
    );
    final hargaPerJamController = TextEditingController(
      text: vehicleData['hargaPerjam']?.toString() ?? '0',
    );
    final fiturController = TextEditingController(
      text: vehicleData['fitur']?.toString() ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Edit Kendaraan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF103667),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('Nama Kendaraan', namaController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('Jenis', jenisController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Merk', merkController)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('Tahun', tahunController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Plat', platController)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField('Lokasi', lokasiController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Harga/Hari',
                      hargaPerHariController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Harga/Jam',
                      hargaPerJamController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Fitur (pisahkan dengan koma)',
                fiturController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _handleUpdateKendaraan(
                          context,
                          namaController.text,
                          jenisController.text,
                          merkController.text,
                          tahunController.text,
                          platController.text,
                          lokasiController.text,
                          hargaPerHariController.text,
                          hargaPerJamController.text,
                          fiturController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DetailRental.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpdateKendaraan(
    BuildContext context,
    String nama,
    String jenis,
    String merk,
    String tahun,
    String plat,
    String lokasi,
    String hargaPerHari,
    String hargaPerJam,
    String fitur,
  ) async {
    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: DetailRental.primaryBlue),
      ),
    );

    try {
      // Update data di Firestore
      await _firestore.collection('vehicles').doc(widget.vehicleId).update({
        'namaKendaraan': nama,
        'jenis': jenis,
        'merk': merk,
        'tahun': tahun,
        'plat': plat,
        'lokasi': lokasi,
        'hargaPerhari': int.tryParse(hargaPerHari) ?? 0,
        'hargaPerjam': int.tryParse(hargaPerJam) ?? 0,
        'fitur': fitur,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local data
      setState(() {
        vehicleData = {
          ...vehicleData,
          'namaKendaraan': nama,
          'jenis': jenis,
          'merk': merk,
          'tahun': tahun,
          'plat': plat,
          'lokasi': lokasi,
          'hargaPerhari': hargaPerHari,
          'hargaPerjam': hargaPerJam,
          'fitur': fitur,
        };
      });

      Navigator.pop(context); // Tutup loading
      Navigator.pop(context); // Tutup modal

      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kendaraan berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      _showErrorDialog(context, 'Gagal memperbarui kendaraan: $e');
    }
  }

  // ================= FUNGSI HAPUS =================
  Future<void> _handleHapusKendaraan(BuildContext context) async {
    final confirmed = await _showDeleteConfirmationDialog(context);
    if (confirmed != true) return;

    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: DetailRental.primaryBlue),
      ),
    );

    try {
      // Cek apakah user adalah pemilik kendaraan
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Navigator.pop(context); // Tutup loading
        _showErrorDialog(context, 'Anda harus login terlebih dahulu');
        return;
      }

      // Cari field pemilik - dicoba berbagai kemungkinan
      String ownerId = '';
      final possibleFields = [
        'ownerId',
        'pemilikId',
        'userId',
        'pemilik',
        'owner',
        'uid',
      ];

      for (var field in possibleFields) {
        if (vehicleData.containsKey(field) && vehicleData[field] != null) {
          ownerId = vehicleData[field].toString();
          break;
        }
      }

      print('DEBUG DELETE - Owner ID found: $ownerId');
      print('DEBUG DELETE - Current User UID: ${currentUser.uid}');

      // Jika ownerId tidak ditemukan, beri pilihan untuk lanjut hapus
      if (ownerId.isEmpty) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Peringatan'),
            content: const Text(
              'Data pemilik tidak ditemukan. Lanjutkan menghapus?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Lanjutkan Hapus'),
              ),
            ],
          ),
        );

        if (proceed != true) {
          Navigator.pop(context); // Tutup loading
          return;
        }
      } else if (ownerId != currentUser.uid) {
        Navigator.pop(context); // Tutup loading
        _showErrorDialog(context, 'Anda bukan pemilik kendaraan ini');
        return;
      }

      // Cek apakah kendaraan sedang disewa
      final status = vehicleData['status']?.toString()?.toLowerCase() ?? '';
      if (status == 'disewa' || status == 'pending') {
        Navigator.pop(context); // Tutup loading
        _showErrorDialog(
          context,
          'Tidak dapat menghapus kendaraan yang sedang disewa atau dalam proses sewa',
        );
        return;
      }

      // Hapus kendaraan dari Firestore
      await _firestore.collection('vehicles').doc(widget.vehicleId).delete();

      Navigator.pop(context); // Tutup loading
      Navigator.pop(context); // Kembali ke halaman sebelumnya

      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kendaraan berhasil dihapus'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      _showErrorDialog(context, 'Gagal menghapus kendaraan: $e');
    }
  }

  // ================= FUNGSI SETUJUI PENYEWAAN =================
  Future<void> _handleSetujuiPenyewaan(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Setujui Penyewaan',
      'Apakah Anda yakin menyetujui penyewaan ini?',
    );

    if (confirmed != true) return;

    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: DetailRental.primaryBlue),
      ),
    );

    try {
      // Update status kendaraan menjadi 'disewa'
      await _firestore.collection('vehicles').doc(widget.vehicleId).update({
        'status': 'disewa',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local data
      setState(() {
        vehicleData['status'] = 'disewa';
      });

      // Buat log penyewaan
      await _firestore.collection('rentals').add({
        'vehicleId': widget.vehicleId,
        'vehicleName': vehicleData['namaKendaraan'] ?? '',
        'penyewaId': vehicleData['penyewaId'] ?? '',
        'penyewaNama': vehicleData['penyewaNama'] ?? 'Penyewa',
        'totalHarga': vehicleData['totalHarga'] ?? 0,
        'durasi': vehicleData['durasi'] ?? 1,
        'lokasiPenyewa': vehicleData['lokasiPenyewa'] ?? '',
        'status': 'active',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': _auth.currentUser?.uid ?? '',
        'startDate': vehicleData['startDate'] ?? FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Tutup loading

      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penyewaan berhasil disetujui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      _showErrorDialog(context, 'Gagal menyetujui penyewaan: $e');
    }
  }

  // ================= FUNGSI TOLAK PENYEWAAN =================
  Future<void> _handleTolakPenyewaan(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Tolak Penyewaan',
      'Apakah Anda yakin menolak penyewaan ini?',
    );

    if (confirmed != true) return;

    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: DetailRental.primaryBlue),
      ),
    );

    try {
      // Update status kendaraan menjadi 'tersedia' kembali
      await _firestore.collection('vehicles').doc(widget.vehicleId).update({
        'status': 'tersedia',
        'penyewaId': null,
        'penyewaNama': null,
        'totalHarga': null,
        'durasi': null,
        'lokasiPenyewa': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local data
      setState(() {
        vehicleData['status'] = 'tersedia';
        vehicleData.remove('penyewaId');
        vehicleData.remove('penyewaNama');
        vehicleData.remove('totalHarga');
        vehicleData.remove('durasi');
        vehicleData.remove('lokasiPenyewa');
      });

      // Simpan riwayat penolakan
      await _firestore.collection('rejected_rentals').add({
        'vehicleId': widget.vehicleId,
        'vehicleName': vehicleData['namaKendaraan'] ?? '',
        'penyewaId': vehicleData['penyewaId'] ?? '',
        'penyewaNama': vehicleData['penyewaNama'] ?? 'Penyewa',
        'reason': 'Ditolak oleh pemilik',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': _auth.currentUser?.uid ?? '',
      });

      Navigator.pop(context); // Tutup loading

      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penyewaan berhasil ditolak'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      _showErrorDialog(context, 'Gagal menolak penyewaan: $e');
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

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
