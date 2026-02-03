import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'package:gorent/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// Import folder renter
import 'renter/dashboard_renter.dart';
import 'renter/detail_rental.dart';
import 'renter/riwayat_rental.dart';
import 'renter/chat_renter.dart';
import 'renter/profil_renter.dart';
import 'renter/daftar_renter.dart';
import 'renter/input_data.dart';
import 'renter/riwayat_chat_renter.dart'; // Tambahkan ini

// Import dari folder penyewa
import 'penyewa/dashboard_penyewa.dart';
import 'penyewa/detail.dart';
import 'penyewa/chat_penyewa.dart';
import 'penyewa/riwayat_booking.dart';
import 'penyewa/profil.dart';
import 'penyewa/riwayat_chat_penyewa.dart'; // Tambahkan ini
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

          // RUTE DETAIL PENYEWA DENGAN PARAMETER
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

          // RUTE CHAT PENYEWA DENGAN PARAMETER
          case '/penyewa/chat_penyewa':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatRoomId: args['chatRoomId'] ?? '',
                  otherUserId: args['otherUserId'] ?? '',
                  otherUserName: args['otherUserName'] ?? '',
                  vehicleId: args['vehicleId'] ?? '',
                  vehicleName: args['vehicleName'] ?? '',
                ),
              );
            }
            // Fallback jika tidak ada arguments
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Chat')),
                body: const Center(
                  child: Text(
                    'Tidak dapat memulai chat. Data tidak lengkap.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            );

          // RUTE CHAT RENTER DENGAN PARAMETER
          case '/renter/chat':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => ChatRenter(
                  chatRoomId: args['chatRoomId'] ?? '',
                  otherUserId: args['otherUserId'] ?? '',
                  otherUserName: args['otherUserName'] ?? '',
                  vehicleId: args['vehicleId'] ?? '',
                  vehicleName: args['vehicleName'] ?? '',
                ),
              );
            }
            // Jika tidak ada parameter, tampilkan ChatRenter kosong
            return MaterialPageRoute(builder: (context) => const ChatRenter());

          default:
            return null;
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
        '/renter/riwayat_transaksi': (context) => const RiwayatTransaksi(),
        '/renter/riwayat_chat_renter': (context) =>
            const RiwayatChatRenter(), // Tambahkan
        '/renter/profil_renter': (context) => const ProfilRenter(),
        '/renter/daftar_rental': (context) => const DaftarRental(),
        '/renter/input_data': (context) => const InputDataRenter(),

        // Penyewa routes
        '/penyewa/dashboard_penyewa': (context) => const DashboardPenyewa(),
        '/penyewa/riwayat_transaksi': (context) =>
            const RiwayatTransaksiPenyewa(),
        '/penyewa/riwayat_chat_penyewa': (context) =>
            const RiwayatChatPenyewa(), // Tambahkan
        '/penyewa/profil': (context) => const ProfilePenyewa(),

        // Lainnya
        '/about_page': (context) => const AboutApp(),
      },
    );
  }
}
