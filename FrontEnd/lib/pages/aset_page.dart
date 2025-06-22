import 'package:flutter/material.dart';
import 'package:daily_cashapp/pages/halaman_crud/tambah_aset.dart';

class HalamanAset extends StatelessWidget {
  const HalamanAset({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Aset
            Container(
              color: Colors.amber,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aset',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.bar_chart),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TambahAsetPage(),
                            ),
                          );
                        },
                        child: Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Header kolom
            Container(
              color: Colors.amber,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Digunakan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Sisa', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Data dummy aset
            Expanded(
              child: ListView(
                children: [
                  _buildAsetItem('Tunai', 'Tunai', 'Rp. 12.000', Colors.red),
                  _buildAsetItem(
                    'E-Wallet',
                    'Gopay',
                    'Rp. 50.000',
                    Colors.blue,
                  ),
                  _buildAsetItem('Rekening Bank', '', 'Rp. 0', Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsetItem(
    String title,
    String subtitle,
    String amount,
    Color color,
  ) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.grey[200],
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(amount, style: TextStyle(color: color)),
        ),
        if (subtitle.isNotEmpty)
          ListTile(
            tileColor: Colors.grey[100],
            title: Text(subtitle),
            trailing: Text(amount, style: TextStyle(color: color)),
          ),
      ],
    );
  }
}
