import 'package:daily_cashapp/service/api.service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahAsetPage extends StatefulWidget {
  const TambahAsetPage({super.key});

  @override
  State<TambahAsetPage> createState() => _TambahAsetPageState();
}

class _TambahAsetPageState extends State<TambahAsetPage> {
  final TextEditingController _namaAsetController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  // Sesuaikan pilihan ini kalau di backend kamu punya standar tertentu
  String _selectedJenis = 'Cash';

  bool _isSaving = false;

  @override
  void dispose() {
    _namaAsetController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  int _parseAmountToInt(String input) {
    // Hapus semua selain digit
    final digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  Future<void> _simpanAset() async {
    if (_isSaving) return;

    final nama = _namaAsetController.text.trim();
    final amount = _parseAmountToInt(_totalController.text);

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama aset harus diisi')),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total aset harus lebih dari 0')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      await ApiService.createAsset(
        token: token,
        assetName: nama,
        assetType: _selectedJenis,
        initialAmount: amount,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aset berhasil ditambahkan')),
      );

      Navigator.pop(context, true); // <- ini penting supaya halaman aset refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan aset: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Aset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _namaAsetController,
              decoration: const InputDecoration(
                labelText: 'Nama Aset',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedJenis,
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                DropdownMenuItem(value: 'E-Wallet', child: Text('E-Wallet')),
                DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedJenis = value);
              },
              decoration: const InputDecoration(
                labelText: 'Jenis Aset',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _totalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Aset (angka saja)',
                hintText: 'contoh: 1500000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpanAset,
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SIMPAN'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
