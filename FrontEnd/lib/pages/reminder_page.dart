import 'package:daily_cashapp/pages/halaman_crud/tambah_reminder.dart';
import 'package:daily_cashapp/view/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';
import '../service/api.service.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  Future<List<ReminderModel>>? _remindersFuture;
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      if (mounted) {
        setState(() {
          _remindersFuture = null; 
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _remindersFuture = ApiService.getReminders(token, _currentMonth);
      });
    }
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahReminderPage()),
    );
    if (result == true && mounted) {
      _fetchReminders(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
        title: const Text('Reminder'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateAndRefresh,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_remindersFuture == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Silakan login untuk melihat reminder."),
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

    return FutureBuilder<List<ReminderModel>>(
      future: _remindersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child:
                  Text('Gagal memuat data. Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada pengingat untuk bulan ini.\nTekan tombol (+) untuk menambahkan.',
              textAlign: TextAlign.center,
            ),
          );
        }

        final reminders = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _fetchReminders,
          child: ListView.builder(
            padding: const EdgeInsets.all(8), 
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              
              // 1. Bungkus Card dengan Dismissible untuk Swipe-to-Delete
              return Dismissible(
                key: Key(reminder.id.toString()),
                direction: DismissDirection.endToStart,
                
                // Dialog Konfirmasi Hapus
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Hapus Pengingat?"),
                        content: Text("Yakin ingin menghapus pengingat '${reminder.description}'?"),
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
                      await ApiService.deleteReminder(token, reminder.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pengingat berhasil dihapus')),
                        );
                        _fetchReminders();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menghapus: $e')),
                        );
                        _fetchReminders(); // Refresh list jika gagal
                      }
                    }
                  }
                },
                
                // Latar belakang merah saat di-swipe
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Samakan margin dengan Card
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  // 2. Gunakan InkWell agar kartu bisa diklik untuk masuk ke Edit Mode
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12), // Sesuaikan efek ripple dengan sudut kartu
                    onTap: () async {
                      // Navigasi ke halaman form dengan mengirimkan data lama
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TambahReminderPage(existingReminder: reminder),
                        ),
                      );

                      if (result == true && mounted) {
                        _fetchReminders(); // Refresh jika ada data yang di-update
                      }
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- Bagian Kiri (Ikon) ---
                          CircleAvatar(
                            backgroundColor: Colors.amber.shade100,
                            child: Icon(Icons.notifications_active,
                                color: Colors.amber.shade800),
                          ),
                          const SizedBox(width: 12),

                          // --- Bagian Tengah (Deskripsi dan Jumlah) ---
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.description,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rp ${NumberFormat.decimalPattern('id').format(reminder.amount)}",
                                  style: TextStyle(
                                      color: Colors.grey.shade700, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // --- Bagian Kanan (Tanggal dan Periode) ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy', 'id')
                                    .format(reminder.date),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 5),
                              Chip(
                                label: Text(reminder.period),
                                visualDensity: const VisualDensity(
                                    horizontal: 0.0, vertical: -4),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                labelStyle: const TextStyle(fontSize: 10),
                                backgroundColor: Colors.blue.shade50,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}