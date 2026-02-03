import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DetailKendaraanPenyewa extends StatefulWidget {
  final String vehicleId;
  const DetailKendaraanPenyewa({
    super.key,
    required this.vehicleId,
    required String kendaraanId,
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
        // Fetch owner data
        if (data['ownerId'] != null) {
          ownerData = FirebaseFirestore.instance
              .collection('users')
              .doc(data['ownerId'])
              .get();
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
  // FUNCTION BOOKING FIREBASE
  // ===========================
  Future<void> _createBooking(
    BuildContext context,
    Map<String, dynamic> vehicleData,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please login to book")));
        return;
      }

      // Calculate total price
      final pricePerDay = vehicleData['hargaPerhari'] ?? 0;
      final totalPrice = pricePerDay * selectedDays * selectedUnits;

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'vehicleId': widget.vehicleId,
        'vehicleName': "${vehicleData['merk']} ${vehicleData['namaKendaraan']}",
        'vehicleImage': vehicleData['imageUrl'] ?? '',
        'vehiclePrice': pricePerDay,
        'startDate': Timestamp.now(),
        'endDate': Timestamp.fromDate(
          DateTime.now().add(Duration(days: selectedDays)),
        ),
        'totalDays': selectedDays,
        'totalPrice': totalPrice,
        'units': selectedUnits,
        'pickupLocation': vehicleData['lokasi'] ?? '',
        'status': 'pending',
        'paymentStatus': 'unpaid',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Booking Successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Close booking modal
      Navigator.pop(context); // Go back to previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
                      'Vehicle not found',
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
          final location = data['lokasi'] ?? 'Unknown Location';
          final description =
              data['deskripsi'] ??
              'A car with high specs that are rented at an affordable price.';
          final features = data['fitur']?.toString().split(',') ?? [];
          final plat = data['plat'] ?? '';
          final tahun = data['tahun'] ?? '';
          final jenis = data['jenis'] ?? 'Mobil';

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
                      'Car Details',
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
                                          '5.0',
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

                              /// OWNER INFO
                              FutureBuilder<DocumentSnapshot>(
                                future: ownerData,
                                builder: (context, ownerSnapshot) {
                                  if (ownerSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  String ownerName = "GoRent Official";
                                  if (ownerSnapshot.hasData &&
                                      ownerSnapshot.data!.exists) {
                                    final ownerData =
                                        ownerSnapshot.data!.data()
                                            as Map<String, dynamic>;
                                    ownerName = ownerData['nama'] ?? ownerName;
                                  }

                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: primaryBlue,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
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
                                          Text(
                                            'Verified Owner',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Icon(Icons.verified, color: Colors.blue),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              /// CAR FEATURES TITLE
                              Text(
                                'Car features',
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

                              const SizedBox(height: 30),

                              /// REVIEWS SECTION
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Review (125)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: primaryBlue,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Navigate to all reviews
                                          },
                                          child: Text(
                                            'See All',
                                            style: TextStyle(
                                              color: primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey[200],
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Mr. Xyz',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: primaryBlue,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  ),
                                                  Text(
                                                    '5.0',
                                                    style: TextStyle(
                                                      color: primaryBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'The rental car was clean, reliable, and the service was quick and efficient.',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),

                              /// BOOK BUTTON
                              SizedBox(
                                width: double.infinity,
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'BOOK NOW',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
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
    final totalPrice = pricePerDay * selectedDays * selectedUnits;
    final location = vehicleData['lokasi'] ?? 'Unknown Location';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
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
                  'Detail Informasi',
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
                        'IDR ${NumberFormat().format(pricePerDay)} / 1 Day',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '3 unit tersedia',
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
                      'Unit',
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
                          onPressed: selectedUnits > 1
                              ? () {
                                  setState(() {
                                    selectedUnits--;
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: selectedUnits > 1
                                ? primaryBlue
                                : Colors.grey,
                          ),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            '$selectedUnits',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: selectedUnits < 3
                              ? () {
                                  setState(() {
                                    selectedUnits++;
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: selectedUnits < 3
                                ? primaryBlue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// PRICE AND DAYS SELECTION
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                              'Price',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'IDR ${NumberFormat().format(totalPrice)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
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
                              'Days',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$selectedDays',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: selectedDays > 1
                                          ? () {
                                              setState(() {
                                                selectedDays--;
                                              });
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.remove,
                                        size: 18,
                                        color: selectedDays > 1
                                            ? primaryBlue
                                            : Colors.grey,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedDays++;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        size: 18,
                                        color: primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

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
                        'Location',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: primaryBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              location,
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

                /// BOOKING BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
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
                      'BOOKING - IDR ${NumberFormat().format(totalPrice)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
