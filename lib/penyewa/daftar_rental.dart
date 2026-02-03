import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gorent/penyewa/detail.dart';
import 'package:intl/intl.dart';

class DaftarRental extends StatefulWidget {
  const DaftarRental({super.key});

  @override
  State<DaftarRental> createState() => _DaftarRentalState();
}

class _DaftarRentalState extends State<DaftarRental> {
  final Color primaryBlue = const Color(0xFF2F5586);
  final Color accentBlue = const Color(0xFF6A94C9);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  String selectedCategory = "ALL";
  final List<String> categories = ["ALL", "Mobil", "Motor", "Bus"];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            /// ===== HEADER =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GoRent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// ===== SEARCH BAR =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search your dream car......",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ===== CATEGORY FILTERS =====
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      backgroundColor: Colors.white,
                      selectedColor: primaryBlue,
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: primaryBlue, width: 1),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// ===== VEHICLES LIST =====
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('vehicles')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2F5586),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No vehicles available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    // Filter vehicles berdasarkan kategori dan search
                    List<QueryDocumentSnapshot>
                    filteredVehicles = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final jenis = data['jenis']?.toString() ?? 'Mobil';
                      final namaKendaraan =
                          data['namaKendaraan']?.toString().toLowerCase() ?? '';
                      final merk = data['merk']?.toString().toLowerCase() ?? '';
                      final searchText = _searchController.text.toLowerCase();

                      // Filter kategori
                      if (selectedCategory != "ALL") {
                        if (selectedCategory == "Mobil" && jenis != "Mobil")
                          return false;
                        if (selectedCategory == "Motor" && jenis != "Motor")
                          return false;
                        if (selectedCategory == "Bus" && jenis != "Bus")
                          return false;
                      }

                      // Filter search
                      if (searchText.isNotEmpty) {
                        final searchMatch =
                            namaKendaraan.contains(searchText) ||
                            merk.contains(searchText) ||
                            data['lokasi']?.toString().toLowerCase().contains(
                                  searchText,
                                ) ==
                                true;
                        return searchMatch;
                      }

                      return true;
                    }).toList();

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: filteredVehicles.length,
                        itemBuilder: (context, index) {
                          final doc = filteredVehicles[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final vehicleName =
                              "${data['merk']} ${data['namaKendaraan']}";
                          final location =
                              data['lokasi']?.toString() ?? "Unknown Location";
                          final pricePerDay = data['hargaPerhari'] ?? 0;
                          final jenis = data['jenis']?.toString() ?? "Mobil";
                          final plat = data['plat']?.toString() ?? "";
                          final tahun = data['tahun']?.toString() ?? "";
                          final fitur = data['fitur']?.toString() ?? "";
                          final ownerId = data['ownerId']?.toString() ?? "";

                          return _buildVehicleCard(
                            context: context,
                            vehicleId: doc.id,
                            vehicleName: vehicleName,
                            location: location,
                            pricePerDay: pricePerDay,
                            jenis: jenis,
                            plat: plat,
                            tahun: tahun,
                            fitur: fitur,
                            ownerId: ownerId,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard({
    required BuildContext context,
    required String vehicleId,
    required String vehicleName,
    required String location,
    required dynamic pricePerDay,
    required String jenis,
    required String plat,
    required String tahun,
    required String fitur,
    required String ownerId,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// VEHICLE IMAGE/ICON
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(_getVehicleIcon(jenis), size: 60, color: primaryBlue),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// VEHICLE NAME
                Text(
                  vehicleName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                /// RATING STARS
                Row(
                  children: List.generate(
                    5,
                    (index) =>
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                  ),
                ),

                const SizedBox(height: 4),

                /// LOCATION
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// PRICE AND BOOK BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rp ${NumberFormat().format(pricePerDay is int ? pricePerDay : (pricePerDay is double ? pricePerDay.toInt() : 0))}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        Text(
                          "/Day",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailKendaraanPenyewa(
                              vehicleId: vehicleId,
                              kendaraanId: '',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Book now",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
