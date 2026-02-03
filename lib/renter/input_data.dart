import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'daftar_renter.dart';
import 'dart:convert';

class InputDataRenter extends StatefulWidget {
  const InputDataRenter({super.key});

  @override
  State<InputDataRenter> createState() => _InputDataRenterState();
}

class _InputDataRenterState extends State<InputDataRenter> {
  String selectedVehicleType = 'Mobil';

  // Controller untuk form
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _tahunController = TextEditingController();
  final TextEditingController _platController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _hargaPerHariController = TextEditingController();
  final TextEditingController _hargaPerJamController = TextEditingController();

  // Variabel untuk foto (menyimpan sebagai string base64 atau path lokal)
  String? _selectedImagePath; // Hanya menyimpan path lokal
  bool _isUploading = false;

  // Untuk fitur
  final List<String> _availableFeatures = [
    'AC',
    'Audio',
    'Kamera',
    'Leather',
    'Bluetooth',
    'Airbag',
    'Power Steering',
  ];

  final Set<String> _selectedFeatures = {
    'AC',
    'Audio',
    'Kamera',
    'Leather',
    'Bluetooth',
    'Airbag',
    'Power Steering',
  };

  @override
  void initState() {
    super.initState();
    // Set nilai default untuk harga
    _hargaPerJamController.text = '50.000';
    _hargaPerHariController.text = '500.000';
    _lokasiController.text = 'Jakarta, Indonesia';
  }

  // Fungsi untuk memilih gambar dari gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Fungsi untuk menyimpan data ke Firebase (TANPA Storage)
  Future<void> _saveVehicleToFirebase(BuildContext context) async {
    try {
      // Validasi input
      if (_namaController.text.isEmpty ||
          _merkController.text.isEmpty ||
          _tahunController.text.isEmpty ||
          _platController.text.isEmpty ||
          _lokasiController.text.isEmpty ||
          _hargaPerHariController.text.isEmpty ||
          _hargaPerJamController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap isi semua field yang diperlukan'),
          ),
        );
        return;
      }

      final FirebaseAuth _auth = FirebaseAuth.instance;
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final User? user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login terlebih dahulu')),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      // Konversi gambar ke base64 (opsional)
      String? base64Image;
      if (_selectedImagePath != null) {
        try {
          final bytes = await File(_selectedImagePath!).readAsBytes();
          base64Image = base64Encode(bytes);
        } catch (e) {
          print('Error converting image to base64: $e');
        }
      }

      // Konversi fitur menjadi string
      String fiturString = _selectedFeatures.join(', ');

      // Data yang akan disimpan
      Map<String, dynamic> vehicleData = {
        'createdAt': FieldValue.serverTimestamp(),
        'fitur': fiturString,
        'hargaPerhari': _hargaPerHariController.text,
        'hargaPerjam': _hargaPerJamController.text,
        'jenis': selectedVehicleType,
        'lokasi': _lokasiController.text,
        'merk': _merkController.text,
        'namaKendaraan': _namaController.text,
        'ownerEmail': user.email,
        'ownerId': user.uid,
        'plat': _platController.text,
        'tahun': _tahunController.text,
      };

      // Tambahkan gambar sebagai base64 jika ada
      if (base64Image != null) {
        vehicleData['fotoBase64'] = base64Image;
        vehicleData['fotoPath'] = _selectedImagePath;
      }

      // Simpan ke Firebase Firestore
      await _firestore.collection('vehicles').add(vehicleData);

