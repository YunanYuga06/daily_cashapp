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
    // Cek jika widget masih terpasang sebelum melakukan operasi async
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      if (mounted) {
        setState(() {
          _remindersFuture = null; // Set ke null jika tidak ada token
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
      MaterialPageRoute(builder: (context) => TambahReminderPage()),
    );
    if (result == true && mounted) {
      _fetchReminders(); // Panggil ulang untuk memuat data baru
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
    // Jika _remindersFuture null (karena tidak login), tampilkan pesan
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

    // Gunakan FutureBuilder jika sudah login
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
            padding: const EdgeInsets.all(8), // Padding untuk seluruh list
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
              );
            },
          ),
        );
      },
    );
  }
}