import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return GNav(
      padding: const EdgeInsets.all(24),
      activeColor: Colors.yellow[700],
      tabBackgroundColor: Colors.white70,
      selectedIndex: selectedIndex,
      onTabChange: onTabChange,
      tabs: const [
        GButton(icon: Icons.wallet, text: "Transaksi"),
        GButton(icon: Icons.wallet_travel, text: "Aset"),
        GButton(icon: Icons.calendar_month, text: "Reminder"),
        GButton(icon: Icons.person, text: "Profil"),
      ],
    );
  }
}