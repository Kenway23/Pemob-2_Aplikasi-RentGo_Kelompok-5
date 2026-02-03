import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'package:gorent/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// Import folder renter
import 'renter/dashboard_renter.dart';
import 'renter/detail_rental.dart'; // DetailRental di folder renter
import 'renter/riwayat_rental.dart';
import 'renter/chat_renter.dart';
import 'renter/profil_renter.dart';
import 'renter/daftar_renter.dart'; // Pastikan ini ada
import 'renter/input_data.dart';

// Import dari folder penyewa
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

  // Aktifkan Firebase App Check hanya di production
  if (!kDebugMode) {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
      print('Firebase App Check activated successfully');
    } catch (e) {
      print('Firebase App Check activation error: $e');
    }
  }

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

      // Untuk rute yang membutuhkan parameter, gunakan onGenerateRoute
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          // RUTE DETAIL RENTAL DENGAN PARAMETER
          case '/renter/detail_rental':
            final args = settings.arguments as Map<String, dynamic>?;

            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => DetailRental(
                  vehicleData: args['vehicleData'] ?? {},
                  vehicleId: args['vehicleId'] ?? '',
                ),
              );
            } else {
              // Fallback jika tidak ada arguments
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Data kendaraan tidak ditemukan')),
                ),
              );
            }

          // RUTE LAINNYA (gunakan ini untuk rute dengan parameter)
          case '/penyewa/detail':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => DetailKendaraanPenyewa(
                  kendaraanId: args['kendaraanId'] ?? '',
                  vehicleId: args['vehicleId'] ?? '',
                ),
              );
            }
            // Default ke rute dengan ID kosong
            return MaterialPageRoute(
              builder: (context) =>
                  const DetailKendaraanPenyewa(kendaraanId: '', vehicleId: ''),
            );

          // Untuk semua rute lainnya yang tidak membutuhkan parameter
          default:
            return null; // Akan dilanjutkan ke routes biasa
        }
      },

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
        // '/renter/detail_rental': (context) => DetailRental(), // DIHAPUS, pindah ke onGenerateRoute
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
        '/penyewa/dashboard_penyewa': (context) => const DashboardPenyewa(),
        // '/penyewa/detail': (context) => // DIHAPUS, pindah ke onGenerateRoute

        // Lainnya
        '/about_page': (context) => const AboutApp(),
      },
    );
  }
}
