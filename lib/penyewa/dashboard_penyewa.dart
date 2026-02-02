import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gorent/penyewa/detail.dart';
import 'package:gorent/penyewa/riwayat_transaksi.dart';
import 'package:gorent/penyewa/daftar_rental.dart';
import 'package:gorent/penyewa/profil.dart';
import 'package:gorent/penyewa/search_page.dart';

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
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
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

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Column(
        children: [
          const SizedBox(height: 60),

          /// TITLE
          const Text(
            'GoRent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          /// WHITE PANEL
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// PROFILE
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String name = "User";
                        String email = user?.email ?? "";

                        if (snapshot.hasData &&
                            snapshot.data?.data() != null) {
                          var data = snapshot.data!.data()
                              as Map<String, dynamic>;
                          name = data['name'] ?? name;
                          email = data['email'] ?? email;
                        }

                        return Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello, $name",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold),
                                ),
                                Text(
                                  email,
                                  style: const TextStyle(
                                      color: Colors.grey),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    /// RIWAYAT
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Riwayat",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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
                          child: const Text("View All"),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("orders")
                          .where("userId",
                              isEqualTo: user?.uid)
                          .limit(2)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text("Belum ada riwayat"),
                          );
                        }

                        return Column(
                          children:
                              snapshot.data!.docs.map((doc) {
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title:
                                    Text(doc["vehicleName"] ?? "-"),
                                subtitle:
                                    Text(doc["tanggal"] ?? "-"),
                                trailing:
                                    Text(doc["status"] ?? "-"),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailKendaraanPenyewa(
                                        vehicleId:
                                            doc["vehicleId"] ?? "",
                                        kendaraanId: '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    /// REKOMENDASI
                    const Text(
                      "Rekomendasi",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("kendaraan")
                          .limit(2)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return Column(
                          children:
                              snapshot.data!.docs.map((doc) {
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title:
                                    Text(doc["nama"] ?? "-"),
                                subtitle:
                                    Text(doc["lokasi"] ?? "-"),
                                trailing: Text(
                                  "Rp ${doc["harga"] ?? 0}/hari",
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight:
                                          FontWeight.bold),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailKendaraanPenyewa(
                                        vehicleId: doc.id,
                                        kendaraanId: '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
