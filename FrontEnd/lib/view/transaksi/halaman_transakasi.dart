// File: lib/habib/halaman_transakasi.dart

import 'package:flutter/material.dart';
import 'transaksi_harian.dart';
import 'transaksi_bulanan.dart';

class HalamanTransaksi extends StatefulWidget {
  const HalamanTransaksi({super.key});

  @override
  State<HalamanTransaksi> createState() => _HalamanTransaksiState();
}

class _HalamanTransaksiState extends State<HalamanTransaksi> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Home (Transaksi)', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'Harian'),
            Tab(text: 'Bulanan'),
            Tab(text: 'Anggaran'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TransaksiHarian(),
          TransaksiBulanan(),
          Center(child: Text('Halaman Anggaran')),
        ],
      ),
    );
  }
}
