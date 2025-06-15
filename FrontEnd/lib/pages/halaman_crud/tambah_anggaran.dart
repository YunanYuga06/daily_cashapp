import 'package:flutter/material.dart';

class AddAnggaran extends StatefulWidget {
  const AddAnggaran({super.key});

  @override
  State<AddAnggaran> createState() => _AddAnggaranState();
}

class _AddAnggaranState extends State<AddAnggaran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Anggaran"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Halaman Tambah Transaksi"),
          ],
        ),
      ),
    );
  }
}