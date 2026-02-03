import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gorent/penyewa/riwayat_chat_penyewa.dart';
import 'package:intl/intl.dart';
import 'dart:convert' show base64Decode;
import 'dart:typed_data';
import 'daftar_rental.dart';
import 'profil.dart';
import 'riwayat_booking.dart';
import 'detail.dart';

class DashboardPenyewa extends StatefulWidget {
  const DashboardPenyewa({super.key});

  @override
  State<DashboardPenyewa> createState() => _DashboardPenyewaState();
}

class _DashboardPenyewaState extends State<DashboardPenyewa> {
  final Color primaryBlue = const Color(0xFF2F5586);
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardHome(primaryBlue: primaryBlue),
      const RiwayatTransaksiPenyewa(),
      const DaftarRental(),
      const RiwayatChatPenyewa(),
      const ProfilePenyewa(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Riwayat Rentals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: "Rentals",
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chat",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  final Color primaryBlue;

  const DashboardHome({super.key, required this.primaryBlue});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Stream<QuerySnapshot> _bookingsStream;
  late Stream<QuerySnapshot> _vehiclesStream;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      // Query sederhana tanpa orderBy dulu untuk testing
      _bookingsStream = FirebaseFirestore.instance
          .collection("bookings")
          .where("userId", isEqualTo: userId)
          // .orderBy("createdAt", descending: true) // COMMENT DULU
          .limit(5)
          .snapshots();
    } else {
      _bookingsStream = const Stream.empty();
    }

