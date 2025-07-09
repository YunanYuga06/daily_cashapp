import 'package:daily_cashapp/pages/halaman_crud/edit_anggaran.dart';
import 'package:daily_cashapp/service/api.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetTab extends StatefulWidget {
  final DateTime currentMonth; // Menerima state bulan
  const BudgetTab({super.key, required this.currentMonth});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  Future<List<BudgetModel>>? _budgetsFuture;

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  @override
  void didUpdateWidget(BudgetTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth.month != widget.currentMonth.month ||
        oldWidget.currentMonth.year != widget.currentMonth.year) {
      _fetchBudgets();
    }
  }
  
  Future<void> _fetchBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');
    if (authToken == null || authToken.isEmpty) {
      if (mounted) {
        setState(() {
          _budgetsFuture = Future.error(
            Exception("Sesi tidak valid. Silakan login kembali."),
          );
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _budgetsFuture = ApiService.getBudgets(authToken, widget.currentMonth);
      });
    }
  }

  Future<void> _deleteBudget(int budgetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token')!;
      await ApiService.deleteBudget(token, budgetId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anggaran berhasil dihapus')),
      );
      _fetchBudgets();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, BudgetModel budget) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus anggaran untuk "${budget.category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteBudget(budget.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BudgetModel>>(
      future: _budgetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data anggaran.\n${snapshot.error}', textAlign: TextAlign.center));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Tidak ada anggaran untuk bulan ini.\nTekan tombol (+) untuk menambahkan.', textAlign: TextAlign.center),
          );
        }
        final budgets = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _fetchBudgets,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) => _buildBudgetCard(budgets[index]),
          ),
        );
      },
    );
  }

  Widget _buildBudgetCard(BudgetModel budget) {
    final double spent = budget.spent.toDouble();
    final double total = budget.amount.toDouble();
    final double percentUsed = (total > 0) ? (spent / total).clamp(0.0, 1.0) : 0.0;
    
    final now = DateTime.now();
    final endDate = budget.lastPeriod;
    int remainingDays = endDate.isAfter(now) ? endDate.difference(now).inDays + 1 : 1;
    if (remainingDays <= 0) remainingDays = 1;

    final dailyLimit = (total > spent) ? ((total - spent) / remainingDays) : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    budget.category.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditAnggaranPage(budget: budget)),
                      );
                      if (result == true) _fetchBudgets();
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, budget);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem<String>(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Anggaran'),
                Text(currencyFormatter.format(total), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentUsed,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(percentUsed > 0.8 ? Colors.red : Colors.green),
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currencyFormatter.format(spent)),
                Text(currencyFormatter.format(total)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sudah digunakan'),
                      Text(NumberFormat.percentPattern().format(percentUsed)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Batas pengeluaran harian'),
                      Text(currencyFormatter.format(dailyLimit)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}