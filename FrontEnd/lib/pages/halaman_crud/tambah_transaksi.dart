// daily_cashapp/FrontEnd/lib/pages/halaman_crud/tambah_transaksi.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/service/api.service.dart';
import 'package:daily_cashapp/models/budget.dart'; // Untuk model Category
import 'package:daily_cashapp/models/asset_model.dart'; // Untuk model Asset
import 'pilih_item_page.dart';

class AddTransaksi extends StatefulWidget {
  const AddTransaksi({super.key});

  @override
  State<AddTransaksi> createState() => _AddTransaksiState();
}

class _AddTransaksiState extends State<AddTransaksi> {
  // State untuk UI
  bool _isExpense = true;
  bool _isSaving = false;
  bool _isLoading = true;

  // Controller
  final _totalController = TextEditingController();
  final _catatanController = TextEditingController();

  // Data dinamis dari API
  late List<Category> _daftarKategori;
  late List<AssetModel> _daftarAset;

  // Data yang dipilih oleh pengguna
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;
  AssetModel? _selectedAsset;
  String _catatan = '';

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _totalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Token tidak ditemukan");

      // Ambil data kategori dan aset secara bersamaan
      final results = await Future.wait([
        ApiService.getCategories(token),
        ApiService.getAssets(token),
      ]);

      if (mounted) {
        setState(() {
          _daftarKategori = results[0] as List<Category>;
          _daftarAset = results[1] as List<AssetModel>;
          // Set nilai default jika list tidak kosong
          if (_daftarKategori.isNotEmpty) _selectedCategory = _daftarKategori.first;
          if (_daftarAset.isNotEmpty) _selectedAsset = _daftarAset.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data awal: $e')),
        );
      }
    }
  }

  Future<void> _simpanTransaksi() async {
    if (_totalController.text.isEmpty || int.tryParse(_totalController.text) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Total tidak boleh kosong!')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori wajib dipilih!')));
      return;
    }
    
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Token tidak ditemukan");

      final transactionData = TransactionData(
        categoryId: _selectedCategory!.id, // <-- Menggunakan ID asli
        amount: int.parse(_totalController.text),
        type: _isExpense ? 'expense' : 'income',
        date: _selectedDate,
        assetId: _selectedAsset?.id, // <-- Menggunakan ID asli (opsional)
        description: _catatan,
      );

      await ApiService.createTransaction(token, transactionData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil disimpan!')));
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

  void _onNumpadTap(String value) {
    if (value == 'del') {
      if (_totalController.text.isNotEmpty) {
        setState(() {
          _totalController.text = _totalController.text.substring(0, _totalController.text.length - 1);
        });
      }
    } else {
      if (value == '.' && _totalController.text.contains('.')) return;
      setState(() {
        _totalController.text += value;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pilihKategori() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PilihItemPage(title: 'Kategori', items: _daftarKategori.map((c) => c.name).toList()),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategory = _daftarKategori.firstWhere((c) => c.name == result);
      });
    }
  }

  Future<void> _pilihAset() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PilihItemPage(title: 'Aset', items: _daftarAset.map((a) => a.assetName).toList()),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedAsset = _daftarAset.firstWhere((a) => a.assetName == result);
      });
    }
  }

  Future<void> _tambahCatatan() async {
    _catatanController.text = _catatan;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Catatan'),
        content: TextField(
          controller: _catatanController, autofocus: true, decoration: const InputDecoration(hintText: 'Masukkan catatan...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, _catatanController.text), child: const Text('Simpan')),
        ],
      ),
    );
    if (result != null) {
      setState(() => _catatan = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tambah Transaksi', style: AppTheme.heading2),
        backgroundColor: AppTheme.surface,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      children: [
                        _buildTypeSelector(),
                        const SizedBox(height: AppTheme.spacingLarge),
                        _buildFormFields(),
                      ],
                    ),
                  ),
                ),
                _buildNumpad(),
              ],
            ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: AppTheme.borderRadius),
      child: ToggleButtons(
        isSelected: [_isExpense, !_isExpense],
        onPressed: (index) => setState(() => _isExpense = index == 0),
        borderRadius: AppTheme.borderRadius,
        selectedColor: Colors.white,
        fillColor: _isExpense ? AppTheme.expense : AppTheme.income,
        renderBorder: false,
        children: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12), child: Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold))),
          Padding(padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12), child: Text('Pemasukan', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildInputRow('Tanggal', DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate), () => _selectDate(context)),
        const Divider(),
        _buildInputRow('Kategori', _selectedCategory?.name ?? 'Pilih Kategori', _pilihKategori),
        const Divider(),
        _buildInputRow('Catatan', _catatan.isEmpty ? 'Ketuk untuk menambah' : _catatan, _tambahCatatan),
        const Divider(),
        _buildInputRow('Aset', _selectedAsset?.assetName ?? 'Pilih Aset', _pilihAset),
        const Divider(),
        _buildInputRow('Total', _totalController.text, null, isAmount: true),
        const Divider(),
        const SizedBox(height: AppTheme.spacingLarge),
        ElevatedButton(
          onPressed: _isSaving ? null : _simpanTransaksi,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
          ),
          child: _isSaving
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Text('SIMPAN', style: AppTheme.buttonText),
        ),
      ],
    );
  }
    
  Widget _buildInputRow(String label, String value, VoidCallback? onTap, {bool isAmount = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
            Row(
              children: [
                if(isAmount)
                  Text('Rp ', style: TextStyle(fontSize: 18, color: _isExpense ? AppTheme.expense : AppTheme.income)),
                Text(
                  value.isEmpty && isAmount ? '0' : value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isAmount ? (_isExpense ? AppTheme.expense : AppTheme.income) : AppTheme.textPrimary,
                  ),
                ),
                if(onTap != null)
                  const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final List<String> buttons = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'del'];
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: buttons.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = buttons[index];
          if (item == 'del') {
            return _numpadButton(item, icon: Icons.backspace_outlined);
          }
          return _numpadButton(item);
        },
      ),
    );
  }

  Widget _numpadButton(String value, {IconData? icon}) {
    return InkWell(
      onTap: () => _onNumpadTap(value),
      child: Center(
        child: icon != null
            ? Icon(icon, color: AppTheme.textPrimary)
            : Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}