    // Query untuk vehicles tanpa filter status dulu
    _vehiclesStream = FirebaseFirestore.instance
        .collection("vehicles")
        // .where("status", isEqualTo: "available") // COMMENT DULU
        .limit(3)
        .snapshots();
  }

  String _parseAndFormatHarga(dynamic harga) {
    if (harga == null) return "Rp 0";

    if (harga is String) {
      if (harga.startsWith('Rp')) return harga;

      String cleanHarga = harga
          .replaceAll('.', '')
          .replaceAll(',', '')
          .replaceAll('Rp', '')
          .replaceAll(' ', '')
          .trim();

      try {
        int parsed = int.parse(cleanHarga);
        return "Rp ${NumberFormat().format(parsed)}";
      } catch (e) {
        return "Rp $harga";
      }
    }

    if (harga is int) {
      return "Rp ${NumberFormat().format(harga)}";
    }

    if (harga is double) {
      return "Rp ${NumberFormat().format(harga.toInt())}";
    }

    return "Rp 0";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    return Scaffold(
      backgroundColor: widget.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          color: widget.primaryBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'GoRent',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            /// WHITE PANEL
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// PROFILE SECTION
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String name = "Guest";
                          String email = user?.email ?? "";
                          String role = "penyewa";

                          if (snapshot.hasData &&
                              snapshot.data?.exists == true) {
                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            name = data['nama'] ?? name;
                            email = data['email'] ?? email;
                            role = data['role'] ?? role;
                          }

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: widget.primaryBlue,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Halo, $name!",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: widget.primaryBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          email,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: role == 'admin'
                                                ? Colors.red
                                                : role == 'pemilik'
                                                ? Colors.blue
                                                : Colors.green,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            role.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      /// STATISTICS - PERBAIKAN QUERY
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: "Total Booking",
                              valueStream: userId != null
                                  ? FirebaseFirestore.instance
                                        .collection("bookings")
                                        .where("userId", isEqualTo: userId)
                                        .snapshots()
                                        .map(
                                          (snapshot) =>
                                              snapshot.docs.length.toString(),
                                        )
                                  : Stream.value("0"),
                              color: widget.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              title: "Menunggu",
                              valueStream: userId != null
                                  ? FirebaseFirestore.instance
                                        .collection("bookings")
                                        .where("userId", isEqualTo: userId)
                                        .snapshots()
                                        .map((snapshot) {
                                          // Filter manual di client untuk menghindari index
                                          int pendingCount = 0;
                                          for (var doc in snapshot.docs) {
                                            final data =
                                                doc.data()
                                                    as Map<String, dynamic>;
                                            final status =
                                                data['status']
                                                    ?.toString()
                                                    .toLowerCase() ??
                                                '';
                                            if (status == 'pending' ||
                                                status == 'menunggu') {
                                              pendingCount++;
                                            }
                                          }
                                          return pendingCount.toString();
                                        })
                                  : Stream.value("0"),
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              title: "Selesai",
                              valueStream: userId != null
                                  ? FirebaseFirestore.instance
                                        .collection("bookings")
                                        .where("userId", isEqualTo: userId)
                                        .snapshots()
                                        .map((snapshot) {
                                          // Filter manual di client
                                          int completedCount = 0;
                                          for (var doc in snapshot.docs) {
                                            final data =
                                                doc.data()
                                                    as Map<String, dynamic>;
                                            final status =
                                                data['status']
                                                    ?.toString()
                                                    .toLowerCase() ??
                                                '';
                                            if (status == 'completed' ||
                                                status == 'selesai') {
                                              completedCount++;
                                            }
                                          }
                                          return completedCount.toString();
                                        })
                                  : Stream.value("0"),
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// RIWAYAT BOOKING - PERBAIKAN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Riwayat Booking Terbaru",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.primaryBlue,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const RiwayatTransaksiPenyewa(),
                                ),
                              );
                            },
                            child: Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: widget.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // STREAM UNTUK BOOKINGS - TANPA ORDERBY DULU
                      StreamBuilder<QuerySnapshot>(
                        stream: _bookingsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: widget.primaryBlue,
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            print('Booking Stream Error: ${snapshot.error}');
                            return _buildErrorCard(
                              "Gagal memuat booking",
                              onRetry: () {
                                setState(() {
                                  _initializeStreams();
                                });
                              },
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return _buildEmptyBookingCard();
                          }

                          // Sorting manual di client
                          var docs = snapshot.data!.docs.toList();
                          docs.sort((a, b) {
                            final aData = a.data() as Map<String, dynamic>;
                            final bData = b.data() as Map<String, dynamic>;
                            final aDate = aData['createdAt'] as Timestamp?;
                            final bDate = bData['createdAt'] as Timestamp?;

                            if (aDate == null && bDate == null) return 0;
                            if (aDate == null) return 1;
                            if (bDate == null) return -1;

                            return bDate.compareTo(aDate);
                          });

                          // Ambil 5 teratas
                          var top5 = docs.take(5).toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: top5.length,
                            itemBuilder: (context, index) {
                              final doc = top5[index];
                              final data = doc.data() as Map<String, dynamic>;

                              // Format tanggal
                              String formatDate(Timestamp? timestamp) {
                                if (timestamp == null) return "-";
                                return DateFormat(
                                  'dd/MM/yy',
                                ).format(timestamp.toDate());
                              }

                              // Ambil data
                              final vehicleName =
                                  data['vehicleName'] ?? 'Kendaraan';
                              final bookingCode = data['bookingCode'] ?? 'N/A';
                              final totalPrice = data['totalPrice'] ?? 0;
                              final status = data['status'] ?? 'pending';
                              final paymentStatus =
                                  data['paymentStatus'] ?? 'unpaid';
                              final startDate = data['startDate'] as Timestamp?;
                              final endDate = data['endDate'] as Timestamp?;
                              final totalDays = data['totalDays'] ?? 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[200]!),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: widget.primaryBlue.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.directions_car,
                                      color: widget.primaryBlue,
                                      size: 30,
                                    ),
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicleName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: widget.primaryBlue,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Kode: $bookingCode",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 12,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${formatDate(startDate)} - ${formatDate(endDate)}",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
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
                                              color: _getStatusColor(
                                                status,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              _formatBookingStatus(status),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(status),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getPaymentStatusColor(
                                                paymentStatus,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              _formatPaymentStatus(
                                                paymentStatus,
                                              ),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _getPaymentStatusColor(
                                                  paymentStatus,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _parseAndFormatHarga(totalPrice),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: widget.primaryBlue,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "$totalDays hari",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Navigate to booking detail
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      /// RECOMMENDED VEHICLES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Kendaraan Rekomendasi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.primaryBlue,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DaftarRental(),
                                ),
                              );
                            },
                            child: Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: widget.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // STREAM UNTUK VEHICLES - TANPA FILTER STATUS
                      StreamBuilder<QuerySnapshot>(
                        stream: _vehiclesStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: widget.primaryBlue,
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Center(
                                child: Text(
                                  "Tidak ada kendaraan tersedia",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final doc = snapshot.data!.docs[index];
                              final data = doc.data() as Map<String, dynamic>;

                              final vehicleName =
                                  "${data['merk'] ?? ''} ${data['namaKendaraan'] ?? ''}";
                              final price = data['hargaPerhari'] ?? 0;
                              final location = data['lokasi'] ?? "-";

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[200]!),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: widget.primaryBlue.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.directions_car,
                                      color: widget.primaryBlue,
                                      size: 30,
                                    ),
                                  ),
                                  title: Text(
                                    vehicleName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: widget.primaryBlue,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              location,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _parseAndFormatHarga(price),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: widget.primaryBlue,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Text(
                                        "/hari",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailKendaraanPenyewa(
                                          kendaraanId: doc.id,
                                          vehicleId: doc.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPER WIDGETS
  Widget _buildStatCard({
    required String title,
    required Stream<String> valueStream,
    required Color color,
  }) {
    return StreamBuilder<String>(
      stream: valueStream,
      builder: (context, snapshot) {
        final value = snapshot.data ?? "0";
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getStatIcon(title), color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(String message, {VoidCallback? onRetry}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(color: Colors.red[700], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Coba Lagi",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyBookingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long, color: Colors.grey[400], size: 50),
          const SizedBox(height: 10),
          Text(
            "Belum ada booking",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DaftarRental()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
  IconData _getStatIcon(String title) {
    if (title.contains("Total")) return Icons.receipt_long;
    if (title.contains("Menunggu")) return Icons.pending_actions;
    if (title.contains("Selesai")) return Icons.check_circle;
    return Icons.info;
  }

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
}
