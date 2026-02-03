import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:gorent/penyewa/chat_penyewa.dart';
import 'package:gorent/penyewa/riwayat_booking.dart';

class DetailKendaraanPenyewa extends StatefulWidget {
  final String vehicleId;
  final String kendaraanId;

  const DetailKendaraanPenyewa({
    super.key,
    required this.vehicleId,
    required this.kendaraanId,
  });

  @override
  State<DetailKendaraanPenyewa> createState() => _DetailKendaraanPenyewaState();
}

class _DetailKendaraanPenyewaState extends State<DetailKendaraanPenyewa> {
  final Color primaryBlue = const Color(0xFF2F5586);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  int selectedDays = 1;
  int selectedUnits = 1;
  late Future<Map<String, dynamic>?> vehicleData;
  late Future<DocumentSnapshot> ownerData;
  String? ownerId;
  String? ownerName;
  int availableUnits = 1;
  String vehicleName = ""; // Variabel untuk menyimpan nama kendaraan

  @override
  void initState() {
    super.initState();
    vehicleData = _fetchVehicleData();
  }

  Future<Map<String, dynamic>?> _fetchVehicleData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Simpan ownerId
        ownerId = data['ownerId'];

        // Ambil jumlah unit tersedia
        availableUnits = data['jumlahUnit'] ?? 1;

        // Simpan nama kendaraan
        vehicleName = "${data['merk']} ${data['namaKendaraan']}";

