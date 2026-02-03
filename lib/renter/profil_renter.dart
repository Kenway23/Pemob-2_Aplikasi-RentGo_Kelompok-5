import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class ProfilRenter extends StatefulWidget {
  const ProfilRenter({super.key});

  @override
  State<ProfilRenter> createState() => _ProfilRenterState();
}

class _ProfilRenterState extends State<ProfilRenter> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> _userData = {};
  int _totalKendaraan = 0;
  int _sewaAktif = 0;
  int _sewaSelesai = 0;
  bool _isLoading = true;
  String _currentTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadUserData();
    _loadRentalStats();

    // Update waktu setiap menit
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      final now = DateTime.now();
      _currentTime = DateFormat('HH:mm').format(now);
    });
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: _currentUser!.uid)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        setState(() {
          _userData = usersSnapshot.docs.first.data();
          _isLoading = false;
        });
      } else {
        // Buat user baru jika belum ada
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set({
              'nama': _currentUser!.displayName ?? 'User',
              'email': _currentUser!.email ?? '',
              'uid': _currentUser!.uid,
              'role': 'renter',
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        setState(() {
          _userData = {
            'nama': _currentUser!.displayName ?? 'User',
            'email': _currentUser!.email ?? '',
            'role': 'renter',
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRentalStats() async {
    if (_currentUser == null) return;

    try {
      // Hitung jumlah kendaraan milik user
      final vehiclesSnapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('ownerId', isEqualTo: _currentUser!.uid)
          .get();

      setState(() {
        _totalKendaraan = vehiclesSnapshot.docs.length;
      });

      // Hitung transaksi dari bookings (jika ada)
      try {
        int aktif = 0;
        int selesai = 0;

        // Coba collection 'bookings'
        final bookingsSnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('ownerId', isEqualTo: _currentUser!.uid)
            .get();

        for (var booking in bookingsSnapshot.docs) {
          final status = booking['status']?.toString()?.toLowerCase() ?? '';

          if (status.contains('aktif') || status.contains('pending')) {
            aktif++;
          } else if (status.contains('selesai') ||
              status.contains('complete')) {
            selesai++;
          }
        }

        setState(() {
          _sewaAktif = aktif;
          _sewaSelesai = selesai;
        });
      } catch (e) {
        print('Error loading bookings: $e');
        // Default values
        setState(() {
          _sewaAktif = 0;
          _sewaSelesai = 0;
        });
      }
    } catch (e) {
      print('Error loading rental stats: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal logout'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // TAMBAHKAN METHOD INI:
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Upload otomatis setelah memilih
      _uploadImageToFirestore();
    }
  }

  // TAMBAHKAN METHOD INI:
  Future<void> _uploadImageToFirestore() async {
    if (_selectedImage == null || _currentUser == null) return;

    setState(() => _isUploading = true);

    try {
      // 1. Baca file sebagai bytes
      final bytes = await _selectedImage!.readAsBytes();

      // 2. Convert ke base64 string
      final base64Image = base64Encode(bytes);

      // 3. Simpan ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
            'photoBase64': base64Image,
            'photoUpdatedAt': FieldValue.serverTimestamp(),
          });

      // 4. Update state
      setState(() {
        _userData['photoBase64'] = base64Image;
        _isUploading = false;
      });

      // 5. Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diupload'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error uploading image: $e');
      setState(() => _isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal upload foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // TAMBAHKAN METHOD INI:
  void _showPhotoOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Pilih Foto Profil',
          style: TextStyle(
            color: Color(0xFF103667),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF2F5586),
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2F5586)),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _takePhotoWithCamera();
              },
            ),
            if (_userData.containsKey('photoBase64') &&
                _userData['photoBase64'] != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfilePhoto();
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  // TAMBAHKAN METHOD INI:
  Future<void> _takePhotoWithCamera() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      _uploadImageToFirestore();
    }
  }

  // TAMBAHKAN METHOD INI:
  Future<void> _deleteProfilePhoto() async {
    if (_currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Foto Profil'),
        content: const Text('Apakah Anda yakin ingin menghapus foto profil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_currentUser!.uid)
                    .update({'photoBase64': FieldValue.delete()});

                setState(() {
                  _selectedImage = null;
                  _userData.remove('photoBase64');
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Foto profil berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus foto: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        _userData['nama']?.toString() ?? _currentUser?.displayName ?? 'User';

    final userEmail =
        _userData['email']?.toString() ??
        _currentUser?.email ??
        'Email tidak tersedia';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingScreen()
            : Column(
                children: [
                  // Header dengan waktu dan back
                  _buildHeader(context),

                  // Logo dan user info
                  _buildUserProfile(userName, userEmail),

                  // Stats section
                  _buildStatsSection(),

                  // Menu options
                  Expanded(child: _buildMenuOptions(context)),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F5586)),
          ),
          SizedBox(height: 16),
          Text('Memuat data profil...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Header dengan waktu dan back button
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
              color: const Color(0xFF2F5586).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF2F5586),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _currentTime,
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

  // User profile dengan avatar (TANPA PHONE NUMBER)
  Widget _buildUserProfile(String userName, String userEmail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Logo GoRent
          const Column(
            children: [
              Text(
                'GoRent',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
              SizedBox(height: 2),
              Divider(
                color: Color(0xFF2F5586),
                thickness: 2,
                indent: 100,
                endIndent: 100,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Di dalam Stack di _buildUserProfile():
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2F5586), width: 3),
                ),
                child: _buildUserAvatar(), // <- METHOD YANG SUDAH DIPERBARUI
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // GANTI INI:
                    // _showEditPhotoDialog(context);
                    // MENJADI:
                    _showPhotoOptionsDialog(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F5586),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User info
          Column(
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    // TAMPILKAN LOADING JIKA SEDANG UPLOAD
    if (_isUploading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F5586)),
        ),
      );
    }

    // CEK FOTO YANG BARU DIPILIH
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      );
    }

    // CEK FOTO BASE64 DARI FIRESTORE
    if (_userData.containsKey('photoBase64') &&
        _userData['photoBase64'] != null &&
        (_userData['photoBase64'] as String).isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.memory(
            base64Decode(_userData['photoBase64']),
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
        );
      } catch (e) {
        print('Error loading base64 image: $e');
      }
    }

    // CEK FOTO URL DARI FIREBASE AUTH
    if (_currentUser?.photoURL != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(_currentUser!.photoURL!),
        radius: 60,
      );
    }

    final initials = _getInitials(_userData['nama'] ?? 'User');
    return CircleAvatar(
      backgroundColor: const Color(0xFF2F5586),
      radius: 60,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return 'U';
  }

  // Stats section
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildProfileStatCard(
              'Total Kendaraan',
              _totalKendaraan.toString(),
              Icons.directions_car,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildProfileStatCard(
              'Sewa Aktif',
              _sewaAktif.toString(),
              Icons.timer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildProfileStatCard(
              'Sewa Selesai',
              _sewaSelesai.toString(),
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2F5586).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2F5586), size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF103667),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Menu options
  Widget _buildMenuOptions(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Edit Profil',
        'icon': Icons.edit,
        'color': const Color(0xFF2F5586),
        'onTap': () {
          _showEditProfileDialog(context);
        },
      },
      {
        'title': 'Riwayat Transaksi',
        'icon': Icons.history,
        'color': const Color(0xFF4CAF50),
        'onTap': () {
          Navigator.pushNamed(context, '/renter/riwayat_transaksi');
        },
      },
      {
        'title': 'Kendaraan Saya',
        'icon': Icons.directions_car,
        'color': const Color(0xFF2196F3),
        'onTap': () {
          Navigator.pushNamed(context, '/renter/daftar_rental');
        },
      },
      {
        'title': 'Bantuan & FAQ',
        'icon': Icons.help,
        'color': const Color(0xFFFF9800),
        'onTap': () {
          _showHelpDialog(context);
        },
      },
      {
        'title': 'Tentang Aplikasi',
        'icon': Icons.info,
        'color': const Color(0xFF9C27B0),
        'onTap': () {
          Navigator.pushNamed(context, '/about_page');
        },
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ...menuItems.map((item) => _buildMenuItem(item)),

        const SizedBox(height: 20),

        // Logout button
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                _showLogoutDialog(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: item['onTap'],
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF103667),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bottom Navigation Bar
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
        currentIndex: 5, // Profil aktif (index 5 dari 6 menu)
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
            icon: Icon(Icons.list_alt_outlined),
            label: 'Daftar',
          ),
          BottomNavigationBarItem(
            // <-- MENU CHAT BARU
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(
                context,
                '/renter/dashboard_renter',
              );
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/renter/input_data');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/renter/daftar_rental');
              break;
            case 3: // <-- MENU CHAT BARU
              Navigator.pushReplacementNamed(context, '/renter/chat_renter');
              break;
            case 4:
              Navigator.pushReplacementNamed(
                context,
                '/renter/riwayat_transaksi',
              );
              break;
            case 5:
              // Already on profile
              break;
          }
        },
      ),
    );
  }

  // Logout dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              color: Color(0xFF103667),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Edit Profile Dialog (SEDERHANA - hanya nama)
  void _showEditProfileDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: _userData['nama'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Profil',
            style: TextStyle(
              color: Color(0xFF103667),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Email tidak dapat diubah untuk keamanan akun',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama tidak boleh kosong'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Update data di Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .set({
                        'nama': nameController.text,
                        'email': _currentUser!.email,
                        'uid': _currentUser!.uid,
                        'updatedAt': FieldValue.serverTimestamp(),
                        'createdAt':
                            _userData['createdAt'] ??
                            FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));

                  // Reload data
                  await _loadUserData();

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  print('Error updating profile: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal memperbarui profil'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5586),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Ubah Foto Profil',
            style: TextStyle(
              color: Color(0xFF103667),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt, size: 60, color: Color(0xFF2F5586)),
              SizedBox(height: 16),
              Text(
                'Fitur upload foto profil akan segera tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Bantuan & FAQ',
            style: TextStyle(
              color: Color(0xFF103667),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFAQItem(
                  'Bagaimana cara menambahkan kendaraan?',
                  'Pilih menu "Input Data" di bawah, lalu isi formulir data kendaraan.',
                ),
                const SizedBox(height: 12),
                _buildFAQItem(
                  'Bagaimana melihat kendaraan saya?',
                  'Pilih menu "Daftar" untuk melihat semua kendaraan yang telah Anda tambahkan.',
                ),
                const SizedBox(height: 12),
                _buildFAQItem(
                  'Bagaimana melihat riwayat transaksi?',
                  'Pilih menu "Riwayat" untuk melihat semua transaksi penyewaan.',
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Butuh bantuan lebih lanjut?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hubungi kami di: support@gorent.com',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $question',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF103667),
          ),
        ),
        const SizedBox(height: 4),
        Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
