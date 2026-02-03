import 'dart:convert'; // Import untuk base64 decoding
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gorent/penyewa/detail.dart';
import 'package:intl/intl.dart';
import 'dashboard_penyewa.dart';

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
  String selectedSection = "all";

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
                      // Jika dashboard Anda memiliki route '/dashboard'
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/penyewa/dashboard_penyewa', // Ganti dengan route dashboard Anda
                        (route) => false, // Hapus semua route sebelumnya
                      );
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
                    hintText: "Search Vechicles.....",
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

            /// ===== SECTION TABS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSectionTab("All Vehicles", "all"),
                  _buildSectionTab("Recommended", "recommended"),
                  _buildSectionTab("Popular", "popular"),
                ],
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

                    List<QueryDocumentSnapshot>
                    filteredVehicles = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final jenis = data['jenis']?.toString() ?? 'Mobil';
                      final namaKendaraan =
                          data['namaKendaraan']?.toString().toLowerCase() ?? '';
                      final merk = data['merk']?.toString().toLowerCase() ?? '';
                      final searchText = _searchController.text.toLowerCase();

                      if (selectedCategory != "ALL") {
                        if (selectedCategory == "Mobil" && jenis != "Mobil")
                          return false;
                        if (selectedCategory == "Motor" && jenis != "Motor")
                          return false;
                        if (selectedCategory == "Bus" && jenis != "Bus")
                          return false;
                      }

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

                    if (selectedSection == "recommended") {
                      filteredVehicles = filteredVehicles.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final rating = data['rating'] ?? 0;
                        final createdAt = data['createdAt'] as Timestamp?;
                        return rating >= 4.0 ||
                            (createdAt != null &&
                                DateTime.now()
                                        .difference(createdAt.toDate())
                                        .inDays <=
                                    7);
                      }).toList();
                    } else if (selectedSection == "popular") {
                      filteredVehicles = filteredVehicles.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final rating = data['rating'] ?? 0;
                        final totalRental = data['totalRental'] ?? 0;
                        return rating >= 4.5 || totalRental >= 5;
                      }).toList();
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          if (selectedSection == "recommended")
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                'Recommended for you',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                          if (selectedSection == "popular")
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                'Most Popular',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ),

                          if (selectedSection == "all")
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio:
                                        0.75, // Changed to 0.75 for better fit
                                  ),
                              itemCount: filteredVehicles.length,
                              itemBuilder: (context, index) {
                                return _buildVehicleCard(
                                  doc: filteredVehicles[index],
                                );
                              },
                            ),

                          if (selectedSection != "all")
                            Column(
                              children: filteredVehicles.map((doc) {
                                return _buildFeaturedVehicleCard(doc: doc);
                              }).toList(),
                            ),

                          if (filteredVehicles.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Center(
                                child: Text(
                                  selectedSection == "recommended"
                                      ? 'No recommended vehicles'
                                      : selectedSection == "popular"
                                      ? 'No popular vehicles'
                                      : 'No vehicles found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ),
                        ],
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

  Widget _buildSectionTab(String title, String value) {
    final isSelected = selectedSection == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryBlue : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard({required QueryDocumentSnapshot doc}) {
    final data = doc.data() as Map<String, dynamic>;
    final vehicleName = "${data['merk']} ${data['namaKendaraan']}";
    final location = data['lokasi']?.toString() ?? "Unknown Location";
    final pricePerDay = data['hargaPerhari'] ?? 0;
    final jenis = data['jenis']?.toString() ?? "Mobil";
    final fotoBase64 = data['fotoBase64']?.toString();
    final fotoPath = data['fotoPath']?.toString();

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
          /// VEHICLE IMAGE
          Container(
            height: 100, // Reduced height
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: _buildVehicleImage(fotoBase64, fotoPath, jenis),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// VEHICLE NAME
                  Text(
                    vehicleName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

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
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// PRICE AND BOOK BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatPrice(pricePerDay),
                              style: TextStyle(
                                fontSize: 13, // Reduced font size
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailKendaraanPenyewa(
                                vehicleId: doc.id,
                                kendaraanId: '',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: const Size(70, 30), // Fixed minimum size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Book",
                          style: TextStyle(
                            fontSize: 11,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedVehicleCard({required QueryDocumentSnapshot doc}) {
    final data = doc.data() as Map<String, dynamic>;
    final vehicleName = "${data['merk']} ${data['namaKendaraan']}";
    final location = data['lokasi']?.toString() ?? "Unknown Location";
    final pricePerDay = data['hargaPerhari'] ?? 0;
    final jenis = data['jenis']?.toString() ?? "Mobil";
    final fotoBase64 = data['fotoBase64']?.toString();
    final fotoPath = data['fotoPath']?.toString();
    final rating = data['rating'] ?? 4.5;
    final totalRental = data['totalRental'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          /// VEHICLE IMAGE
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: _buildVehicleImage(fotoBase64, fotoPath, jenis),
          ),

          Expanded(
            child: Padding(
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

                  /// RATING AND POPULARITY
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (selectedSection == "popular")
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$totalRental',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      if (selectedSection == "recommended")
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Rec',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// LOCATION
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
                          location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// VEHICLE DETAILS
                  Text(
                    '${data['plat'] ?? ''} • ${data['tahun'] ?? ''}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),

                  const SizedBox(height: 8),

                  /// PRICE AND BOOK BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatPrice(pricePerDay),
                              style: TextStyle(
                                fontSize: 16, // Reduced font size
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "/Day",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailKendaraanPenyewa(
                                vehicleId: doc.id,
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
                          minimumSize: const Size(80, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Book",
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
          ),
        ],
      ),
    );
  }

  /// Helper method to format price with compact notation for large numbers
  String _formatPrice(dynamic price) {
    final numPrice = price is int
        ? price
        : (price is double ? price.toInt() : 0);

    // Format with thousand separators
    final formatter = NumberFormat("#,###", "id_ID");

    // For very large numbers, you can add compact notation
    if (numPrice >= 1000000) {
      return "Rp ${(numPrice / 1000000).toStringAsFixed(1)}Jt";
    } else if (numPrice >= 1000) {
      return "Rp ${(numPrice / 1000).toStringAsFixed(1)}K";
    } else {
      return "Rp ${formatter.format(numPrice)}";
    }
  }

  /// HELPER METHOD UNTUK MENAMPILKAN GAMBAR
  Widget _buildVehicleImage(
    String? fotoBase64,
    String? fotoPath,
    String jenis,
  ) {
    // Prioritaskan fotoBase64 jika ada
    if (fotoBase64 != null && fotoBase64.isNotEmpty) {
      try {
        // Pastikan base64 string valid
        if (fotoBase64.contains(',')) {
          // Jika ada prefix data:image, hapus prefixnya
          final base64Data = fotoBase64.split(',').last;
          return Image.memory(
            base64Decode(base64Data),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print("Error loading base64 image: $error");
              return _buildVehicleIcon(jenis);
            },
          );
        } else {
          // Jika langsung base64 tanpa prefix
          return Image.memory(
            base64Decode(fotoBase64),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print("Error loading base64 image: $error");
              return _buildVehicleIcon(jenis);
            },
          );
        }
      } catch (e) {
        print("Base64 decode error: $e");
        return _buildVehicleIcon(jenis);
      }
    }
    // Jika tidak ada fotoBase64, coba fotoPath
    else if (fotoPath != null && fotoPath.isNotEmpty) {
      // Jika fotoPath adalah URL
      if (fotoPath.startsWith('http')) {
        return Image.network(
          fotoPath,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildVehicleIcon(jenis);
          },
        );
      }
      // Jika fotoPath adalah path Firebase Storage
      else if (fotoPath.startsWith('gs://') ||
          fotoPath.contains('firebasestorage')) {
        // Anda perlu mengonversi path Firebase Storage ke download URL
        // Untuk sementara, tampilkan icon
        return _buildVehicleIcon(jenis);
      }
    }

    // Jika tidak ada gambar, tampilkan icon
    return _buildVehicleIcon(jenis);
  }

  /// HELPER METHOD UNTUK ICON KENDARAAN
  Widget _buildVehicleIcon(String jenis) {
    return Center(
      child: Icon(_getVehicleIconType(jenis), size: 50, color: primaryBlue),
    );
  }

  IconData _getVehicleIconType(String jenis) {
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
