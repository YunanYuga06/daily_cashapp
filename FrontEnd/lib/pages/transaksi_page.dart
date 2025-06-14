import 'package:flutter/material.dart';


import '../models/budget.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/budget_tab.dart';
import '../widgets/app_bar.dart'; // Import appbar custom

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  DateTime _currentMonth = DateTime.now();
  late final TabController _tabController;

  final Budget _lunchBudget = Budget(
    category: 'Buat Makan',
    total: 500000,
    spent: 150000,
    dailyLimit: 20000,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          BudgetTab(budget: _lunchBudget),
          const Center(child: Text('Halaman Dashboard')),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
