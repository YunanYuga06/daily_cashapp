// daily_cashapp/FrontEnd/lib/pages/transaksi_bulanan.dart

import 'package:flutter/material.dart';

class TransaksiBulanan extends StatelessWidget {
  const TransaksiBulanan({super.key});

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
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: const [
                ListTile(title: Text('Mei'), trailing: Text('Rp. 12.000', style: TextStyle(color: Colors.red))),
                ListTile(title: Text('29.05 - 31.05'), trailing: Text('Rp. 50.000')),
                ListTile(title: Text('22.05 - 28.05'), trailing: Text('Rp. 50.000')),
                ListTile(title: Text('15.05 - 21.05'), trailing: Text('Rp. 50.000')),
                ListTile(title: Text('08.05 - 14.05'), trailing: Text('Rp. 50.000')),
                ListTile(title: Text('01.05 - 07.05'), trailing: Text('Rp. 0')),
                Divider(),
                ListTile(title: Text('April'), trailing: Text('Rp. 12.000', style: TextStyle(color: Colors.red))),
                ListTile(title: Text('29.04 - 30.04'), trailing: Text('Rp. 50.000')),
                ListTile(title: Text('22.04 - 28.04'), trailing: Text('Rp. 50.000')),
                ListTile(title: Text('15.04 - 21.04'), trailing: Text('Rp. 50.000')),
                ListTile(title: Text('08.04 - 14.04'), trailing: Text('Rp. 50.000')),
                ListTile(title: Text('01.04 - 07.04'), trailing: Text('Rp. 0')),
              ],
            ),
          ),
        ],
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