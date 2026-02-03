import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert' show base64Decode;
import 'search_page.dart';
import 'daftar_rental.dart';
import 'profil.dart';
import 'riwayat_transaksi.dart';

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
      const SearchPage(),
      const DaftarRental(),
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Bookings",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  final Color primaryBlue;

  const DashboardHome({super.key, required this.primaryBlue});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Column(
        children: [
          const SizedBox(height: 40),

          /// HEADER DENGAN LOGO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        Icons.two_wheeler,
                        color: primaryBlue,
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
                  onPressed: () {
                    // Notification action
                  },
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

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
                        String name = "User";
                        String email = user?.email ?? "";
                        String role = "penyewa";
                        String? photoBase64;

                        if (snapshot.hasData && snapshot.data?.exists == true) {
                          var data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          name = data['nama'] ?? name;
                          email = data['email'] ?? email;
                          role = data['role'] ?? role;
                          photoBase64 = data['photoBase64'];
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
                                // PROFILE PICTURE
                                if (photoBase64 != null &&
                                    photoBase64.isNotEmpty)
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: primaryBlue,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.memory(
                                        base64Decode(photoBase64),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                else
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: primaryBlue,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),

                                const SizedBox(width: 15),

                                // USER INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hello, $name",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: primaryBlue,
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
                                          color: _getRoleColor(role),
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

                    /// STATISTICS CARDS
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.receipt_long,
                            title: "Total Bookings",
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
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.pending_actions,
                            title: "Pending",
                            valueStream: userId != null
                                ? FirebaseFirestore.instance
                                      .collection("bookings")
                                      .where("userId", isEqualTo: userId)
                                      .where("status", isEqualTo: "pending")
                                      .snapshots()
                                      .map(
                                        (snapshot) =>
                                            snapshot.docs.length.toString(),
                                      )
                                : Stream.value("0"),
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// RECENT BOOKINGS SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Bookings",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RiwayatTransaksiPenyewa(),
                              ),
                            );
                          },
                          child: Text(
                            "View All",
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // STREAM UNTUK BOOKINGS
                    StreamBuilder<QuerySnapshot>(
                      stream: userId != null
                          ? FirebaseFirestore.instance
                                .collection("bookings")
                                .where("userId", isEqualTo: userId)
                                .orderBy("createdAt", descending: true)
                                .limit(3)
                                .snapshots()
                          : null,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2F5586),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: Colors.grey[400],
                                  size: 50,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "No bookings yet",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to search page
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Rent Now",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;

                            // Format tanggal
                            String formatDate(Timestamp? timestamp) {
                              if (timestamp == null) return "-";
                              return DateFormat(
                                'MMM dd, yyyy',
                              ).format(timestamp.toDate());
                            }

                            // Format currency
                            String formatCurrency(dynamic amount) {
                              if (amount == null) return "Rp 0";
                              final num = amount is int
                                  ? amount
                                  : (amount is double ? amount.toInt() : 0);
                              return "Rp ${NumberFormat().format(num)}";
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: primaryBlue.withOpacity(0.1),
                                    image: data['vehicleImage'] != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              data['vehicleImage'],
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: data['vehicleImage'] == null
                                      ? Icon(
                                          _getVehicleIcon(data['vehicleName']),
                                          color: primaryBlue,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  data['vehicleName'] ?? "Unknown Vehicle",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: primaryBlue,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${formatDate(data['startDate'] as Timestamp?)} - ${formatDate(data['endDate'] as Timestamp?)}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        // Status Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              data['status'] ?? '',
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            _formatStatus(
                                              data['status'] ?? 'pending',
                                            ),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(
                                                data['status'] ?? '',
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Payment Status Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPaymentStatusColor(
                                              data['paymentStatus'] ?? '',
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            _formatPaymentStatus(
                                              data['paymentStatus'] ?? 'unpaid',
                                            ),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getPaymentStatusColor(
                                                data['paymentStatus'] ?? '',
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
                                      formatCurrency(data['totalPrice']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${data['totalDays'] ?? 0} days",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Navigate to booking detail
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => DetailBookingPenyewa(bookingId: doc.id),
                                  //   ),
                                  // );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    /// RECOMMENDED VEHICLES SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recommended Vehicles",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to vehicles page
                          },
                          child: Text(
                            "See All",
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // STREAM UNTUK RECOMMENDED VEHICLES
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("vehicles")
                          .limit(3)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2F5586),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Center(
                              child: Text(
                                "No vehicles available",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: primaryBlue.withOpacity(0.1),
                                  ),
                                  child: Icon(
                                    data['jenis'] == 'Mobil'
                                        ? Icons.directions_car
                                        : Icons.two_wheeler,
                                    color: primaryBlue,
                                    size: 30,
                                  ),
                                ),
                                title: Text(
                                  "${data['merk']} ${data['namaKendaraan']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: primaryBlue,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            data['lokasi'] ?? "-",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Plat: ${data['plat'] ?? '-'} • Tahun: ${data['tahun'] ?? '-'}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Rp ${NumberFormat().format(data['hargaPerhari'] ?? 0)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "/day",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Navigate to vehicle detail
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => DetailKendaraanPenyewa(vehicleId: doc.id),
                                  //   ),
                                  // );
                                },
                              ),
                            );
                          }).toList(),
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
    );
  }

  // Helper Widget untuk Stat Card
  Widget _buildStatCard({
    required IconData icon,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
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

  // Helper functions
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'selesai':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'lunas':
        return Colors.green;
      case 'unpaid':
      case 'belum bayar':
        return Colors.orange;
      case 'failed':
      case 'gagal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'pemilik':
        return Colors.blue;
      case 'penyewa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getVehicleIcon(String? vehicleName) {
    if (vehicleName?.toLowerCase().contains("vespa") == true ||
        vehicleName?.toLowerCase().contains("motor") == true) {
      return Icons.two_wheeler;
    } else {
      return Icons.directions_car;
    }
  }

  String _formatStatus(String status) {
    return status.toUpperCase();
  }

  String _formatPaymentStatus(String paymentStatus) {
    return paymentStatus.toUpperCase();
  }
}
