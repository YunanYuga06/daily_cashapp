// lib/pages/main_page.dart
// Updated to support the floating pill bottom nav bar.
// The Scaffold's extendBody = true lets the content scroll behind the
// transparent gap below the floating nav container.

import 'package:daily_cashapp/pages/profile_page.dart';
import 'package:daily_cashapp/pages/reminder_page.dart';
import 'package:daily_cashapp/pages/transaksi_page.dart';
import 'package:daily_cashapp/pages/aset_page.dart';
import 'package:daily_cashapp/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TransaksiPage(),
    const HalamanAset(),
    const ReminderPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Required so body content is visible under the floating nav bar
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
