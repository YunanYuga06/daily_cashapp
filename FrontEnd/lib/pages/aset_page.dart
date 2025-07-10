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
  List<AssetModel> _assets = [];
  bool _isLoading = true;
  String? _error;

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
    if (mounted) setState(() => _isLoading = true);
    _error = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Sesi tidak valid.");

      final fetchedAssets = await ApiService.getAssets(token);
      if (mounted) {
        setState(() {
          _assets = fetchedAssets;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              color: Colors.orange,
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
              child: RefreshIndicator(
                onRefresh: _fetchAssets,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Terjadi kesalahan:\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_assets.isEmpty) {
      return const Center(
        child: Text('Belum ada aset. Tekan tombol (+) untuk menambah.'),
      );
    }

    final Map<String, List<AssetModel>> groupedAssets = {};
    for (var asset in _assets) {
      (groupedAssets[asset.assetType] ??= []).add(asset);
    }

    return ListView(
      children:
          groupedAssets.entries.map((entry) {
            final String type = entry.key;
            final List<AssetModel> assetsInGroup = entry.value;
            final int totalForType = assetsInGroup.fold(
              0,
              (sum, item) => sum + item.first_amount,
            );

            return _buildAssetGroup(type, totalForType, assetsInGroup);
          }).toList(),
    );
  }

  Widget _buildAssetGroup(String type, int total, List<AssetModel> assets) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.grey[300],
          title: Text(
            type,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Text(
            currencyFormatter.format(total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        ...assets.map(
          (asset) => ListTile(
            tileColor: Colors.grey[100],
            title: Text(asset.assetName),
            trailing: Text(
              currencyFormatter.format(asset.first_amount),
              style: const TextStyle(color: Colors.black54),
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
