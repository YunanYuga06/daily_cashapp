import 'package:daily_cashapp/pages/transaksi_page.dart';
import 'package:daily_cashapp/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    TransaksiPage(), // <- ini halaman yang kamu kirim
    Center(child: Text('Halaman Aset')),
    Center(child: Text('Halaman Reminder')),
    Center(child: Text('Halaman Profil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
