import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'package:gorent/register.dart';
import 'package:firebase_core/firebase_core.dart';

// Import folder renter
import 'renter/dashboard_renter.dart';
import 'renter/detail_rental.dart';
import 'renter/riwayat_transaksi.dart';
import 'renter/chat_renter.dart';
import 'renter/profil_renter.dart';
import 'renter/daftar_renter.dart';
import 'renter/input_data.dart';

// Import dari folder penyewa
import 'penyewa/motor_page.dart';
import 'penyewa/bus_page.dart';
import 'penyewa/mobil_page.dart';
import 'penyewa/dashboard_penyewa.dart';
import 'penyewa/detail.dart';
import 'penyewa/riwayat_chat.dart';
import 'penyewa/riwayat_transaksi.dart';
import 'penyewa/profil.dart';
import 'penyewa/search_page.dart';
import 'penyewa/rekomend.dart';
import 'about_page.dart';

// Import dari folder admin
import 'admin/dashboard_admin.dart';
import 'admin/daftar_kendaraan_admin.dart';
import 'admin/detail_sewa_admin.dart';
import 'admin/riwayat_transaksi_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const GoRentApp());
}

class GoRentApp extends StatelessWidget {
  const GoRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoRent',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // Admin routes
        '/admin/dashboard_admin': (context) => const DashboardAdmin(),
        '/admin/daftar_kendaraan_admin': (context) =>
            const DaftarKendaraanAdmin(),
        '/admin/detail_sewa_admin': (context) => const DetailSewaAdminPage(),
        '/admin/riwayat_transaksi_admin': (context) =>
            const RiwayatTransaksiAdmin(),

        // Renter routes
        '/renter/dashboard_renter': (context) => const DashboardRenter(),
        '/renter/detail_rental': (context) => DetailRental(),
        '/renter/riwayat_transaksi': (context) => const RiwayatTransaksi(),
        '/renter/riwayat_chat': (context) => const ChatRenter(),
        '/renter/profil_renter': (context) => const ProfilRenter(),
        '/renter/daftar_rental': (context) => const DaftarRental(),
        '/renter/input_data': (context) => const InputDataRenter(),

        // Penyewa routes
        '/penyewa/riwayat_chat': (context) => const RiwayatChatPenyewa(),
        '/penyewa/riwayat_transaksi': (context) =>
            const RiwayatTransaksiPenyewa(),
        '/penyewa/profil': (context) => const ProfilePenyewa(),
        '/penyewa/search_page': (context) => const SearchPage(),
        '/penyewa/rekomend': (context) => const RecommendPage(),
        '/penyewa/motor_page': (context) => const MotorPage(),
        '/penyewa/bus_page': (context) => const BusPage(),
        '/penyewa/mobil_page': (context) => const MobilPage(),
        '/penyewa/dashboard_penyewa': (context) => const DashboardPenyewa(),
        '/penyewa/detail': (context) => const DetailKendaraanPenyewa(kendaraanId: '', vehicleId: '',),

        //Lainya
        '/about_page': (context) => const AboutApp(),
      },
    );
  }
}
