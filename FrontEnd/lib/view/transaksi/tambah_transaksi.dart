// File: lib/habib/tambah_transaksi.dart

import 'package:flutter/material.dart';

class TambahTransaksi extends StatefulWidget {
  const TambahTransaksi({super.key});

  @override
  State<TambahTransaksi> createState() => _TambahTransaksiState();
}

class _TambahTransaksiState extends State<TambahTransaksi> {
  bool isPemasukan = true;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
                  ),
                  onPressed: () => setState(() => isPemasukan = true),
                  child: const Text('Pemasukan'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isPemasukan ? Colors.red : Colors.grey[300],
                  ),
                  onPressed: () => setState(() => isPemasukan = false),
                  child: const Text('Pengeluaran'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...['Tanggal', 'Kategori', 'Catatan', 'Aset', 'Total']
                .map((field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: field,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ))
                .toList(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('SIMPAN'),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Keypad')),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...List.generate(9, (i) => i + 1).map((e) => KeyButton(label: '$e')),
                const SizedBox(),
                const KeyButton(label: '0'),
                const Icon(Icons.backspace_outlined),
              ],
            )
          ],
        ),
      ),
    );
  }
}

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
