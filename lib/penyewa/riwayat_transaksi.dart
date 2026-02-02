import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail.dart';

class RiwayatTransaksiPenyewa extends StatelessWidget {
  const RiwayatTransaksiPenyewa({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text("Riwayat Transaksi"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: user?.uid)
            .orderBy("tanggal", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Belum ada transaksi"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(doc["vehicleName"] ?? "-"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tanggal: ${doc["tanggal"] ?? "-"}"),
                      Text("Status: ${doc["status"] ?? "-"}"),
                    ],
                  ),
                  trailing: Text(
                    "Rp ${doc["harga"] ?? 0}",
                    style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailKendaraanPenyewa(
                          vehicleId: doc["vehicleId"] ?? "",
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
    );
  }
}
