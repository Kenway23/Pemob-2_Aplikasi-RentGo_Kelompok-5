import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DashboardRenter extends StatelessWidget {
  const DashboardRenter({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan waktu
              _buildHeader(context),

              // Welcome Section
              _buildWelcomeSection(context),

              // Stats Cards
              _buildStatsSection(),

              // Riwayat Section
              _buildRiwayatSection(context),

              // Daftar Rental Section
              _buildDaftarRentalSection(context),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Header dengan waktu live
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2F5586).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Color(0xFF2F5586),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('HH:mm').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Welcome Section
  Widget _buildWelcomeSection(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName =
        currentUser?.displayName ??
        currentUser?.email?.split('@').first ??
        'Pengguna';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo GoRent
          Row(
            children: [
              Container(
                width: 8,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5586),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'GoRent',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Welcome dengan nama user
          Text(
            'Halo, $userName!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF103667),
            ),
          ),
          const SizedBox(height: 8),

          // Slogan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2F5586).withOpacity(0.1),
                  const Color(0xFF103667).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ayo Sewakan Kendaraanmu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF103667),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dapatkan penghasilan tambahan dengan menyewakan kendaraan Anda',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/renter/input_data');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5586),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Mulai Sewakan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Stats Section dengan data real dari Firebase
  Widget _buildStatsSection() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return _buildStatsLoading();
    }

    print('DEBUG STATS: User ID: ${currentUser.uid}');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('ownerId', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        print('DEBUG STATS: Snapshot state: ${snapshot.connectionState}');
        print('DEBUG STATS: Snapshot has data: ${snapshot.hasData}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildStatsLoading();
        }

        if (!snapshot.hasData || snapshot.hasError) {
          print('DEBUG STATS: Error atau tidak ada data');
          return _buildStatsPlaceholder();
        }

        final bookings = snapshot.data!.docs;
        print('DEBUG STATS: Jumlah booking ditemukan: ${bookings.length}');

        // Hitung statistik
        int totalSewa = bookings.length;
        int sewaAktif = bookings.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status']?.toString().toLowerCase() ?? '';
          return status == 'active' ||
              status == 'disewa' ||
              status == 'confirmed';
        }).length;

        int sewaSelesai = bookings.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status']?.toString().toLowerCase() ?? '';
          return status == 'completed' || status == 'selesai';
        }).length;

        print(
          'DEBUG STATS: Total: $totalSewa, Aktif: $sewaAktif, Selesai: $sewaSelesai',
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Sewa',
                  totalSewa.toString(),
                  Icons.list_alt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Sewa Aktif',
                  sewaAktif.toString(),
                  Icons.timer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Sewa Selesai',
                  sewaSelesai.toString(),
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Sewa', '...', Icons.list_alt)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Sewa Aktif', '...', Icons.timer)),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Sewa Selesai', '...', Icons.check_circle),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Sewa', '0', Icons.list_alt)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Sewa Aktif', '0', Icons.timer)),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Sewa Selesai', '0', Icons.check_circle),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
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

  // Riwayat Section dengan data dari Firebase
  Widget _buildRiwayatSection(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print('DEBUG RIWAYAT: User belum login');
      return _buildRiwayatPlaceholder(context);
    }

    print('=== DEBUG RIWAYAT ===');
    print('Owner ID yang login: ${currentUser.uid}');
    print('Owner ID yang dicari di bookings: "GZh44pveyHYtJlphpqC9i8RaLQx2"');

    return StreamBuilder<QuerySnapshot>(
      // COBA: Ambil semua data dulu untuk debug
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        print('DEBUG RIWAYAT: ConnectionState: ${snapshot.connectionState}');
        print('DEBUG RIWAYAT: HasError: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('DEBUG RIWAYAT: Error details: ${snapshot.error}');
        }
        print('DEBUG RIWAYAT: HasData: ${snapshot.hasData}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('DEBUG RIWAYAT: Masih loading...');
          return _buildRiwayatLoading(context);
        }

        if (snapshot.hasError) {
          print('DEBUG RIWAYAT: Error snapshot: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          print('DEBUG RIWAYAT: Snapshot tidak punya data');
          return _buildRiwayatPlaceholder(context);
        }

        final bookings = snapshot.data!.docs;
        print(
          'DEBUG RIWAYAT: Jumlah total dokumen di bookings: ${bookings.length}',
        );

        if (bookings.isEmpty) {
          print('DEBUG RIWAYAT: Tidak ada dokumen di collection bookings');
          return _buildRiwayatPlaceholder(context);
        }

        // Filter secara manual di client side
        final userBookings = bookings.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final ownerId = data['ownerId']?.toString();
          print('DEBUG RIWAYAT: Cek dokumen ${doc.id}: ownerId=$ownerId');
          return ownerId == currentUser.uid;
        }).toList();

        print(
          'DEBUG RIWAYAT: Jumlah booking untuk user ini: ${userBookings.length}',
        );

        if (userBookings.isEmpty) {
          print('DEBUG RIWAYAT: User tidak punya booking');
          print('DEBUG RIWAYAT: User ID pencarian: ${currentUser.uid}');

          // Tampilkan semua booking untuk debug
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Terbaru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF103667),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/renter/riwayat_rental',
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFF2F5586),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ DEBUG: Semua booking dalam database (${bookings.length}):',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...bookings.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final isMatch = data['ownerId'] == currentUser.uid;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isMatch ? Colors.green[50] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isMatch ? Colors.green : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking ID: ${doc.id}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Owner ID: ${data['ownerId']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Vehicle: ${data['vehicleName']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Status: ${data['status']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'User ID login: ${currentUser.uid}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              isMatch ? '✓ COCOK' : '✗ TIDAK COCOK',
                              style: TextStyle(
                                color: isMatch ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                    Text(
                      'Login dengan ownerId: ${currentUser.uid}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Sort berdasarkan tanggal terbaru
        userBookings.sort((a, b) {
          final aDate =
              (a.data() as Map<String, dynamic>)['createdAt'] ??
              Timestamp.now();
          final bDate =
              (b.data() as Map<String, dynamic>)['createdAt'] ??
              Timestamp.now();
          return (bDate as Timestamp).compareTo(aDate as Timestamp);
        });

        final booking = userBookings.first;
        final data = booking.data() as Map<String, dynamic>;
        print('DEBUG RIWAYAT: Data yang akan ditampilkan: $data');

        return _buildRiwayatCard(context, data);
      },
    );
  }

  Widget _buildRiwayatCard(BuildContext context, Map<String, dynamic> data) {
    final vehicleName = data['vehicleName']?.toString() ?? 'Kendaraan';
    final status = data['status']?.toString() ?? 'pending';
    final userName = data['userName']?.toString() ?? 'Penyewa';

    // Format tanggal
    String formattedDate = 'Tanggal tidak tersedia';
    if (data['createdAt'] != null) {
      final timestamp = data['createdAt'] as Timestamp;
      formattedDate = DateFormat('dd MMMM yyyy').format(timestamp.toDate());
    }

    // Status styling
    Map<String, dynamic> statusInfo = _getStatusInfo(status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/renter/riwayat_rental');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF2F5586),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/renter/riwayat_rental');
            },
            child: Container(
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
                  // Vehicle Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE7F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildVehicleImage(data),
                  ),
                  const SizedBox(width: 16),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicleName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF103667),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Oleh: $userName',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 14,
                              color: Color(0xFF2F5586),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusInfo['iconColor'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusInfo['text'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusInfo['color'] as Color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // Widget untuk menampilkan gambar kendaraan dari booking
  Widget _buildVehicleImage(Map<String, dynamic> data) {
    if (data.containsKey('vehicleImage') && data['vehicleImage'] != null) {
      try {
        final base64Image = data['vehicleImage'].toString();
        if (base64Image.isNotEmpty) {
          return Image.memory(
            base64.decode(base64Image),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildDefaultVehicleIcon(),
          );
        }
      } catch (e) {
        print('Error loading base64 image: $e');
      }
    }

    return _buildDefaultVehicleIcon();
  }

  Widget _buildDefaultVehicleIcon() {
    return Container(
      color: const Color(0xFFDDE7F2),
      child: const Icon(
        Icons.directions_car,
        color: Color(0xFF2F5586),
        size: 30,
      ),
    );
  }

  Widget _buildRiwayatLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/renter/riwayat_rental');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF2F5586),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                      Container(
                        height: 12,
                        width: 100,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/renter/riwayat_rental');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF2F5586),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
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
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 40, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat penyewaan',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (sisa kode untuk Daftar Rental Section dan fungsi lainnya tetap sama)
  // Daftar Rental Section dengan data dari Firebase
  Widget _buildDaftarRentalSection(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return _buildDaftarRentalPlaceholder(context);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('ownerId', isEqualTo: currentUser.uid)
          .limit(2)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDaftarRentalLoading(context);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildDaftarRentalPlaceholder(context);
        }

        final vehicles = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kendaraan Saya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF103667),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/renter/daftar_rental');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF2F5586),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...vehicles.map((vehicleDoc) {
                final vehicleData = vehicleDoc.data() as Map<String, dynamic>;
                return _buildRentalCard(
                  context: context,
                  vehicleData: vehicleData,
                  vehicleId: vehicleDoc.id,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRentalCard({
    required BuildContext context,
    required Map<String, dynamic> vehicleData,
    required String vehicleId,
  }) {
    final namaKendaraan =
        vehicleData['namaKendaraan']?.toString() ?? 'Kendaraan';
    final merk = vehicleData['merk']?.toString() ?? '';
    final jenis = vehicleData['jenis']?.toString() ?? 'Motor';
    final lokasi = vehicleData['lokasi']?.toString() ?? 'Lokasi tidak tersedia';
    final hargaPerhari = vehicleData['hargaPerhari']?.toString() ?? '0';

    // Handle null untuk totalRental
    final totalRental = vehicleData['totalRental'] ?? 0;
    final totalRentalText = totalRental.toString();

    // Gabungkan merk dan nama kendaraan
    final fullVehicleName = '$merk $namaKendaraan'.trim();

    // Cek booking aktif untuk kendaraan ini
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('vehicleId', isEqualTo: vehicleId)
          .where('status', whereIn: ['pending', 'confirmed', 'active'])
          .snapshots(),
      builder: (context, bookingSnapshot) {
        final hasActiveBooking =
            bookingSnapshot.hasData && bookingSnapshot.data!.docs.isNotEmpty;
        final status = hasActiveBooking ? 'Sedang Disewa' : 'Tersedia';
        final statusColor = hasActiveBooking ? Colors.blue : Colors.green;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
              // Vehicle Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE7F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildVehicleImageFromData(vehicleData),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullVehicleName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF103667),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jenis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // PERBAIKAN: Gunakan string concatenation yang aman
                        Text(
                          '$totalRentalText' + 'x sewa',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            lokasi,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Rp ${_formatRupiah(hargaPerhari)}/hari',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF103667),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // SEE Button
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/renter/detail_rental',
                        arguments: {
                          'vehicleId': vehicleId,
                          'vehicleData': vehicleData,
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F5586),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'SEE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk menampilkan gambar kendaraan dari data vehicle
  Widget _buildVehicleImageFromData(Map<String, dynamic> vehicleData) {
    if (vehicleData.containsKey('fotoBase64') &&
        vehicleData['fotoBase64'] != null) {
      try {
        final base64Image = vehicleData['fotoBase64'].toString();
        if (base64Image.isNotEmpty) {
          return Image.memory(
            base64.decode(base64Image),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildDefaultVehicleIcon(),
          );
        }
      } catch (e) {
        print('Error loading vehicle base64 image: $e');
      }
    }

    return _buildDefaultVehicleIcon();
  }

  Widget _buildDaftarRentalLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kendaraan Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/renter/daftar_rental');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF2F5586),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                      Container(
                        height: 12,
                        width: 100,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarRentalPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kendaraan Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103667),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/renter/daftar_rental');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF2F5586),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
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
                Icon(Icons.directions_car, size: 50, color: Colors.grey[300]),
                const SizedBox(height: 12),
                const Text(
                  'Belum ada kendaraan',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/renter/input_data');
                  },
                  child: const Text(
                    'Tambah Kendaraan Pertama',
                    style: TextStyle(
                      color: Color(0xFF2F5586),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ... (kode _buildDaftarRentalSection dan lainnya)

  // Helper functions
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'disewa':
        return {
          'text': 'Dalam Penyewaan',
          'color': Colors.orange,
          'iconColor': Colors.orange,
        };
      case 'completed':
      case 'selesai':
        return {
          'text': 'Selesai Disewa',
          'color': Colors.green,
          'iconColor': Colors.green,
        };
      case 'pending':
        return {
          'text': 'Menunggu Konfirmasi',
          'color': Colors.orange,
          'iconColor': Colors.orange,
        };
      case 'confirmed':
        return {
          'text': 'Terkonfirmasi',
          'color': Colors.green,
          'iconColor': Colors.green,
        };
      case 'cancelled':
      case 'ditolak':
        return {
          'text': 'Dibatalkan',
          'color': Colors.red,
          'iconColor': Colors.red,
        };
      default:
        return {
          'text': 'Menunggu',
          'color': Colors.grey,
          'iconColor': Colors.grey,
        };
    }
  }

  String _formatRupiah(String value) {
    try {
      final number = int.tryParse(value) ?? 0;
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    } catch (e) {
      return value;
    }
  }

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
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2F5586),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outlined),
            activeIcon: Icon(Icons.add_circle),
            label: 'Input Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Daftar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Navigator.pushNamed(context, '/renter/input_data');
              break;
            case 2:
              Navigator.pushNamed(context, '/renter/daftar_rental');
              break;
            case 3:
              Navigator.pushNamed(context, '/renter/riwayat_chat_renter');
              break;
            case 4:
              Navigator.pushNamed(context, '/renter/riwayat_rental');
              break;
            case 5:
              Navigator.pushNamed(context, '/renter/profil_renter');
              break;
          }
        },
      ),
    );
  }
}
