import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePenyewa extends StatefulWidget {
  const ProfilePenyewa({super.key});

  @override
  State<ProfilePenyewa> createState() => _ProfilePenyewaState();
}

class _ProfilePenyewaState extends State<ProfilePenyewa> {
  final Color primaryBlue = const Color(0xFF2F5586);

  String name = '';
  String email = '';
  String phone = '';
  String address = '';

  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        setState(() {
          name = data?['name'] ?? '';
          email = data?['email'] ?? user.email ?? '';
          phone = data?['phone'] ?? '';
          address = data?['address'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          name = '';
          email = user.email ?? '';
          phone = '';
          address = '';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error ambil data profile: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        "name": nameController.text.trim(),
        "email": email,
        "phone": phoneController.text.trim(),
        "address": addressController.text.trim(),
        "role": "penyewa",
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // FIX layar gelap
      }

      await getUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile berhasil diupdate")),
      );
    } catch (e) {
      debugPrint("Error update profile: $e");
    }
  }

  void showEditDialog() {
    nameController.text = name;
    phoneController.text = phone;
    addressController.text = address;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nama"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "No HP"),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Alamat"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: updateProfile,
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profile",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: showEditDialog,
            icon: const Icon(Icons.edit, color: Colors.white),
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'GoRent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person,
                                size: 60,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            name.isEmpty
                                ? "Nama belum diisi"
                                : name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF103667),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildInfoCard("Email", email),
                          _buildInfoCard("No HP", phone),
                          _buildInfoCard("Alamat", address),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(
                                  double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Logout",
                              style: TextStyle(
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(value.isEmpty ? "-" : value),
        ],
      ),
    );
  }
}
