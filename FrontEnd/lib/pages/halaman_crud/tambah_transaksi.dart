import 'package:flutter/material.dart';

class AddTransaksi extends StatefulWidget {
  const AddTransaksi({super.key});

  @override
  State<AddTransaksi> createState() => _AddTransaksiState();
}

class _AddTransaksiState extends State<AddTransaksi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Catatan"),
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