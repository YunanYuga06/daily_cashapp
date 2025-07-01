import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset_model.dart';
import '../service/api.service.dart';
import 'halaman_crud/tambah_aset.dart';
=======
import 'package:daily_cashapp/pages/halaman_crud/tambah_aset.dart';
>>>>>>> parent of cdfc6d6 (membuat crud tambah aset)

class HalamanAset extends StatelessWidget {
  const HalamanAset({super.key});
<<<<<<< HEAD

  @override
  State<HalamanAset> createState() => _HalamanAsetState();
}

class _HalamanAsetState extends State<HalamanAset> {
  Future<List<AssetModel>>? _assetsFuture;

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      return;
    }
    setState(() {
      _assetsFuture = ApiService.getAssets(token);
    });
  }

  Future<void> _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahAsetPage()),
    );
    if (result == true && mounted) {
      _fetchAssets();
    }
  }

=======
>>>>>>> parent of cdfc6d6 (membuat crud tambah aset)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
<<<<<<< HEAD
                      const Icon(Icons.bar_chart),
                      const SizedBox(width: 12),
=======
                      Icon(Icons.bar_chart),
                      SizedBox(width: 12),
>>>>>>> parent of cdfc6d6 (membuat crud tambah aset)
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
<<<<<<< HEAD
            Expanded(
              child: FutureBuilder<List<AssetModel>>(
                future: _assetsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Gagal memuat aset: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada aset.'));
                  }

                  final assets = snapshot.data!;

                  return RefreshIndicator(
                    onRefresh: _fetchAssets,
                    child: ListView.builder(
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        return _buildAsetItem(
                          asset.assetName,
                          'Rp 123.456', // Ganti dengan saldo dinamis nanti
                          Colors.blue,
                        );
                      },
                    ),
                  );
                },
=======

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
>>>>>>> parent of cdfc6d6 (membuat crud tambah aset)
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildAsetItem(String title, String amount, Color color) {
    return ListTile(
      tileColor: Colors.grey[200],
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(amount, style: TextStyle(color: color)),
      onTap: () {
      },
=======
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
>>>>>>> parent of cdfc6d6 (membuat crud tambah aset)
    );
  }
}
