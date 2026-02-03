import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Import halaman chat dan detail
import 'chat_penyewa.dart'; // Pastikan import ini sesuai
import 'detail.dart';

class RiwayatTransaksiPenyewa extends StatefulWidget {
  const RiwayatTransaksiPenyewa({super.key});

  @override
  State<RiwayatTransaksiPenyewa> createState() =>
      _RiwayatTransaksiPenyewaState();
}

class _RiwayatTransaksiPenyewaState extends State<RiwayatTransaksiPenyewa> {
  final Color primaryBlue = const Color(0xFF2F5586);
  String _selectedFilter = 'semua';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Riwayat Booking",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // FILTER CHIPS
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'semua'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Menunggu', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Aktif', 'active'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Selesai', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dibatalkan', 'cancelled'),
                ],
              ),
            ),
          ),

          // LIST RIWAYAT BOOKING
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("bookings")
                  .where("userId", isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Filter dan sort data
                var allDocs = snapshot.data!.docs;

                // Filter berdasarkan status yang dipilih
                List<QueryDocumentSnapshot> filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status']?.toString().toLowerCase() ?? '';

                  if (_selectedFilter == 'semua') return true;
                  if (_selectedFilter == 'pending')
                    return status == 'pending' || status == 'menunggu';
                  if (_selectedFilter == 'active')
                    return status == 'active' || status == 'aktif';
                  if (_selectedFilter == 'completed')
                    return status == 'completed' || status == 'selesai';
                  if (_selectedFilter == 'cancelled')
                    return status == 'cancelled' || status == 'dibatalkan';

                  return true;
                }).toList();

                // Sorting manual berdasarkan createdAt (descending)
                filteredDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aDate = aData['createdAt'] as Timestamp?;
                  final bDate = bData['createdAt'] as Timestamp?;

                  if (aDate == null && bDate == null) return 0;
                  if (aDate == null) return 1;
                  if (bDate == null) return -1;

                  return bDate.compareTo(aDate);
                });

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      "Tidak ada booking dengan status '${_getFilterLabel(_selectedFilter)}'",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return _buildBookingCard(data, doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      backgroundColor: Colors.white,
      selectedColor: primaryBlue,
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? primaryBlue : Colors.grey[300]!,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> data, String bookingId) {
    // Format harga
    String formatPrice(dynamic price) {
      if (price == null) return "Rp 0";
      if (price is String) {
        if (price.startsWith('Rp')) return price;
        try {
          int parsed = int.parse(price.replaceAll(RegExp(r'[^0-9]'), ''));
          return "Rp ${NumberFormat().format(parsed)}";
        } catch (e) {
          return "Rp $price";
        }
      }
      if (price is int || price is double) {
        return "Rp ${NumberFormat().format(price)}";
      }
      return "Rp 0";
    }

    // Format tanggal
    String formatDate(Timestamp? timestamp) {
      if (timestamp == null) return "-";
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
    }

    String formatDateShort(Timestamp? timestamp) {
      if (timestamp == null) return "-";
      return DateFormat('dd/MM/yy').format(timestamp.toDate());
    }

    // Ambil data
    final vehicleName = data['vehicleName'] ?? 'Kendaraan';
    final bookingCode = data['bookingCode'] ?? 'N/A';
    final totalPrice = data['totalPrice'] ?? 0;
    final status = data['status'] ?? 'pending';
    final paymentStatus = data['paymentStatus'] ?? 'unpaid';
    final startDate = data['startDate'] as Timestamp?;
    final endDate = data['endDate'] as Timestamp?;
    final totalDays = data['totalDays'] ?? 0;
    final units = data['units'] ?? 1;
    final createdAt = data['createdAt'] as Timestamp?;
    final pickupLocation = data['pickupLocation'] ?? '-';
    final ownerId = data['ownerId'] ?? '';
    final ownerName = data['ownerName'] ?? 'Pemilik';
    final vehicleId = data['vehicleId'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          // Navigasi ke detail booking
          _navigateToDetail(context, bookingId, data);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER: Booking Code dan Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Kode: $bookingCode",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatBookingStatus(status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // VEHICLE INFO
              Text(
                vehicleName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // RENTAL PERIOD
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${formatDateShort(startDate)} - ${formatDateShort(endDate)} ($totalDays hari)",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // UNITS AND LOCATION
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$units unit",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pickupLocation,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // PAYMENT STATUS AND PRICE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(
                        paymentStatus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatPaymentStatus(paymentStatus),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getPaymentStatusColor(paymentStatus),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatPrice(totalPrice),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      Text(
                        "Dibuat: ${formatDate(createdAt)}",
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ACTION BUTTONS - DIPERBAIKI
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // ✅ FUNGSI CHAT DIPERBAIKI
                        _startChatFromBooking(context, data);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBlue,
                        side: BorderSide(color: primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat, size: 16),
                          SizedBox(width: 4),
                          Text("Chat"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // ✅ FUNGSI DETAIL DIPERBAIKI
                        _navigateToDetail(context, bookingId, data);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility, size: 16),
                          SizedBox(width: 4),
                          Text("Detail"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FUNGSI UNTUK MEMULAI CHAT DARI BOOKING
  Future<void> _startChatFromBooking(
    BuildContext context,
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final ownerId = bookingData['ownerId']?.toString();
      final ownerName = bookingData['ownerName']?.toString() ?? 'Pemilik';
      final vehicleId = bookingData['vehicleId']?.toString() ?? '';
      final vehicleName = bookingData['vehicleName']?.toString() ?? 'Kendaraan';

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silakan login untuk chat")),
        );
        return;
      }

      if (ownerId == null || ownerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Informasi pemilik tidak tersedia")),
        );
        return;
      }

      // Buat chatRoomId yang konsisten dari kedua user IDs
      final List<String> sortedIds = [currentUser.uid, ownerId]..sort();
      final chatRoomId = 'chat_${sortedIds[0]}_${sortedIds[1]}';

      final chatRoomsRef = FirebaseFirestore.instance.collection('chatRooms');
      final doc = await chatRoomsRef.doc(chatRoomId).get();

      if (!doc.exists) {
        // Buat chat room baru
        await chatRoomsRef.doc(chatRoomId).set({
          'participants': [currentUser.uid, ownerId],
          'participantNames': {
            currentUser.uid: currentUser.displayName ?? 'User',
            ownerId: ownerName,
          },
          'vehicleId': vehicleId,
          'vehicleName': vehicleName,
          'lastMessage': '',
          'lastMessageTime': Timestamp.now(),
          'createdAt': Timestamp.now(),
          'unreadCount': {currentUser.uid: 0, ownerId: 0},
        });
      }

      // Navigasi ke halaman chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId,
            otherUserId: ownerId,
            otherUserName: ownerName,
            vehicleId: vehicleId,
            vehicleName: vehicleName,
          ),
        ),
      );
    } catch (e) {
      print("Error starting chat from booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memulai chat: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ FUNGSI UNTUK NAVIGASI KE DETAIL BOOKING
  void _navigateToDetail(
    BuildContext context,
    String bookingId,
    Map<String, dynamic> data,
  ) {
    // Sementara tampilkan dialog sederhana
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detail Booking - ${data['bookingCode']}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Kendaraan: ${data['vehicleName']}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Kode: ${data['bookingCode']}"),
              Text("Status: ${_formatBookingStatus(data['status'])}"),
              Text(
                "Pembayaran: ${_formatPaymentStatus(data['paymentStatus'])}",
              ),
              Text("Unit: ${data['units']}"),
              Text("Total Hari: ${data['totalDays']}"),
              Text(
                "Total: Rp ${NumberFormat().format(data['totalPrice'] ?? 0)}",
              ),
              Text("Lokasi: ${data['pickupLocation']}"),
              if (data['notes'] != null && data['notes'].toString().isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Catatan:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(data['notes'].toString()),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );

    // Atau jika sudah punya halaman detail booking:
    /*
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailBookingScreen(
          bookingId: bookingId,
          bookingData: data,
        ),
      ),
    );
    */
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Belum ada riwayat booking",
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
              "Mulai rental kendaraan favorit Anda dan lihat riwayat booking di sini",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Cari Kendaraan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // HELPER FUNCTIONS
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'selesai':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'menunggu':
        return Colors.orange;
      case 'cancelled':
      case 'dibatalkan':
        return Colors.red;
      case 'active':
      case 'aktif':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatBookingStatus(String status) {
    final statusMap = {
      'pending': 'Menunggu',
      'confirmed': 'Dikonfirmasi',
      'active': 'Aktif',
      'completed': 'Selesai',
      'cancelled': 'Dibatalkan',
      'dibatalkan': 'Dibatalkan',
      'selesai': 'Selesai',
      'menunggu': 'Menunggu',
      'aktif': 'Aktif',
    };

    return statusMap[status.toLowerCase()] ?? status;
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'lunas':
        return Colors.green;
      case 'unpaid':
      case 'belum_bayar':
        return Colors.orange;
      case 'failed':
      case 'gagal':
        return Colors.red;
      case 'pending':
      case 'menunggu':
        return Colors.blue;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatPaymentStatus(String paymentStatus) {
    final paymentMap = {
      'unpaid': 'Belum Bayar',
      'paid': 'Lunas',
      'pending': 'Menunggu',
      'failed': 'Gagal',
      'refunded': 'Dikembalikan',
      'belum_bayar': 'Belum Bayar',
      'lunas': 'Lunas',
      'gagal': 'Gagal',
    };

    return paymentMap[paymentStatus.toLowerCase()] ?? paymentStatus;
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'semua':
        return 'Semua';
      case 'pending':
        return 'Menunggu';
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return filter;
    }
  }
}
