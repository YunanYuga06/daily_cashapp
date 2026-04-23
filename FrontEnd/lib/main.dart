import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/view/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

// Pastikan import ini sesuai dengan struktur folder Anda
import 'view/login.dart';
import 'pages/main_page.dart'; // Tempat HalamanUtama() berada

void main() async {
  // Wajib dipanggil jika kita ingin menggunakan async di main()
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  // 1. Cek Kulkas (SharedPreferences) sebelum aplikasi menggambar UI
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  // 2. Tentukan status login (jika token ada, berarti sudah login)
  final bool isLoggedIn = token != null;

  // 3. Jalankan aplikasi dengan membawa status login
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Cash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // 4. Logika Pengalihan (Routing) Pintar
      // Jika sudah login -> masuk ke HalamanUtama
      // Jika belum login -> masuk ke LoginPage
      home: isLoggedIn ? const HalamanUtama() : const DashboardPage(),
    );
  }
}
