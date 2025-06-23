import 'package:daily_cashapp/service/api.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetTab extends StatefulWidget {
  const BudgetTab({Key? key}) : super(key: key);

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
        _budgetsFuture = ApiService.getBudgets(authToken);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_budgetsFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<BudgetModel>>(
      future: _budgetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Gagal memuat data.\nPesan: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Anda belum memiliki anggaran.\nTekan tombol (+) untuk menambahkan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        final budgets = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _fetchBudgets,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _buildBudgetCard(budget);
            },
          ),
        );
      },
    );
  }
  Widget _buildBudgetCard(BudgetModel budget) {
    final double spent = budget.amount * 0.45;
    final double total = budget.amount.toDouble();
    final double percentUsed = (total > 0) ? (spent / total).clamp(0.0, 1.0) : 0.0;
    

    final remainingDays = budget.lastPeriod.difference(DateTime.now()).inDays.clamp(1, 365);
    final dailyLimit = (total - spent) / remainingDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget.category.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Anggaran'),
                Text(
                  currencyFormatter.format(total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
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