import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';

class BudgetTab extends StatelessWidget {
  final Budget budget;
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  BudgetTab({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentUsed = (budget.total > 0)
        ? (budget.spent / budget.total).clamp(0.0, 1.0)
        : 0.0;
    final percentText = NumberFormat.decimalPercentPattern(
      locale: 'id',
      decimalDigits: 1,
    ).format(percentUsed);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Row(
            children: const [
              Icon(Icons.note_alt_outlined),
              SizedBox(width: 8),
              Text(
                'Anggaran',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Container dengan kategori hingga info box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori
                Text(
                  budget.category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),

                // Total Anggaran
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Anggaran Bulan ini'),
                    Text(
                      currencyFormatter.format(budget.total),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress
                LinearProgressIndicator(
                  value: percentUsed,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(currencyFormatter.format(budget.spent)),
                    Text(currencyFormatter.format(budget.total)),
                  ],
                ),
                const SizedBox(height: 16),

                // Info box
                Container(
                  width: double.infinity,
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
                          Text(percentText),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Batas pengeluaran harian'),
                          Text(currencyFormatter.format(budget.dailyLimit)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
