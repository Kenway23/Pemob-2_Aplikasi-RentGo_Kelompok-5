import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class ProfilePenyewa extends StatefulWidget {
  const ProfilePenyewa({super.key});

  @override
  State<ProfilePenyewa> createState() => _ProfilePenyewaState();
}

class _ProfilePenyewaState extends State<ProfilePenyewa> {
  final Color primaryBlue = const Color(0xFF2F5586);
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  String _currentTime = '';
  Timer? _timer;
  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadUserData();

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
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      _currentTime = '$hour:$minute';
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
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set({
              'nama': _currentUser!.displayName ?? 'User',
              'email': _currentUser!.email ?? '',
              'uid': _currentUser!.uid,
              'role': 'penyewa',
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        setState(() {
          _userData = {
            'nama': _currentUser!.displayName ?? 'User',
            'email': _currentUser!.email ?? '',
            'role': 'penyewa',
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70, // Sedikit dikurangi untuk ukuran file lebih kecil
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Tampilkan dialog konfirmasi
        _showImageConfirmationDialog();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_currentUser == null || _selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Baca file sebagai bytes
      final bytes = await _selectedImage!.readAsBytes();

      // Konversi ke base64
      String base64Image = base64Encode(bytes);

      // Tambahkan prefix (optional, bisa disesuaikan dengan format yang diinginkan)
      final String imageType = _selectedImage!.path
          .split('.')
          .last
          .toLowerCase();
      final String mimeType = imageType == 'png' ? 'png' : 'jpeg';
      final String base64WithPrefix =
          'data:image/$mimeType;base64,$base64Image';

      // Simpan ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
            'photoBase64': base64WithPrefix,
            'photoUpdatedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update user data
      await _loadUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupload foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
        _selectedImage = null;
      });
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

  void _showImageConfirmationDialog() {
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2F5586), width: 2),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gunakan foto ini sebagai profil?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Foto akan disimpan di database sebagai teks',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedImage = null;
                });
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _uploadProfileImage();
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF2F5586)),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF2F5586),
                ),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text('Batal', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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

    final userPhone =
        _userData['phone']?.toString() ??
        _userData['telepon']?.toString() ??
        _userData['noTelp']?.toString() ??
        '';

    final userAddress =
        _userData['address']?.toString() ??
        _userData['alamat']?.toString() ??
        '';

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingScreen()
            : Stack(
                children: [
                  Column(
                    children: [
                      // Header dengan waktu dan back
                      _buildHeader(context),

                      // Logo dan user info
                      _buildUserProfile(userName, userEmail),

                      // User details section
                      _buildUserDetails(userPhone, userAddress),

                      // Menu options
                      Expanded(child: _buildMenuOptions(context)),
                    ],
                  ),

                  // Loading overlay untuk upload gambar
                  if (_isUploadingImage) _buildUploadingOverlay(),
                ],
              ),
      ),
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

  Widget _buildUploadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Menyimpan foto...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
              onPressed: () {
                // Ganti dengan halaman yang ingin Anda tuju
                // Misalnya ke dashboard
                Navigator.pushReplacementNamed(
                  context,
                  '/penyewa/dashboard_penyewa',
                );
              },
              padding: EdgeInsets.zero,
            ),
          ),
          // ... sisa kode waktu tetap
        ],
      ),
    );
  }

  Widget _buildUserProfile(String userName, String userEmail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
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

          // Avatar dengan edit button
          Stack(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2F5586), width: 3),
                ),
                child: _buildUserAvatar(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F5586),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

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
    // Cek jika ada fotoBase64
    if (_userData['photoBase64'] != null &&
        _userData['photoBase64'].isNotEmpty) {
      try {
        String base64String = _userData['photoBase64'];

        // Handle base64 string dengan atau tanpa prefix
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        return ClipOval(
          child: Image.memory(
            base64Decode(base64String),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading base64 image: $error');
              return _buildDefaultAvatar();
            },
          ),
        );
      } catch (e) {
        print('Error decoding base64 image: $e');
        return _buildDefaultAvatar();
      }
    }

    // Cek jika ada photoUrl (fallback jika ada)
    if (_userData['photoUrl'] != null && _userData['photoUrl'].isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _userData['photoUrl'],
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF2F5586),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        ),
      );
    }

    // Default avatar
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    final initials = _getInitials(_userData['nama'] ?? 'User');

    return CircleAvatar(
      backgroundColor: const Color(0xFF2F5586),
      radius: 70,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 48,
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

  Widget _buildUserDetails(String userPhone, String userAddress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          if (userPhone.isNotEmpty)
            _buildDetailCard(
              icon: Icons.phone,
              title: 'Nomor Telepon',
              value: userPhone,
              color: const Color(0xFF4CAF50),
            ),

          const SizedBox(height: 12),

          if (userAddress.isNotEmpty)
            _buildDetailCard(
              icon: Icons.location_on,
              title: 'Alamat',
              value: userAddress,
              color: const Color(0xFF2196F3),
            ),

          if (userPhone.isEmpty && userAddress.isEmpty)
            GestureDetector(
              onTap: () {
                _showEditProfileDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5586).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2F5586).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 16, color: Color(0xFF2F5586)),
                    SizedBox(width: 8),
                    Text(
                      'Lengkapi Data Profil',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2F5586),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF103667),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          Navigator.pushNamed(context, '/penyewa/riwayat_transaksi');
        },
      },
      {
        'title': 'Riwayat Chat',
        'icon': Icons.chat,
        'color': const Color(0xFF2196F3),
        'onTap': () {
          Navigator.pushNamed(context, '/penyewa/riwayat_chat');
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

  void _showEditProfileDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: _userData['nama'] ?? '',
    );
    final TextEditingController phoneController = TextEditingController(
      text:
          _userData['phone'] ??
          _userData['telepon'] ??
          _userData['noTelp'] ??
          '',
    );
    final TextEditingController addressController = TextEditingController(
      text: _userData['address'] ?? _userData['alamat'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Foto profil dengan edit button
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Ubah Foto Profil'),
                                  content: const Text('Ubah foto profil?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Ya'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (result == true) {
                              Navigator.pop(context); // Tutup dialog edit
                              _showImagePickerOptions();
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2F5586),
                                width: 2,
                              ),
                            ),
                            child: _buildUserAvatar(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Ubah Foto Profil'),
                                    content: const Text('Ubah foto profil?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Ya'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (result == true) {
                                Navigator.pop(context); // Tutup dialog edit
                                _showImagePickerOptions();
                              }
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F5586),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap untuk ganti foto',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 3,
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
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_currentUser!.uid)
                          .set({
                            'nama': nameController.text,
                            'phone': phoneController.text,
                            'address': addressController.text,
                            'email': _currentUser!.email,
                            'uid': _currentUser!.uid,
                            'role': 'penyewa',
                            'updatedAt': FieldValue.serverTimestamp(),
                            'createdAt':
                                _userData['createdAt'] ??
                                FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));

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
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            );
          },
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
                  'Bagaimana cara menyewa kendaraan?',
                  'Pilih menu "Cari" di bawah, lalu cari kendaraan yang sesuai kebutuhan Anda.',
                ),
                const SizedBox(height: 12),
                _buildFAQItem(
                  'Bagaimana melihat riwayat penyewaan?',
                  'Pilih menu "Riwayat" untuk melihat semua transaksi penyewaan yang telah dilakukan.',
                ),
                const SizedBox(height: 12),
                _buildFAQItem(
                  'Bagaimana menghubungi pemilik kendaraan?',
                  'Pilih menu "Chat" untuk berkomunikasi langsung dengan pemilik kendaraan.',
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
