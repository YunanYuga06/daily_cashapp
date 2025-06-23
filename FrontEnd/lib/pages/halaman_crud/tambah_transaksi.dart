// daily_cashapp/FrontEnd/lib/pages/halaman_crud/tambah_transaksi.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:shared_preferences/shared_preferences.dart'; // Untuk mendapatkan token
import '../../service/api.service.dart'; // Import ApiService
import '../../models/budget.dart'; // Import Category model
import '../../models/asset_model.dart'; // Import AssetModel

class TambahTransaksi extends StatefulWidget {
  const TambahTransaksi({super.key});

  @override
  State<TambahTransaksi> createState() => _TambahTransaksiState();
}

class _TambahTransaksiState extends State<TambahTransaksi> {
  bool isPemasukan = true; // State untuk memilih pemasukan/pengeluaran
  final _formKey = GlobalKey<FormState>(); // Key untuk form validation
  final _totalController = TextEditingController();
  final _catatanController = TextEditingController();

  DateTime _selectedDate = DateTime.now(); // State untuk tanggal
  Category? _selectedCategory; // State untuk kategori yang dipilih
  AssetModel? _selectedAsset; // State untuk aset yang dipilih

  List<Category> _categories = []; // Daftar kategori dari API
  List<AssetModel> _assets = []; // Daftar aset dari API
  bool _isLoading = true; // Indikator loading data awal
  bool _isSaving = false; // Indikator sedang menyimpan transaksi

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

  // Fungsi untuk mengambil data kategori dan aset dari API
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });
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
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi untuk menyimpan transaksi
  Future<void> _simpanTransaksi() async {
    if (_isSaving) return; // Mencegah klik ganda saat sedang menyimpan

    if (_formKey.currentState!.validate()) {
      // Validasi dropdown
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori wajib diisi!')),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token == null) throw Exception("Token tidak ditemukan");

        await ApiService.createTransaction(
          token: token,
          categoryId: _selectedCategory!.id,
          amount: int.parse(_totalController.text.replaceAll('.', '')), // Hapus titik format ribuan
          assetId: _selectedAsset?.id,
          description: _catatanController.text,
          date: _selectedDate,
          type: isPemasukan ? 'income' : 'expense',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil disimpan!')),
        );
        Navigator.pop(context, true); // Mengirim true sebagai indikasi refresh
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false, // Penting agar tidak mengisi seluruh layar secara default
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPemasukan ? Colors.blue : Colors.grey[300],
                            foregroundColor: isPemasukan ? Colors.white : Colors.black,
                          ),
                          onPressed: () => setState(() => isPemasukan = true),
                          child: const Text('Pemasukan'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isPemasukan ? Colors.red : Colors.grey[300],
                            foregroundColor: !isPemasukan ? Colors.white : Colors.black,
                          ),
                          onPressed: () => setState(() => isPemasukan = false),
                          child: const Text('Pengeluaran'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Field Tanggal
                    TextFormField(
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      controller: TextEditingController(
                          text: DateFormat('dd MMMM yyyy', 'id').format(_selectedDate)),
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dropdown Kategori
                    DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      hint: const Text('Pilih Kategori'),
                      items: _categories
                          .where((cat) => (isPemasukan && cat.type == 'income') || (!isPemasukan && cat.type == 'expense'))
                          .map((category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name),
                            );
                          })
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Kategori wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    // Dropdown Aset
                    DropdownButtonFormField<AssetModel>(
                      value: _selectedAsset,
                      decoration: const InputDecoration(
                        labelText: 'Aset (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance_wallet),
                      ),
                      hint: const Text('Pilih Aset'),
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
                    ),
                    const SizedBox(height: 12),
                    // Field Catatan
                    TextFormField(
                      controller: _catatanController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Field Total
                    TextFormField(
                      controller: _totalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: 'Rp ',
                      ),
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
                    const SizedBox(height: 24),
                    // Tombol SIMPAN
                    ElevatedButton(
                      onPressed: _isSaving ? null : _simpanTransaksi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3, color: Colors.white),
                            )
                          : const Text('SIMPAN', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),
                    // Anda bisa menghapus bagian "Keypad" jika tidak digunakan secara langsung
                    // const Center(child: Text('Keypad')),
                    // GridView.count(
                    //   crossAxisCount: 3,
                    //   shrinkWrap: true,
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   children: [
                    //     ...List.generate(9, (i) => i + 1).map((e) => KeyButton(label: '$e')),
                    //     const SizedBox(),
                    //     const KeyButton(label: '0'),
                    //     const Icon(Icons.backspace_outlined),
                    //   ],
                    // )
                  ],
                ),
              ),
      ),
    );
  }
}

// Class KeyButton (jika masih ingin disimpan, tapi tidak digunakan di kode di atas)
class KeyButton extends StatelessWidget {
  final String label;
  const KeyButton({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}