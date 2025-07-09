import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../service/api.service.dart';

class TambahAsetPage extends StatefulWidget {
  const TambahAsetPage({super.key});

  @override
  State<TambahAsetPage> createState() => _TambahAsetPageState();
}

class _TambahAsetPageState extends State<TambahAsetPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _totalController = TextEditingController();

  // Opsi untuk jenis aset
  final List<String> _jenisAset = [
    'Uang Tunai',
    'E-Wallet',
    'Bank',
    'Investasi',
    'Lainnya',
  ];
  String? _selectedJenis;
  bool _isSaving = false;

  @override
  void dispose() {
    _namaController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _simpanAset() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Sesi tidak valid");

      

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aset berhasil ditambahkan!')),
        );
        Navigator.pop(context, true); // Kirim 'true' untuk refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Aset'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedJenis,
              decoration: const InputDecoration(
                labelText: 'Jenis Aset',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              hint: const Text('Pilih Jenis Aset'),
              items:
                  _jenisAset.map((jenis) {
                    return DropdownMenuItem<String>(
                      value: jenis,
                      child: Text(jenis),
                    );
                  }).toList(),
              onChanged:
                  (newValue) => setState(() => _selectedJenis = newValue),
              validator:
                  (value) => value == null ? 'Jenis aset wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Aset',
                hintText: 'Contoh: Dompet, GoPay, Rekening BCA',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              validator:
                  (value) =>
                      (value == null || value.isEmpty)
                          ? 'Nama aset wajib diisi'
                          : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _totalController,
              decoration: const InputDecoration(
                labelText: 'Saldo Awal',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                // Bisa ditambahkan formatter untuk ribuan jika perlu
              ],
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Saldo awal wajib diisi';
                if (int.tryParse(value.replaceAll('.', '')) == null)
                  return 'Masukkan angka yang valid';
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _simpanAset,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _isSaving
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                      : const Text('SIMPAN', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
