import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color primaryBlue = Color(0xFF2F5586);

  String selectedCategory = "ALL";
  String searchQuery = "";

  final List<Map<String, dynamic>> kendaraanList = [
    {"nama": "Tesla Model S", "kategori": "Mobil", "harga": 1500000},
    {"nama": "Toyota Avanza", "kategori": "Mobil", "harga": 500000},
    {"nama": "Yamaha NMAX", "kategori": "Motor", "harga": 200000},
    {"nama": "Honda CBR", "kategori": "Motor", "harga": 350000},
    {"nama": "Bus Pariwisata", "kategori": "Bus", "harga": 2500000},
  ];

  List<Map<String, dynamic>> get filteredList {
    return kendaraanList.where((item) {
      final matchCategory = selectedCategory == "ALL"
          ? true
          : item["kategori"] == selectedCategory;

      final matchSearch = item["nama"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      return matchCategory && matchSearch;
    }).toList();
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void onSearch(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryBlue,
      child: Column(
        children: [
          const SizedBox(height: 50),

          const Text(
            'GoRent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      onChanged: onSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search your dream car...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// FILTER CATEGORY
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                buildFilter("ALL"),
                buildFilter("Mobil"),
                buildFilter("Motor"),
                buildFilter("Bus"),
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
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text("Data tidak ditemukan"),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.directions_car,
                                    size: 50),
                                Text(
                                  item["nama"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Rp ${item["harga"]}/hari",
                                  style: const TextStyle(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilter(String label) {
    final bool isActive = selectedCategory == label;

    return GestureDetector(
      onTap: () => selectCategory(label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? primaryBlue : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
