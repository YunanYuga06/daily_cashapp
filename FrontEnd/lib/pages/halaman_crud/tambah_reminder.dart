import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/service/api.service.dart';
import 'package:daily_cashapp/models/reminder_model.dart'; 

class TambahReminderPage extends StatefulWidget {
  final ReminderModel? existingReminder; 

  const TambahReminderPage({super.key, this.existingReminder});

  @override
  State<TambahReminderPage> createState() => _TambahReminderPageState();
}

class _TambahReminderPageState extends State<TambahReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'Sekali'; 
  bool _isSaving = false;

  bool get _isEditMode => widget.existingReminder != null;

  // Daftar opsi periode yang bisa dipilih
  final List<String> _periodOptions = [
    'Sekali',
    'Harian',
    'Mingguan',
    'Bulanan',
    'Tahunan'
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _descController.text = widget.existingReminder!.description;
      _amountController.text = widget.existingReminder!.amount.toString();
      _selectedDate = widget.existingReminder!.date;
      
      // Pastikan periode lama ada di dalam daftar opsi kita
      if (_periodOptions.contains(widget.existingReminder!.period)) {
        _selectedPeriod = widget.existingReminder!.period;
      } else {
        _selectedPeriod = 'Sekali'; 
      }
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) throw Exception('Token tidak ditemukan');

      if (_isEditMode) {
        await ApiService.updateReminder(
          token: token,
          id: widget.existingReminder!.id,
          description: _descController.text,
          amount: int.parse(_amountController.text),
          period: _selectedPeriod, // Mengirimkan periode yang dipilih
          date: _selectedDate,
        );
      } else {
        await ApiService.createReminder(
          token: token,
          description: _descController.text,
          amount: int.parse(_amountController.text),
          period: _selectedPeriod, // Mengirimkan periode yang dipilih
          date: _selectedDate,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengingat berhasil disimpan!'))
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Pengingat' : 'Tambah Pengingat', style: AppTheme.heading2),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi', 
                  hintText: 'Cth: Tagihan Listrik, Cicilan Motor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number, 
                decoration: const InputDecoration(
                  labelText: 'Nominal', 
                  prefixText: 'Rp ', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              // --- FITUR DROPDOWN PERIODE DITAMBAHKAN DI SINI ---
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                decoration: const InputDecoration(
                  labelText: 'Periode Pengulangan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: _periodOptions.map((period) {
                  return DropdownMenuItem(value: period, child: Text(period));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPeriod = val);
                },
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  title: const Text("Tanggal Tagihan"),
                  subtitle: Text(DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, 
                      initialDate: _selectedDate, 
                      firstDate: DateTime.now(), 
                      lastDate: DateTime(2030)
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isSaving ? null : _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue, 
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : Text(_isEditMode ? 'UPDATE PENGINGAT' : 'SIMPAN PENGINGAT', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}