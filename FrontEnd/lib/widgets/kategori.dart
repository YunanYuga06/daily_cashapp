import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget.dart'; // Sesuaikan jika model Category ada di file lain
import '../service/api.service.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  Future<List<Category>>? _kategoriFuture;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  void _fetchKategori() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && mounted) {
      setState(() {
        _kategoriFuture = ApiService.getCategories(token);
      });
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    // Menggunakan 'expense'/'income' sesuai standar tabel transaksi baru Anda
    String selectedType = 'expense'; 

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Tambah Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  hintText: 'Cth: Skincare, Jajan, dll',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipe'),
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                  DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                ],
                onChanged: (val) {
                  if (val != null) setStateDialog(() => selectedType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                Navigator.pop(context); // Tutup dialog dulu
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menyimpan kategori...')),
                );

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('auth_token')!;
                
                // MENGGUNAKAN TRY-CATCH KARENA API BARU MELEMPAR EXCEPTION
                try {
                  await ApiService.createCategory(
                    token: token,
                    name: nameController.text.trim(),
                    type: selectedType,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kategori berhasil ditambahkan!')),
                    );
                    _fetchKategori(); // Refresh daftar kategori
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menambahkan kategori: $e')),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
        backgroundColor: Colors.orange,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Category>>(
        future: _kategoriFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada kategori.'));
          }

          final kategoriList = snapshot.data!;

          return ListView.builder(
            itemCount: kategoriList.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final kategori = kategoriList[index];
              final isIncome = kategori.type == 'IN' || kategori.type == 'income'; 

              return Dismissible(
                key: Key(kategori.id.toString()), 
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Kategori?'),
                      content: Text('Yakin ingin menghapus "${kategori.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('auth_token')!;
                  
                  // MENGGUNAKAN TRY-CATCH UNTUK DELETE
                  try {
                    await ApiService.deleteCategory(token, kategori.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kategori dihapus')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus: $e')),
                      );
                      // Refresh jika gagal dihapus (misal karena terikat dengan data transaksi)
                      _fetchKategori(); 
                    }
                  }
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(kategori.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(isIncome ? 'Pemasukan' : 'Pengeluaran'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}