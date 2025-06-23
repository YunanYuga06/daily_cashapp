// daily_cashapp/FrontEnd/lib/pages/transaksi_page.dart

import 'package:daily_cashapp/pages/halaman_crud/tambah_anggaran.dart';
import 'package:daily_cashapp/pages/halaman_crud/tambah_transaksi.dart';
import 'package:daily_cashapp/pages/transaksi_bulanan.dart';
import 'package:daily_cashapp/pages/transaksi_harian.dart';
import 'package:daily_cashapp/widgets/dahboard_tab.dart';
import 'package:flutter/material.dart';
import '../widgets/budget_tab.dart';
import '../widgets/app_bar.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage>
    with SingleTickerProviderStateMixin {
  DateTime _currentMonth = DateTime.now();
  late final TabController _tabController;

  var _budgetTabKey = UniqueKey();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _incrementMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
      );
    });
  }

  void _decrementMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
      );
    });
  }

  Future<void> _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAnggaran()),
    );

    if (result == true) {
      setState(() {
        _budgetTabKey = UniqueKey();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildTransaksiAppBar(
        currentMonth: _currentMonth,
        onNextMonth: _incrementMonth,
        onPreviousMonth: _decrementMonth,
        tabController: _tabController,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TransaksiHarian(), // HAPUS 'const' DI SINI
          TransaksiBulanan(), // HAPUS 'const' DI SINI
          // --- LANGKAH 2.2: Hapus 'const' dan gunakan Key ---
          BudgetTab(key: _budgetTabKey),
          const DashboardTab(),
        ],
      ),
      floatingActionButton:
          (_tabController.index == 0 || _tabController.index == 2)
              ? FloatingActionButton(
                  onPressed: () {
                    if (_tabController.index == 0) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TambahTransaksi())); // HAPUS 'const' DI SINI
                    } else {
                      _navigateAndRefresh();
                    }
                  },
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }
}