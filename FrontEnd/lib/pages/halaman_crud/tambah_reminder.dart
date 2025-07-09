import 'package:daily_cashapp/service/api.service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahReminderPage extends StatefulWidget {
  @override
  _TambahReminderPageState createState() => _TambahReminderPageState();
}

class _TambahReminderPageState extends State<TambahReminderPage> {
  int _selectedIndex = 2; // default Tahunan
  final _descriptionController = TextEditingController();
  final _numericController = TextEditingController();

  DateTime? _selectedDate;

  final List<String> _tabs = ['Mingguan', 'Bulanan', 'Tahunan'];

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onKeyTap(String value) {
    setState(() {
      if (value == '⌫') {
        if (_numericController.text.isNotEmpty) {
          _numericController.text = _numericController.text
              .substring(0, _numericController.text.length - 1);
        }
      } else {
        _numericController.text += value;
      }
    });
  }

  Future<void> _saveReminder() async {
    if (_descriptionController.text.isEmpty ||
        _numericController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Deskripsi, jumlah, dan tanggal harus diisi!')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Token tidak ditemukan");

      await ApiService.createReminder(
        token: token,
        description: _descriptionController.text,
        amount: int.parse(_numericController.text),
        period: _tabs[_selectedIndex],
        date: _selectedDate!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengingat berhasil disimpan!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pengingat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tambah Reminder'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_tabs.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedIndex == index
                                ? Colors.blue.shade400
                                : Colors.grey.shade300,
                            foregroundColor: _selectedIndex == index
                                ? Colors.white
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(_tabs[index]),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Tempo',
                        hintText: 'Pilih Tanggal',
                      ),
                      controller: TextEditingController(
                          text: _selectedDate == null
                              ? ''
                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: StadiumBorder(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text('SIMPAN'),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Text(
                    _numericController.text,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F6EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.8,
                    ),
                    itemBuilder: (context, index) {
                      final keys = [
                        '1', '2', '3',
                        '4', '5', '6',
                        '7', '8', '9',
                        '.', '0', '⌫',
                      ];
                      final key = keys[index];
                      return ElevatedButton(
                        onPressed: () => _onKeyTap(key),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: key == '⌫'
                            ? Icon(Icons.backspace_outlined)
                            : Text(
                                key,
                                style: TextStyle(fontSize: 20),
                              ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}