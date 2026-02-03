import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadUserData();

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
        // Buat user baru jika belum ada
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
            : Column(
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

  // User profile dengan avatar
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

          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2F5586), width: 3),
            ),
            child: _buildUserAvatar(),
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
    // Cek jika user punya photoURL dari Firebase Auth
    if (_currentUser?.photoURL != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(_currentUser!.photoURL!),
        backgroundColor: const Color(0xFFDDE7F2),
      );
    }

    // Cek jika ada foto di Firestore
    if (_userData.containsKey('photoUrl') && _userData['photoUrl'] != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(_userData['photoUrl']),
        backgroundColor: const Color(0xFFDDE7F2),
      );
    }

    // Default avatar dengan inisial nama
    final initials = _getInitials(_userData['nama'] ?? 'User');

    return CircleAvatar(
      backgroundColor: const Color(0xFF2F5586),
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

  // User details section
  Widget _buildUserDetails(String userPhone, String userAddress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Phone number
          if (userPhone.isNotEmpty)
            _buildDetailCard(
              icon: Icons.phone,
              title: 'Nomor Telepon',
              value: userPhone,
              color: const Color(0xFF4CAF50),
            ),

          const SizedBox(height: 12),

          // Address
          if (userAddress.isNotEmpty)
            _buildDetailCard(
              icon: Icons.location_on,
              title: 'Alamat',
              value: userAddress,
              color: const Color(0xFF2196F3),
            ),

          // Jika tidak ada data, tampilkan tombol edit
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

  // Bottom Navigation Bar (PENYEWA VERSION)
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
        currentIndex: 4, // Profil aktif (index 4 dari 5 menu)
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
            icon: Icon(Icons.search_outlined),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
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
              Navigator.pushReplacementNamed(
                context,
                '/penyewa/dashboard_penyewa',
              );
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/penyewa/search_page');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/penyewa/riwayat_chat');
              break;
            case 3:
              Navigator.pushReplacementNamed(
                context,
                '/penyewa/riwayat_transaksi',
              );
              break;
            case 4:
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

  // Edit Profile Dialog
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
                  // Update data di Firestore
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
              child: const Text('Simpan Perubahan'),
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
