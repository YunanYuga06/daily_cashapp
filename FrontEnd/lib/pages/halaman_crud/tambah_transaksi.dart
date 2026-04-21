import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/service/api.service.dart';
import 'package:daily_cashapp/models/budget.dart'; 
import 'package:daily_cashapp/models/asset_model.dart';
import 'package:daily_cashapp/models/transaksi_model.dart'; // <-- Wajib import ini
import 'pilih_item_page.dart';

class AddTransaksi extends StatefulWidget {
  // Tambahkan parameter opsional untuk mode Edit
  final TransactionModel? existingTransaction;

  const AddTransaksi({super.key, this.existingTransaction});

  @override
  State<AddTransaksi> createState() => _AddTransaksiState();
}

class _AddTransaksiState extends State<AddTransaksi> {
  bool _isExpense = true;
  bool _isSaving = false;
  bool _isLoading = true;

  final _totalController = TextEditingController();
  final _catatanController = TextEditingController();

  late List<Category> _daftarKategori;
  late List<AssetModel> _daftarAset;

  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;
  AssetModel? _selectedAsset;
  String _catatan = '';

  // Getter untuk mengecek apakah sedang dalam mode edit
  bool get _isEditMode => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();
    _setupEditData();
    _fetchInitialData();
  }

  // Jika masuk dalam mode Edit, isi form dengan data lama
  void _setupEditData() {
    if (_isEditMode) {
      final tx = widget.existingTransaction!;
      _isExpense = tx.type == 'expense';
      _totalController.text = tx.amount.toString();
      _catatan = tx.description ?? '';
      _selectedDate = tx.date;
    }
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
      
      final results = await Future.wait([
        ApiService.getCategories(token),
        ApiService.getAssets(token),
      ]);

      if (mounted) {
        setState(() {
          _daftarKategori = results[0] as List<Category>;
          _daftarAset = results[1] as List<AssetModel>;
          
          if (_isEditMode) {
            // Cocokkan ID Kategori lama dengan daftar yang baru ditarik
            try {
              _selectedCategory = _daftarKategori.firstWhere(
                (c) => c.id == widget.existingTransaction!.category.id
              );
            } catch (e) {}
          } else {
            // Jika mode tambah, pilih yang pertama (default)
            if (_daftarKategori.isNotEmpty) _selectedCategory = _daftarKategori.first;
            if (_daftarAset.isNotEmpty) _selectedAsset = _daftarAset.first;
          }
          
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
        categoryId: _selectedCategory!.id,
        amount: int.parse(_totalController.text),
        type: _isExpense ? 'expense' : 'income',
        date: _selectedDate,
        assetId: _selectedAsset?.id,
        description: _catatan,
      );

      if (_isEditMode) {
        // Panggil fungsi Update API
        await ApiService.updateTransaction(token, widget.existingTransaction!.id, transactionData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil diperbarui!')));
        }
      } else {
        // Panggil fungsi Create API
        await ApiService.createTransaction(token, transactionData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil disimpan!')));
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya dan kirim sinyal 'true' untuk refresh data
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
          controller: _catatanController, 
          autofocus: true, 
          decoration: const InputDecoration(hintText: 'Masukkan catatan...'),
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
        // Judul AppBar berubah secara dinamis
        title: Text(_isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi', style: AppTheme.heading2),
        backgroundColor: AppTheme.surface,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                children: [
                  _buildTypeSelector(),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildFormFields(),
                ],
              ),
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
        // Total menggunakan TextField Native
        TextField(
          controller: _totalController,
          keyboardType: TextInputType.number, // Memanggil numpad native Android/iOS
          style: TextStyle(
            fontSize: 28, 
            fontWeight: FontWeight.bold, 
            color: _isExpense ? AppTheme.expense : AppTheme.income
          ),
          decoration: InputDecoration(
            labelText: 'Total Transaksi',
            prefixText: 'Rp ',
            prefixStyle: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: _isExpense ? AppTheme.expense : AppTheme.income
            ),
            border: const UnderlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        
        _buildInputRow('Tanggal', DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate), () => _selectDate(context)),
        const Divider(),
        _buildInputRow('Kategori', _selectedCategory?.name ?? 'Pilih Kategori', _pilihKategori),
        const Divider(),
        _buildInputRow('Catatan', _catatan.isEmpty ? 'Ketuk untuk menambah' : _catatan, _tambahCatatan),
        const Divider(),
        _buildInputRow('Aset', _selectedAsset?.assetName ?? 'Pilih Aset', _pilihAset),
        
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _isSaving ? null : _simpanTransaksi,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
          ),
          child: _isSaving
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              // Teks tombol berubah secara dinamis
              : Text(_isEditMode ? 'UPDATE TRANSAKSI' : 'SIMPAN', style: AppTheme.buttonText),
        ),
      ],
    );
  }
    
  Widget _buildInputRow(String label, String value, VoidCallback? onTap) {
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
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
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
}