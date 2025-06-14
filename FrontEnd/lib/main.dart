import 'package:daily_cashapp/view/transaksi/halaman_transakasi.dart';
import 'package:flutter/material.dart';
import 'view/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Cash',
      debugShowCheckedModeBanner: false,
      home: const HalamanTransaksi(),
    );
  }
}
