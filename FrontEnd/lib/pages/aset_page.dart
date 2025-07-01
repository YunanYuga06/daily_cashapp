import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset_model.dart';
import '../service/api.service.dart';
import 'halaman_crud/tambah_aset.dart';

class HalamanAset extends StatefulWidget {
  const HalamanAset({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aset',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.bar_chart),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _navigateAndRefresh,
                        child: const Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsetItem(String title, String amount, Color color) {
    return ListTile(
      tileColor: Colors.grey[200],
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(amount, style: TextStyle(color: color)),
      onTap: () {
      },
    );
  }
}
