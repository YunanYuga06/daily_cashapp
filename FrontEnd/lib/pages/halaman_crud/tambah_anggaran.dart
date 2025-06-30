import 'package:daily_cashapp/models/asset_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/budget.dart';
import '../../service/api.service.dart';

class AddAnggaran extends StatefulWidget {
  const AddAnggaran({super.key});

  @override
  State<AddAnggaran> createState() => _AddAnggaranState();
}

class _AddAnggaranState extends State<AddAnggaran> {
  final _formKey = GlobalKey<FormState>();
  final _totalController = TextEditingController();
  final _catatanController = TextEditingController();


  String? _selectedPriority = 'Sedang';
  final List<String> _priorities = ['Tinggi', 'Sedang', 'Rendah'];

  DateTimeRange? _selectedDateRange;
  Category? _selectedCategory;
  AssetModel? _selectedAsset;
  List<Category> _categories = [];
  List<AssetModel> _assets = [];
  
  bool _isLoading = true;
  bool _isSaving = false;

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
    setState(() { _isLoading = true; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      final fetchedCategories = await ApiService.getCategories(token);
      final fetchedAssets = await ApiService.getAssets(token);
      
      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
          _assets = fetchedAssets;
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  void _pickDateRange() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDateRange ?? DateTimeRange(start: firstDayOfMonth, end: lastDayOfMonth),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _simpanAnggaran() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      if (_selectedDateRange == null || _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanggal dan Kategori wajib diisi!')),
        );
        return;
      }
      
      setState(() { _isSaving = true; });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token == null) throw Exception("Token tidak ditemukan");

        await ApiService.createBudget(
          token: token,
          categoryId: _selectedCategory!.id,
          amount: int.parse(_totalController.text.replaceAll('.', '')),
          priority: _selectedPriority,
          assetId: _selectedAsset?.id,
          note: _catatanController.text,
          startDate: _selectedDateRange!.start,
          endDate: _selectedDateRange!.end,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggaran berhasil disimpan!')),
        );
        Navigator.pop(context, true);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      } finally {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Anggaran"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildForm(),
    );
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildDateField(),
          const SizedBox(height: 20),
          _buildCategoryDropdown(),
          const SizedBox(height: 20),
          _buildAssetDropdown(),
          const SizedBox(height: 20),
          TextFormField(
            controller: _catatanController,
            decoration: const InputDecoration(
              labelText: 'Catatan (Opsional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_alt_outlined),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          const Text('Prioritas', style: TextStyle(fontSize: 16, color: Colors.black54)),
          Column(
            children: _priorities.map((priority) {
              return RadioListTile<String>(
                title: Text(priority),
                value: priority,
                groupValue: _selectedPriority,
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          TextFormField(
            controller: _totalController,
            decoration: const InputDecoration(
              labelText: 'Total Anggaran',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Total tidak boleh kosong';
              }
              if (int.tryParse(value.replaceAll('.', '')) == null) {
                return 'Masukkan angka yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _simpanAnggaran,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  )
                : const Text('SIMPAN', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    final dateFormat = DateFormat('d MMM yyyy', 'id');
    final String dateText = _selectedDateRange == null
        ? ''
        : '${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}';

    return TextFormField(
      readOnly: true,
      onTap: _pickDateRange,
      decoration: InputDecoration(
        labelText: 'Periode Anggaran',
        hintText: 'Pilih rentang tanggal',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(text: dateText),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Kategori',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      hint: const Text('Pilih Kategori'),
      items: _categories.map((category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) => value == null ? 'Kategori wajib diisi' : null,
    );
  }

  Widget _buildAssetDropdown() {
    return DropdownButtonFormField<AssetModel>(
      value: _selectedAsset,
      decoration: const InputDecoration(
        labelText: 'Aset (Opsional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
      ),
      hint: const Text('Semua Aset'),
      items: _assets.map((asset) {
        return DropdownMenuItem<AssetModel>(
          value: asset,
          child: Text(asset.assetName),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedAsset = newValue;
        });
      },
    );
  }
}