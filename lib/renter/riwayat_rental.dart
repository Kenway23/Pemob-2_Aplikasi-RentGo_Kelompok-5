import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class RiwayatTransaksiOwner extends StatelessWidget {
  const RiwayatTransaksiOwner({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Riwayat Penyewaan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildTransactionList(context),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
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
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Row(
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
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return _buildLoginRequired(context);
    }

    print('=== DEBUG OWNER TRANSAKSI ===');
    print('Owner ID saat ini: ${currentUser.uid}');
    print('Owner ID dari data: "GZh44pveyHYtJlphpqC9i8RaLQx2"');
    print('=============================');

    return StreamBuilder<QuerySnapshot>(
      // PERBAIKAN PENTING: Gunakan ownerId bukan userId
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('ownerId', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        print('DEBUG: ConnectionState: ${snapshot.connectionState}');
        print('DEBUG: HasError: ${snapshot.hasError}');
        print('DEBUG: HasData: ${snapshot.hasData}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryBlue));
        }

        if (snapshot.hasError) {
          print('DEBUG: Error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red[300]),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RiwayatTransaksiOwner(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('DEBUG: Tidak ada booking untuk owner ini');
          return _buildEmptyState();
        }

        final bookings = snapshot.data!.docs;
        print('DEBUG: Jumlah booking ditemukan: ${bookings.length}');

        // Sort berdasarkan tanggal terbaru
        bookings.sort((a, b) {
          final aDate =
              (a.data() as Map<String, dynamic>)['createdAt'] ??
              Timestamp.now();
          final bDate =
              (b.data() as Map<String, dynamic>)['createdAt'] ??
              Timestamp.now();
          return (bDate as Timestamp).compareTo(aDate as Timestamp);
        });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final data = booking.data() as Map<String, dynamic>;
            return _buildTransactionItem(data, booking.id, context);
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(
    Map<String, dynamic> data,
    String bookingId,
    BuildContext context,
  ) {
    final vehicleName = data['vehicleName']?.toString() ?? 'Kendaraan';
    final status = data['status']?.toString() ?? 'pending';
    final totalPrice = data['totalPrice']?.toString() ?? '0';
    final totalDays = data['totalDays']?.toString() ?? '1';
    final bookingCode = data['bookingCode']?.toString() ?? '-';
    final userName = data['userName']?.toString() ?? 'Penyewa';
    final userEmail = data['userEmail']?.toString() ?? '-';

    // Format tanggal
    String formattedDate = 'Tanggal tidak tersedia';
    if (data['createdAt'] != null) {
      final timestamp = data['createdAt'] as Timestamp;
      formattedDate = DateFormat('dd MMMM yyyy').format(timestamp.toDate());
    }

    // Status styling
    Map<String, dynamic> statusInfo = _getStatusInfo(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showBookingDetail(context, data, bookingId, statusInfo);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan kode booking
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking: $bookingCode',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo['bgColor'] as Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusInfo['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Informasi kendaraan
                Row(
                  children: [
                    // Gambar Kendaraan
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE7F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildVehicleImage(data),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Detail Kendaraan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicleName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF103667),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalDays Hari • Rp ${_formatRupiah(totalPrice)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Informasi penyewa
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Color(0xFF2F5586),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Penyewa: $userName',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Tanggal dan arrow
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'disewa':
        return {
          'text': 'Dalam Penyewaan',
          'color': Colors.orange,
          'iconColor': Colors.orange,
          'bgColor': Colors.orange.withOpacity(0.1),
        };
      case 'completed':
      case 'selesai':
        return {
          'text': 'Selesai Disewa',
          'color': Colors.green,
          'iconColor': Colors.green,
          'bgColor': Colors.green.withOpacity(0.1),
        };
      case 'cancelled':
      case 'dibatalkan':
        return {
          'text': 'Dibatalkan',
          'color': Colors.red,
          'iconColor': Colors.red,
          'bgColor': Colors.red.withOpacity(0.1),
        };
      case 'rejected':
      case 'ditolak':
        return {
          'text': 'Ditolak',
          'color': Colors.red,
          'iconColor': Colors.red,
          'bgColor': Colors.red.withOpacity(0.1),
        };
      case 'pending':
        return {
          'text': 'Menunggu Konfirmasi',
          'color': Colors.orange,
          'iconColor': Colors.orange,
          'bgColor': Colors.orange.withOpacity(0.1),
        };
      case 'confirmed':
        return {
          'text': 'Terkonfirmasi',
          'color': Colors.green,
          'iconColor': Colors.green,
          'bgColor': Colors.green.withOpacity(0.1),
        };
      default:
        return {
          'text': 'Menunggu',
          'color': Colors.blue,
          'iconColor': Colors.blue,
          'bgColor': Colors.blue.withOpacity(0.1),
        };
    }
  }

  Widget _buildVehicleImage(Map<String, dynamic> data) {
    if (data.containsKey('vehicleImage') && data['vehicleImage'] != null) {
      try {
        final base64Image = data['vehicleImage'].toString();
        if (base64Image.isNotEmpty) {
          return Image.memory(
            base64.decode(base64Image),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildDefaultImage(),
          );
        }
      } catch (e) {
        print('Error loading base64 image: $e');
      }
    }

    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    return Container(
      color: const Color(0xFFDDE7F2),
      child: const Icon(
        Icons.directions_car,
        color: Color(0xFF2F5586),
        size: 32,
      ),
    );
  }

  void _showBookingDetail(
    BuildContext context,
    Map<String, dynamic> data,
    String bookingId,
    Map<String, dynamic> statusInfo,
  ) {
    // Format tanggal
    String startDate = '-';
    String endDate = '-';
    String createdAt = '-';

    if (data['startDate'] != null) {
      final timestamp = data['startDate'] as Timestamp;
      startDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());
    }

    if (data['endDate'] != null) {
      final timestamp = data['endDate'] as Timestamp;
      endDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());
    }

    if (data['createdAt'] != null) {
      final timestamp = data['createdAt'] as Timestamp;
      createdAt = DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              data['vehicleName'] ?? 'Detail Penyewaan',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF103667),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Kode: ${data['bookingCode'] ?? '-'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusInfo['bgColor'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusInfo['iconColor'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Status: ${statusInfo['text'] as String}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: statusInfo['color'] as Color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Informasi Penyewa
            const Text(
              'Informasi Penyewa:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF103667),
              ),
            ),
            const SizedBox(height: 10),
            _detailRow('Nama:', data['userName']?.toString() ?? '-'),
            _detailRow('Email:', data['userEmail']?.toString() ?? '-'),
            const SizedBox(height: 15),

            // Informasi Penyewaan
            const Text(
              'Informasi Penyewaan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF103667),
              ),
            ),
            const SizedBox(height: 10),
            _detailRow('Durasi:', '${data['totalDays'] ?? 1} hari'),
            _detailRow('Tanggal Mulai:', startDate),
            _detailRow('Tanggal Selesai:', endDate),
            _detailRow(
              'Total Harga:',
              'Rp ${_formatRupiah(data['totalPrice']?.toString() ?? '0')}',
            ),
            _detailRow(
              'Lokasi Penjemputan:',
              data['pickupLocation']?.toString() ?? '-',
            ),
            _detailRow(
              'Metode Pembayaran:',
              data['paymentMethod']?.toString() ?? '-',
            ),
            _detailRow(
              'Status Pembayaran:',
              data['paymentStatus']?.toString() ?? '-',
            ),
            _detailRow('Catatan:', data['notes']?.toString() ?? '-'),
            _detailRow('Dibuat pada:', createdAt),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.car_rental, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Belum ada penyewaan",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Belum ada yang menyewa kendaraan Anda",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Silakan Login",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Anda perlu login sebagai pemilik kendaraan",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        currentIndex: 4,
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          if (index == 4) return;

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
            case 3:
              Navigator.pushReplacementNamed(
                context,
                '/renter/riwayat_chat_renter',
              );
              break;
            case 5:
              Navigator.pushReplacementNamed(context, '/renter/profil_renter');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Kendaraan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
