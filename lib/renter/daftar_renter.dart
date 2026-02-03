import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:gorent/renter/detail_rental.dart'; // atau sesuaikan path

class DaftarRental extends StatefulWidget {
  const DaftarRental({super.key});

  @override
  State<DaftarRental> createState() => _DaftarRentalState();
}

class _DaftarRentalState extends State<DaftarRental> {
  final Color primaryBlue = const Color(0xFF2F5586);
  final Color cardBg = const Color(0xFFD2E3F1);
  final Color darkGrey = const Color(0xFF616161);
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildBodyContent(context, currentUser),
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
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF2F5586),
                ),
                const SizedBox(width: 6),
                Text(
                  _getCurrentTime(),
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

  Widget _buildBodyContent(BuildContext context, User? currentUser) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            'Daftar Rental',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF103667),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari kendaraan...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F5586),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(child: _buildVehicleList(context, currentUser)),
      ],
    );
  }

  Widget _buildVehicleList(BuildContext context, User? currentUser) {
    if (currentUser == null) {
      return const Center(
        child: Text(
          'Silakan login terlebih dahulu',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('ownerId', isEqualTo: currentUser.uid)
          .snapshots(), // SEMENTARA TANPA ORDERBY KARENA ERROR INDEX
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F5586)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                const Text(
                  'Gagal memuat data',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 5),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Belum ada kendaraan tersedia',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Tambahkan kendaraan melalui menu Input Data',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Filter berdasarkan search query
        final vehicles = snapshot.data!.docs.where((doc) {
          if (_searchQuery.isEmpty) return true;
          final data = doc.data() as Map<String, dynamic>;
          final nama = (data['namaKendaraan'] ?? '').toString().toLowerCase();
          final merk = (data['merk'] ?? '').toString().toLowerCase();
          final plat = (data['plat'] ?? '').toString().toLowerCase();
          final jenis = (data['jenis'] ?? '').toString().toLowerCase();

          return nama.contains(_searchQuery) ||
              merk.contains(_searchQuery) ||
              plat.contains(_searchQuery) ||
              jenis.contains(_searchQuery);
        }).toList();

        // Sort secara manual berdasarkan namaKendaraan
        vehicles.sort((a, b) {
          final aName =
              (a.data() as Map<String, dynamic>)['namaKendaraan']?.toString() ??
              '';
          final bName =
              (b.data() as Map<String, dynamic>)['namaKendaraan']?.toString() ??
              '';
          return aName.compareTo(bName);
        });

        if (vehicles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Tidak ditemukan',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  'Coba kata kunci lain',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: constraints.maxWidth > 400 ? 0.68 : 0.72,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index].data() as Map<String, dynamic>;
                final vehicleId = vehicles[index].id;
                return _buildRentalCard(context, vehicle, vehicleId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRentalCard(
    BuildContext context,
    Map<String, dynamic> vehicle,
    String vehicleId,
  ) {
    final name = vehicle['namaKendaraan']?.toString() ?? 'Tidak ada nama';
    final location = vehicle['lokasi']?.toString() ?? 'Lokasi tidak tersedia';
    final jenis = vehicle['jenis']?.toString() ?? 'Mobil';
    final hargaPerHari = vehicle['hargaPerhari']?.toString() ?? '0';
    final merk = vehicle['merk']?.toString() ?? '';
    final tahun = vehicle['tahun']?.toString() ?? '';
    final plat = vehicle['plat']?.toString() ?? '';
    final fitur = vehicle['fitur']?.toString() ?? '';

    final status = 'Tersedia';
    final statusColor = const Color(0xFF2F5586);

    // Tentukan icon berdasarkan jenis
    IconData icon;
    switch (jenis.toLowerCase()) {
      case 'motor':
        icon = Icons.motorcycle;
        break;
      case 'bus':
        icon = Icons.directions_bus;
        break;
      default:
        icon = Icons.directions_car;
    }

    return Container(
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
            _showVehicleDetail(context, vehicle, vehicleId);
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar/Icon kendaraan
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(child: _buildVehicleImage(vehicle)),

                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info kendaraan
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama kendaraan
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF103667),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Merk dan tahun
                    if (merk.isNotEmpty || tahun.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${merk.isNotEmpty ? '$merk • ' : ''}$tahun',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const SizedBox(height: 6),

                    // Lokasi
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 11,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Plat nomor
                    if (plat.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number,
                            size: 11,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            plat,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),

                    // Harga dan tombol LIHAT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp $hargaPerHari/hari',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigasi ke DetailRental dengan data vehicle
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailRental(
                                    vehicleData: vehicle,
                                    vehicleId: vehicleId,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 28,
                              width: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F5586),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2F5586,
                                    ).withOpacity(0.3),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'LIHAT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildVehicleImage(Map<String, dynamic> vehicle) {
    // Coba tampilkan gambar base64 jika ada
    if (vehicle.containsKey('fotoBase64') && vehicle['fotoBase64'] != null) {
      try {
        final base64Image = vehicle['fotoBase64'].toString();
        if (base64Image.isNotEmpty) {
          return Image.memory(
            base64Decode(base64Image),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        }
      } catch (e) {
        print('Error loading base64 image: $e');
      }
    }

    // Jika tidak ada gambar, tampilkan icon berdasarkan jenis
    final jenis = vehicle['jenis']?.toString() ?? 'Mobil';
    IconData icon;

    switch (jenis.toLowerCase()) {
      case 'motor':
        icon = Icons.motorcycle;
        break;
      case 'bus':
        icon = Icons.directions_bus;
        break;
      default:
        icon = Icons.directions_car;
    }

    return Icon(icon, size: 55, color: primaryBlue);
  }

  void _showVehicleDetail(
    BuildContext context,
    Map<String, dynamic> vehicle,
    String vehicleId,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _buildVehicleDetailSheet(context, vehicle, vehicleId);
      },
    );
  }

  Widget _buildVehicleDetailSheet(
    BuildContext context,
    Map<String, dynamic> vehicle,
    String vehicleId,
  ) {
    final createdAt = vehicle['createdAt'];
    final formattedDate = createdAt != null
        ? _formatDate(createdAt)
        : 'Tidak tersedia';

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.8,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detail Kendaraan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF103667),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Gambar kendaraan
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _buildVehicleImage(vehicle),
            ),

            const SizedBox(height: 20),

            // Detail informasi
            _buildDetailItem(
              'Nama Kendaraan',
              vehicle['namaKendaraan']?.toString() ?? '-',
            ),
            _buildDetailItem('Merk', vehicle['merk']?.toString() ?? '-'),
            _buildDetailItem('Tahun', vehicle['tahun']?.toString() ?? '-'),
            _buildDetailItem('Plat Nomor', vehicle['plat']?.toString() ?? '-'),
            _buildDetailItem('Lokasi', vehicle['lokasi']?.toString() ?? '-'),
            _buildDetailItem('Jenis', vehicle['jenis']?.toString() ?? '-'),
            _buildDetailItem(
              'Harga per Hari',
              'Rp ${vehicle['hargaPerhari']?.toString() ?? '0'}',
            ),
            _buildDetailItem(
              'Harga per Jam',
              'Rp ${vehicle['hargaPerjam']?.toString() ?? '0'}',
            ),
            _buildDetailItem('Tanggal Input', formattedDate),

            if (vehicle.containsKey('fitur') && vehicle['fitur'] != null)
              _buildDetailItem('Fitur', vehicle['fitur']?.toString() ?? '-'),

            const SizedBox(height: 30),

            // Tombol aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Navigasi ke edit page
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF2F5586)),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2F5586),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('vehicles')
                            .doc(vehicleId)
                            .delete();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kendaraan berhasil dihapus'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menghapus: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF103667),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF616161)),
            ),
          ),
        ],
      ),
    );
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
        currentIndex: 2, // Daftar rental aktif (index 2 dari 6 menu)
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
            icon: Icon(Icons.add_circle_outline),
            label: 'Input Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Daftar',
          ),
          BottomNavigationBarItem(
            // <-- MENU CHAT BARU
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
                '/renter/dashboard_renter',
              );
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/renter/input_data');
              break;
            case 2:
              // Already on daftar rental
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/renter/riwayat_chat_renter');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/renter/riwayat_rental');
              break;
            case 5:
              Navigator.pushReplacementNamed(context, '/renter/profil_renter');
              break;
          }
        },
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(dynamic date) {
    try {
      if (date is Timestamp) {
        final dateTime = date.toDate();
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
      }
      return date.toString();
    } catch (e) {
      return 'Format tidak valid';
    }
  }
}
