import 'package:flutter/material.dart';
import 'detail.dart';

class DaftarRental extends StatelessWidget {
  const DaftarRental({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);
  final Color accentBlue = const Color(0xFF6A94C9);

  final List<Map<String, dynamic>> daftarRental = const [
    {
      "id": "tesla_1",
      "nama": "Tesla Model S",
      "harga": 1500000,
      "icon": Icons.directions_car,
    },
    {
      "id": "avanza_1",
      "nama": "Toyota Avanza",
      "harga": 500000,
      "icon": Icons.directions_car,
    },
    {
      "id": "nmax_1",
      "nama": "Yamaha NMAX",
      "harga": 200000,
      "icon": Icons.motorcycle,
    },
    {
      "id": "cbr_1",
      "nama": "Honda CBR",
      "harga": 350000,
      "icon": Icons.motorcycle,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Column(
        children: [

          const SizedBox(height: 60),

          /// ===== TITLE =====
          const Text(
            'GoRent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          /// ===== WHITE PANEL =====
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  itemCount: daftarRental.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    final kendaraan = daftarRental[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              kendaraan["icon"],
                              size: 55,
                              color: primaryBlue,
                            ),

                            Text(
                              kendaraan["nama"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              "Rp ${kendaraan["harga"]} / hari",
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailKendaraanPenyewa(
                                      kendaraanId:
                                          kendaraan["id"],
                                      vehicleId: '',
                                    ),
                                  ),
                                );
                              },
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    accentBlue,
                                minimumSize:
                                    const Size(
                                        double.infinity,
                                        38),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(10),
                                ),
                              ),
                              child: const Text(
                                "SEE",
                                style: TextStyle(
                                    color:
                                        Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
