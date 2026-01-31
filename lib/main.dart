import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'register.dart';

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
import 'penyewa/reccomend.dart';
import 'about_page.dart';

void main() {
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

        // Renter routes
        '/dashboard': (context) => const DashboardRenter(),
        '/detail-rental': (context) => DetailRental(),
        '/riwayat': (context) => const RiwayatTransaksi(),
        '/chat': (context) => const ChatRenter(),
        '/profil': (context) => const ProfilRenter(),
        '/daftar-rental': (context) => const DaftarRental(),
        '/input-data': (context) => const InputDataRenter(),

        // Penyewa routes
        '/riwayat-chat': (context) => const RiwayatChatPenyewa(),
        '/riwayat-transaksi': (context) => const RiwayatTransaksiPenyewa(),
        '/profil-penyewa': (context) => const ProfilePenyewa(),
        '/search': (context) => const SearchPage(),
        '/rekomendasi': (context) => const RecommendPage(),
        '/motor': (context) => const MotorPage(),
        '/bus': (context) => const BusPage(),
        '/mobil': (context) => const MobilPage(),
        '/dashboard-penyewa': (context) => const DashboardOwner(),
        '/detail-penyewa': (context) =>
            const DetailKendaraanPenyewa(), // Untuk penyewa
        '/about': (context) => const AboutApp(),
      },
    );
  }
}
