import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/service/api.service.dart';
import 'package:daily_cashapp/models/asset_model.dart'; // Pastikan path ini benar

class TambahAsetPage extends StatefulWidget {
  final AssetModel? existingAsset;

  const TambahAsetPage({super.key, this.existingAsset});

  @override
  State<TambahAsetPage> createState() => _TambahAsetPageState();
}

class _TambahAsetPageState extends State<TambahAsetPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _saldoController = TextEditingController();
  
  String _selectedType = 'Dompet';
  bool _isSaving = false;
  bool get _isEditMode => widget.existingAsset != null;

  final List<String> _tipeAset = ['Dompet', 'Bank', 'E-Wallet', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _setupEditData();
  }

  void _setupEditData() {
    if (_isEditMode) {
      final asset = widget.existingAsset!;
      _namaController.text = asset.assetName;
      _saldoController.text = asset.currentAmount.toString(); 
      if (_tipeAset.contains(asset.assetType)) {
        _selectedType = asset.assetType;
      } else {
        _selectedType = 'Lainnya';
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  Future<void> _simpanAset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Token tidak ditemukan");

      final int saldo = int.parse(_saldoController.text);

      if (_isEditMode) {
        await ApiService.updateAsset(
          token: token,
          assetId: widget.existingAsset!.id,
          assetName: _namaController.text.trim(),
          assetType: _selectedType,
          initialAmount: saldo,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aset berhasil diperbarui!')));
        }
      } else {
        await ApiService.createAsset(
          token: token,
          assetName: _namaController.text.trim(),
          assetType: _selectedType,
          initialAmount: saldo,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aset berhasil ditambahkan!')));
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Aset' : 'Tambah Aset', style: AppTheme.heading2),
        backgroundColor: AppTheme.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Aset',
                  hintText: 'Cth: BCA, Gopay, Dompet Utama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Nama aset wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Aset',
                  border: OutlineInputBorder(),
                ),
                items: _tipeAset.map((tipe) {
                  return DropdownMenuItem(value: tipe, child: Text(tipe));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _saldoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saldo',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Saldo wajib diisi';
                  if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSaving ? null : _simpanAset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
                ),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text(_isEditMode ? 'UPDATE ASET' : 'SIMPAN ASET', style: AppTheme.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}