        // Fetch owner data
        if (ownerId != null) {
          ownerData = FirebaseFirestore.instance
              .collection('users')
              .doc(ownerId)
              .get();

          ownerData.then((snapshot) {
            if (snapshot.exists) {
              final ownerDataMap = snapshot.data() as Map<String, dynamic>;
              ownerName = ownerDataMap['nama'] ?? 'GoRent Owner';
            }
          });
        }
        return data;
      }
      return null;
    } catch (e) {
      print("Error fetching vehicle data: $e");
      return null;
    }
  }

  // ===========================
  // FUNCTION CHAT KE PEMILIK - DIPERBAIKI
  // ===========================
  Future<void> _startChatWithOwner(BuildContext context) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silakan login untuk chat")),
        );
        return;
      }

      if (ownerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Informasi pemilik tidak tersedia")),
        );
        return;
      }

      // ✅ SOLUSI: Buat chatRoomId yang konsisten dari kedua user IDs
      final List<String> sortedIds = [currentUser.uid, ownerId!]..sort();
      final chatRoomId = 'chat_${sortedIds[0]}_${sortedIds[1]}';

      final chatRoomsRef = FirebaseFirestore.instance.collection('chatRooms');
      final doc = await chatRoomsRef.doc(chatRoomId).get();

      if (!doc.exists) {
        // Buat chat room baru
        await chatRoomsRef.doc(chatRoomId).set({
          'participants': [currentUser.uid, ownerId],
          'participantNames': {
            currentUser.uid: currentUser.displayName ?? 'User',
            ownerId!: ownerName ?? 'Owner',
          },
          'vehicleId': widget.vehicleId,
          'vehicleName': vehicleName,
          'lastMessage': '',
          'lastMessageTime': Timestamp.now(),
          'createdAt': Timestamp.now(),
          'unreadCount': {currentUser.uid: 0, ownerId!: 0},
        });
      }

      // ✅ NAVIGASI KE HALAMAN CHAT dengan SEMUA PARAMETER
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId,
            otherUserId: ownerId!,
            otherUserName: ownerName ?? 'Owner',
            vehicleId: widget.vehicleId,
            vehicleName: vehicleName, // ✅ Kirim vehicleName
          ),
        ),
      );
    } catch (e) {
      print("Error starting chat: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memulai chat: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ... (sisa kode booking dan UI tetap sama)
  // ===========================
  // FUNCTION BOOKING FIREBASE
  // ===========================
  Future<void> _createBooking(
    BuildContext context,
    Map<String, dynamic> vehicleData,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silakan login untuk booking")),
        );
        return;
      }

      // Cek apakah unit masih tersedia
      if (selectedUnits > availableUnits) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hanya $availableUnits unit tersedia"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Calculate total price
      final pricePerDay = vehicleData['hargaPerhari'] ?? 0;
      final totalPrice = pricePerDay * selectedDays * selectedUnits;

      // Generate booking code
      final bookingCode =
          'BR${DateTime.now().millisecondsSinceEpoch}${user.uid.substring(0, 3).toUpperCase()}';

      // Buat booking di Firestore
      final bookingRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add({
            'bookingCode': bookingCode,
            'userId': user.uid,
            'userName': user.displayName ?? 'User',
            'userEmail': user.email,
            'ownerId': ownerId,
            'ownerName': ownerName,
            'vehicleId': widget.vehicleId,
            'vehicleName':
                "${vehicleData['merk']} ${vehicleData['namaKendaraan']}",
            'vehicleImage':
                vehicleData['fotoBase64'] ?? vehicleData['fotoPath'] ?? '',
            'vehiclePrice': pricePerDay,
            'startDate': Timestamp.now(),
            'endDate': Timestamp.fromDate(
              DateTime.now().add(Duration(days: selectedDays)),
            ),
            'totalDays': selectedDays,
            'totalPrice': totalPrice,
            'units': selectedUnits,
            'pickupLocation': vehicleData['lokasi'] ?? '',
            'status':
                'pending', // pending, confirmed, active, completed, cancelled
            'paymentStatus': 'unpaid', // unpaid, paid, refunded
            'paymentMethod': '', // akan diisi saat pembayaran
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'notes': '',
          });

      // Kurangi jumlah unit tersedia di kendaraan
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .update({
            'jumlahUnit': FieldValue.increment(-selectedUnits),
            'updatedAt': Timestamp.now(),
          });

      // Buat notifikasi untuk pemilik
      if (ownerId != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': ownerId!,
          'title': 'Booking Baru',
          'message':
              '${user.displayName ?? "User"} telah membooking ${vehicleData['namaKendaraan']}',
          'type': 'booking',
          'relatedId': bookingRef.id,
          'isRead': false,
          'createdAt': Timestamp.now(),
        });
      }

      // Tampilkan konfirmasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Booking Berhasil!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text("Kode Booking: $bookingCode"),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Tutup modal booking
      Navigator.pop(context);

      // Tampilkan dialog konfirmasi
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Booking Berhasil"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kode Booking: $bookingCode"),
              const SizedBox(height: 8),
              Text("Total: Rp ${NumberFormat().format(totalPrice)}"),
              const SizedBox(height: 8),
              const Text("Status: Menunggu Konfirmasi"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                // Navigasi ke riwayat booking
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RiwayatTransaksiPenyewa(),
                  ),
                );
              },
              child: const Text("Lihat Riwayat"),
              style: TextButton.styleFrom(foregroundColor: primaryBlue),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error creating booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal membuat booking: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: vehicleData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Center(
                    child: Text(
                      'Kendaraan tidak ditemukan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }

          final data = snapshot.data!;
          final vehicleName = "${data['merk']} ${data['namaKendaraan']}";
          final pricePerDay = data['hargaPerhari'] ?? 0;
          final totalPrice = pricePerDay * selectedDays * selectedUnits;
          final location = data['lokasi'] ?? 'Lokasi tidak diketahui';
          final description =
              data['deskripsi'] ??
              'Mobil dengan spesifikasi tinggi yang disewakan dengan harga terjangkau.';
          final features = data['fitur']?.toString().split(',') ?? [];
          final plat = data['plat'] ?? '';
          final tahun = data['tahun'] ?? '';
          final jenis = data['jenis'] ?? 'Mobil';
          final rating = data['rating'] ?? 5.0;

          return Column(
            children: [
              _buildAppBar(),

              /// HEADER WITH VEHICLE INFO
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Text(
                      'Detail Kendaraan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      vehicleName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// VEHICLE IMAGE/ICON SECTION
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getVehicleIcon(jenis),
                              size: 120,
                              color: primaryBlue,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// VEHICLE NAME AND RATING
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vehicleName,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: primaryBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              /// PRICE AND AVAILABLE UNITS INFO
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryBlue.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Harga/Hari',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Rp ${NumberFormat().format(pricePerDay)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Tersedia',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '$availableUnits Unit',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// OWNER INFO
                              FutureBuilder<DocumentSnapshot>(
                                future: ownerData,
                                builder: (context, ownerSnapshot) {
                                  if (ownerSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: primaryBlue,
                                      ),
                                    );
                                  }

                                  String ownerName = "GoRent Official";
                                  String ownerPhone = "";
                                  if (ownerSnapshot.hasData &&
                                      ownerSnapshot.data!.exists) {
                                    final ownerData =
                                        ownerSnapshot.data!.data()
                                            as Map<String, dynamic>;
                                    ownerName = ownerData['nama'] ?? ownerName;
                                    ownerPhone = ownerData['telepon'] ?? "";
                                  }

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: primaryBlue,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ownerName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryBlue,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (ownerPhone.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  ownerPhone,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                              Text(
                                                'Pemilik Terverifikasi',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            _startChatWithOwner(context);
                                          },
                                          icon: Icon(
                                            Icons.chat,
                                            color: primaryBlue,
                                            size: 24,
                                          ),
                                          tooltip: 'Chat dengan Pemilik',
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              /// CAR FEATURES TITLE
                              Text(
                                'Fitur Kendaraan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),

                              const SizedBox(height: 15),

                              /// FEATURES GRID
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 3,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                    ),
                                itemCount: features.length,
                                itemBuilder: (context, index) {
                                  final feature = features[index].trim();
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getFeatureIcon(feature),
                                          size: 18,
                                          color: primaryBlue,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            feature,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 40),

                              /// DUAL BUTTONS: CHAT & BOOK
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        _startChatWithOwner(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primaryBlue,
                                        side: BorderSide(color: primaryBlue),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.chat, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'CHAT',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _showBookingModal(context, data);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryBlue,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.calendar_today, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'BOOKING',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              /// INFO BOOKING DETAIL
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryBlue.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimasi Harga:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${selectedUnits} unit x $selectedDays hari',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Rp ${NumberFormat().format(totalPrice)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Klik tombol BOOKING untuk menentukan hari dan unit',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            DateFormat('HH:mm').format(DateTime.now()),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  void _showBookingModal(
    BuildContext context,
    Map<String, dynamic> vehicleData,
  ) {
    final pricePerDay = vehicleData['hargaPerhari'] ?? 0;
    int currentSelectedDays = selectedDays;
    int currentSelectedUnits = selectedUnits;

    void updateTotalPrice(StateSetter setModalState) {
      // Update total price calculation
      setModalState(() {});
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final totalPrice =
              pricePerDay * currentSelectedDays * currentSelectedUnits;

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Detail Booking',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),

                /// PRICE INFO CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primaryBlue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp ${NumberFormat().format(pricePerDay)} / Hari',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$availableUnits unit tersedia',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// UNIT SELECTION
                Row(
                  children: [
                    Text(
                      'Jumlah Unit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: primaryBlue,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: currentSelectedUnits > 1
                              ? () {
                                  setModalState(() {
                                    currentSelectedUnits--;
                                    updateTotalPrice(setModalState);
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: currentSelectedUnits > 1
                                ? primaryBlue
                                : Colors.grey,
                          ),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            '$currentSelectedUnits',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: currentSelectedUnits < availableUnits
                              ? () {
                                  setModalState(() {
                                    currentSelectedUnits++;
                                    updateTotalPrice(setModalState);
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: currentSelectedUnits < availableUnits
                                ? primaryBlue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// DAYS SELECTION
                Row(
                  children: [
                    Text(
                      'Lama Sewa (Hari)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: primaryBlue,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: currentSelectedDays > 1
                              ? () {
                                  setModalState(() {
                                    currentSelectedDays--;
                                    updateTotalPrice(setModalState);
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: currentSelectedDays > 1
                                ? primaryBlue
                                : Colors.grey,
                          ),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            '$currentSelectedDays',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: currentSelectedDays < 30
                              ? () {
                                  setModalState(() {
                                    currentSelectedDays++;
                                    updateTotalPrice(setModalState);
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: currentSelectedDays < 30
                                ? primaryBlue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// PRICE CALCULATION DETAILS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Harga per unit/hari:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Rp ${NumberFormat().format(pricePerDay)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$currentSelectedUnits unit x $currentSelectedDays hari:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            '${currentSelectedUnits * currentSelectedDays} unit-hari',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Biaya:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                          Text(
                            'Rp ${NumberFormat().format(totalPrice)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// LOCATION
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Pengambilan',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: primaryBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              vehicleData['lokasi'] ?? 'Lokasi tidak diketahui',
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                /// CONFIRM BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Update state variables
                      setState(() {
                        selectedDays = currentSelectedDays;
                        selectedUnits = currentSelectedUnits;
                      });
                      // Create booking
                      _createBooking(context, vehicleData);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'KONFIRMASI BOOKING - Rp ${NumberFormat().format(totalPrice)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// CANCEL BUTTON
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getVehicleIcon(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'motor':
        return Icons.motorcycle;
      case 'bus':
        return Icons.directions_bus;
      case 'mobil':
      default:
        return Icons.directions_car;
    }
  }

  IconData _getFeatureIcon(String feature) {
    final lowerFeature = feature.toLowerCase();
    if (lowerFeature.contains('seat') || lowerFeature.contains('capacity')) {
      return Icons.airline_seat_recline_normal;
    } else if (lowerFeature.contains('engine') || lowerFeature.contains('hp')) {
      return Icons.settings_input_component;
    } else if (lowerFeature.contains('speed')) {
      return Icons.speed;
    } else if (lowerFeature.contains('autopilot') ||
        lowerFeature.contains('auto')) {
      return Icons.psychology;
    } else if (lowerFeature.contains('charge')) {
      return Icons.bolt;
    } else if (lowerFeature.contains('parking')) {
      return Icons.local_parking;
    } else if (lowerFeature.contains('airbag')) {
      return Icons.air;
    } else if (lowerFeature.contains('power')) {
      return Icons.power;
    } else if (lowerFeature.contains('steering')) {
      return Icons.directions;
    } else if (lowerFeature.contains('ac') || lowerFeature.contains('air')) {
      return Icons.ac_unit;
    } else if (lowerFeature.contains('audio') ||
        lowerFeature.contains('bluetooth') ||
        lowerFeature.contains('gps')) {
      return Icons.settings_input_antenna;
    } else if (lowerFeature.contains('leather')) {
      return Icons.arrow_circle_down_outlined;
    }
    return Icons.check_circle;
  }
}