      // Tampilkan dialog sukses
      _showSuccessDialog(context);
    } catch (e) {
      print('Error saving vehicle: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Widget untuk memilih foto
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Kendaraan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF103667),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
            ),
            child: _selectedImagePath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap untuk menambah foto',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedImagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
          ),
        ),
        if (_selectedImagePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedImagePath = null;
                    });
                  },
                  child: const Text(
                    'Hapus Foto',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Widget untuk kartu jenis kendaraan
  Widget _vehicleTypeItem({
    required IconData icon,
    required String label,
    required String description,
  }) {
    final bool isSelected = selectedVehicleType == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVehicleType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2F5586).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2F5586) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2F5586) : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF103667) : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF2F5586).withOpacity(0.8)
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk chip fitur
  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedFeatures.remove(label);
          } else {
            _selectedFeatures.add(label);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F5586) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF2F5586) : Colors.grey[300]!,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF2F5586).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF2F5586),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk form field
  Widget _buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF103667),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF2F5586).withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                    keyboardType: keyboardType,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF103667)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Kendaraan',
          style: TextStyle(
            color: Color(0xFF103667),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Type Selection
                const Text(
                  'Pilih Jenis Kendaraan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF103667),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pilih jenis kendaraan yang akan Anda sewakan',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // Vehicle Type Cards
                Row(
                  children: [
                    Expanded(
                      child: _vehicleTypeItem(
                        icon: Icons.directions_car,
                        label: 'Mobil',
                        description: 'Sedan, SUV, MPV',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _vehicleTypeItem(
                        icon: Icons.motorcycle,
                        label: 'Motor',
                        description: 'Sport, Matic, Bebek',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _vehicleTypeItem(
                        icon: Icons.directions_bus,
                        label: 'Bus',
                        description: 'Mini Bus, Big Bus',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Form Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Title
                      const Text(
                        'Detail Kendaraan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF103667),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form Fields
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Nama Kendaraan',
                                  hint: 'Tesla Model S',
                                  icon: Icons.directions_car,
                                  controller: _namaController,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Merk',
                                  hint: 'Tesla',
                                  icon: Icons.branding_watermark,
                                  controller: _merkController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Tahun',
                                  hint: '2023',
                                  icon: Icons.calendar_today,
                                  keyboardType: TextInputType.number,
                                  controller: _tahunController,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Plat Nomor',
                                  hint: 'B 1234 ABC',
                                  icon: Icons.confirmation_number,
                                  controller: _platController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Photo Section
                          _buildImagePicker(),

                          const SizedBox(height: 20),

                          // Location Field
                          _buildFormField(
                            label: 'Lokasi Kendaraan',
                            hint: 'Jakarta, Indonesia',
                            icon: Icons.location_on,
                            controller: _lokasiController,
                          ),

                          const SizedBox(height: 20),

                          // Price Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Harga Sewa',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF103667),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildPriceCard(
                                      title: 'Per Hari',
                                      controller: _hargaPerHariController,
                                      icon: Icons.calendar_today,
                                      timeUnit: '/hari',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildPriceCard(
                                      title: 'Per Jam',
                                      controller: _hargaPerJamController,
                                      icon: Icons.access_time,
                                      timeUnit: '/jam',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Features Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fitur & Spesifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF103667),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pilih fitur yang tersedia di kendaraan Anda',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),

                      // Features Grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableFeatures.map((feature) {
                          IconData icon = _getIconForFeature(feature);
                          return _buildFeatureChip(
                            icon: icon,
                            label: feature,
                            isSelected: _selectedFeatures.contains(feature),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isUploading
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF2F5586)),
                        ),
                        child: const Text(
                          'Batalkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2F5586),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isUploading
                            ? null
                            : () => _saveVehicleToFirebase(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F5586),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Simpan Data',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Loading overlay
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F5586)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget untuk kartu harga
  Widget _buildPriceCard({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required String timeUnit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5586).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF2F5586)),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF103667),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'IDR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F5586),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Text(
                timeUnit,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mendapatkan icon berdasarkan fitur
  IconData _getIconForFeature(String feature) {
    switch (feature) {
      case 'AC':
        return Icons.ac_unit;
      case 'Audio':
        return Icons.audiotrack;
      case 'Kamera':
        return Icons.camera_alt;
      case 'Leather':
        return Icons.chair;
      case 'Bluetooth':
        return Icons.bluetooth;
      case 'Airbag':
        return Icons.security;
      case 'Power Steering':
        return Icons.power;
      default:
        return Icons.settings;
    }
  }

  // Fungsi untuk menampilkan dialog sukses
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5586).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Color(0xFF2F5586),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Data kendaraan berhasil disimpan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DaftarRental(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5586),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lihat di Daftar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
