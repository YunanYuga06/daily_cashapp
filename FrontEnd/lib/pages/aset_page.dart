import 'package:daily_cashapp/models/asset_model.dart';
import 'package:daily_cashapp/pages/halaman_crud/tambah_aset.dart';
import 'package:daily_cashapp/service/api.service.dart';
import 'package:daily_cashapp/view/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanAset extends StatefulWidget {
  const HalamanAset({super.key});

  @override
  State<HalamanAset> createState() => _HalamanAsetState();
}

class _HalamanAsetState extends State<HalamanAset> {
  Future<List<AssetModel>>? _assetsFuture;

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      if (mounted) {
        setState(() {
          _assetsFuture = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _assetsFuture = ApiService.getAssets(token);
      });
    }
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahAsetPage()),
    );

    if (result == true && mounted) {
      _fetchAssets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Aset'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _navigateAndRefresh,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Kalau belum login / token tidak ada
    if (_assetsFuture == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Silakan login untuk melihat aset."),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("Login"),
            )
          ],
        ),
      );
    }

    return FutureBuilder<List<AssetModel>>(
      future: _assetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Gagal memuat aset. Error: ${snapshot.error}'),
          );
        }

        final assets = snapshot.data ?? [];
        if (assets.isEmpty) {
          return RefreshIndicator(
            onRefresh: _fetchAssets,
            child: ListView(
              children: const [
                SizedBox(height: 200),
                Center(
                  child: Text(
                    'Belum ada aset.\nTekan tombol (+) untuk menambahkan.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchAssets,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return _buildAsetItem(asset);
            },
          ),
        );
      },
    );
  }

  Widget _buildAsetItem(AssetModel asset) {
    return Dismissible(
      key: Key(asset.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Hapus Aset?"),
              content: Text("Yakin ingin menghapus dompet '${asset.assetName}'?\n\nCatatan: Jika aset ini sudah memiliki transaksi, penghapusan akan ditolak untuk menjaga riwayat keuangan Anda."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      
      // Aksi Hapus via API
      onDismissed: (direction) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null) {
          try {
            await ApiService.deleteAsset(token, asset.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aset berhasil dihapus')),
              );
              _fetchAssets();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gagal menghapus! Pastikan aset ini tidak terikat dengan transaksi.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
              _fetchAssets(); 
            }
          }
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          tileColor: Colors.grey[200],
          leading: const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.account_balance_wallet, color: Colors.white),
          ),
          title: Text(
            asset.assetName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: asset.assetType.isNotEmpty ? Text(asset.assetType) : null,
          trailing: Text(
            currencyFormatter.format(asset.currentAmount),
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TambahAsetPage(existingAsset: asset),
              ),
            );
            if (result == true && mounted) {
              _fetchAssets();
            }
          },
        ),
      ),
    );
  }
}