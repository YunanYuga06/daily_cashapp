// lib/pages/transaksi_page.dart

import 'package:daily_cashapp/pages/halaman_crud/tambah_anggaran.dart';
import 'package:daily_cashapp/pages/halaman_crud/tambah_transaksi.dart';
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
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late final TabController _tabController;

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
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _decrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  Future<void> _navigateAndRefreshBudget() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAnggaran()),
    );
    if (result == true && mounted) {
      setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
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
          const Center(child: Text('Halaman Harian')),
          const Center(child: Text('Halaman Bulanan')),
          BudgetTab(currentMonth: _currentMonth),
          DashboardTab(currentMonth: _currentMonth),
        ],
      ),
      floatingActionButton:
          (_tabController.index == 2)
              ? FloatingActionButton(
                  onPressed: () {
                    if (_tabController.index == 2) {
                      _navigateAndRefreshBudget();
                    } 
                  },
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }
}