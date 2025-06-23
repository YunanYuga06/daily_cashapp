// daily_cashapp/FrontEnd/lib/pages/transaksi_harian.dart

import 'package:flutter/material.dart';
import 'package:daily_cashapp/pages/halaman_crud/tambah_transaksi.dart'; // Perbaiki impor ini

class TransaksiHarian extends StatelessWidget {
  const TransaksiHarian({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.amber,
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Pemasukan\nRp. 525.000', style: TextStyle(fontSize: 12)),
                Text('Pengeluaran\nRp. -18.500', style: TextStyle(fontSize: 12)),
                Text('Total\nRp. 506.000', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('19 Mei 2025', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('Uang Saku Harian'),
                  subtitle: Text('Tunai'),
                  trailing: Text('Rp. 25.000', style: TextStyle(color: Colors.blue)),
                ),
                ListTile(
                  title: Text('Job Freelance'),
                  subtitle: Text('E-wallet'),
                  trailing: Text('Rp. 500.000', style: TextStyle(color: Colors.blue)),
                ),
                ListTile(
                  title: Text('Ayam Geprek'),
                  subtitle: Text('Tunai'),
                  trailing: Text('Rp. -11.000', style: TextStyle(color: Colors.red)),
                ),
                ListTile(
                  title: Text('Gojek - Berangkat'),
                  subtitle: Text('Tunai'),
                  trailing: Text('Rp. -7.500', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const TambahTransaksi(),
          );
        },
        child: const Icon(Icons.add),
      ),
      // Bagian BottomNavigationBar ini tidak diperlukan di sini karena sudah ada di main_page.dart
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 0,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.view_list), label: 'Transaksi'),
      //     BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
      //     BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Aset'),
      //     BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Reminder'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      //   ],
      // ),
    );
  }
}