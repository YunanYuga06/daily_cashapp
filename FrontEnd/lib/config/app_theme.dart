// daily_cashapp/FrontEnd/lib/config/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // --- WARNA ---
  static const Color primaryOrange = Color(0xFFF5A623); // Orange dari AppBar
  static const Color primaryYellow = Color(0xFFFFFBEA); // Latar belakang utama yang kuning pucat
  static const Color primaryBlue = Color(0xFF007BFF);   // Biru untuk tombol Simpan

  static const Color textPrimary = Color(0xFF212121);   // Hitam pekat untuk teks utama
  static const Color textSecondary = Color(0xFF757575); // Abu-abu untuk sub-teks

  static const Color income = Colors.blue;      // Biru untuk nominal pemasukan
  static const Color expense = Colors.red;      // Merah untuk nominal pengeluaran

  static const Color surface = Colors.white;    // Putih untuk latar belakang card/input
  static const Color border = Colors.black;     // Warna border untuk beberapa tombol
  static const Color disabled = Colors.grey;    // Warna untuk elemen non-aktif

  // --- GAYA TEKS (TYPOGRAPHY) ---

  // Gaya untuk judul besar, misal: "Login", "Mei 2025"
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // Gaya untuk sub-judul atau label besar, misal: "Pemasukan", "Total"
  static const TextStyle heading2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // Gaya untuk teks nominal utama
  static const TextStyle amountText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Gaya untuk teks di dalam list transaksi
  static const TextStyle transactionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  // Gaya untuk sub-teks di dalam list, misal: nama aset "Tunai"
  static const TextStyle transactionSubtitle = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  // Gaya teks standar untuk input field
  static const TextStyle inputLabel = TextStyle(
    fontSize: 16,
    color: textSecondary,
  );

  // Gaya untuk tombol
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // --- PADDING & SPACING ---
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;

  // --- BENTUK (SHAPE) ---
  static final BorderRadius borderRadius = BorderRadius.circular(12.0);
}