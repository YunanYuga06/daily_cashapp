import 'package:daily_cashapp/pages/halaman_crud/tambah_anggaran.dart';
import 'package:daily_cashapp/pages/halaman_crud/tambah_transaksi.dart';
import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/budget_tab.dart';
import '../widgets/dahboard_tab.dart';
import '../widgets/harian_tab.dart';
import '../widgets/bulanan_tab.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage>
    with SingleTickerProviderStateMixin {
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  late final TabController _tabController;

  var _harianTabKey = UniqueKey();
  var _bulananTabKey = UniqueKey();
  var _budgetTabKey = UniqueKey();
  var _dashboardTabKey = UniqueKey();

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
      _refreshTabs();
    });
  }

  void _decrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _refreshTabs();
    });
  }

  void _refreshTabs() {
    setState(() {
      _harianTabKey = UniqueKey();
      _bulananTabKey = UniqueKey();
      _budgetTabKey = UniqueKey();
      _dashboardTabKey = UniqueKey();
    });
  }

  Future<void> _navigateAndMaybeRefresh({required Widget page}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (result == true && mounted) {
      _refreshTabs();
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
          HarianTab(key: _harianTabKey, currentMonth: _currentMonth),
          BulananTab(key: _bulananTabKey, currentMonth: _currentMonth),
          BudgetTab(key: _budgetTabKey, currentMonth: _currentMonth),
          DashboardTab(key: _dashboardTabKey, currentMonth: _currentMonth),
        ],
      ),
      floatingActionButton:
          (_tabController.index == 0 || _tabController.index == 2)
              ? Padding(
                padding: const EdgeInsets.only(bottom: 70.0),
                child: FloatingActionButton(
                  onPressed: () {
                    if (_tabController.index == 0) {
                      // Tab Harian/Bulanan
                      _navigateAndMaybeRefresh(page: const AddTransaksi());
                    } else if (_tabController.index == 2) {
                      // Tab Anggaran
                      _navigateAndMaybeRefresh(page: const AddAnggaran());
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              )
              : null,
    );
  }
}
