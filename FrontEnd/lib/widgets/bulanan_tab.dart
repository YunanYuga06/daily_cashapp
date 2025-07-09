// daily_cashapp/FrontEnd/lib/widgets/bulanan_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaksi_model.dart';
import '../service/api.service.dart';

// Kelas helper untuk menyimpan ringkasan mingguan
class WeeklyTransactionSummary {
  final DateTime startDate;
  final DateTime endDate;
  final int totalIncome;
  final int totalExpense;

  WeeklyTransactionSummary({
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpense,
  });
}

class BulananTab extends StatefulWidget {
  final DateTime currentMonth;

  const BulananTab({Key? key, required this.currentMonth}) : super(key: key);

  @override
  State<BulananTab> createState() => _BulananTabState();
}

class _BulananTabState extends State<BulananTab> {
  Future<List<TransactionModel>>? _transactionsFuture;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  @override
  void didUpdateWidget(covariant BulananTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMonth.month != oldWidget.currentMonth.month ||
        widget.currentMonth.year != oldWidget.currentMonth.year) {
      _fetchTransactions();
    }
  }

  Future<void> _fetchTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && mounted) {
      setState(() {
        _transactionsFuture = ApiService.getTransactions(
          token,
          year: widget.currentMonth.year,
          month: widget.currentMonth.month,
        );
      });
    }
  }

  // LOGIKA BARU: Mengelompokkan transaksi ke dalam minggu
  List<WeeklyTransactionSummary> _groupTransactionsByWeek(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return [];

    List<WeeklyTransactionSummary> weeklySummaries = [];
    DateTime firstDayOfMonth = DateTime(widget.currentMonth.year, widget.currentMonth.month, 1);
    DateTime lastDayOfMonth = DateTime(widget.currentMonth.year, widget.currentMonth.month + 1, 0);

    // Mulai dari minggu pertama di bulan ini
    DateTime weekStart = firstDayOfMonth;
    while (weekStart.isBefore(lastDayOfMonth)) {
      // Akhir minggu adalah 6 hari setelah awal minggu, atau hari terakhir bulan
      DateTime weekEnd = weekStart.add(const Duration(days: 6));
      if (weekEnd.isAfter(lastDayOfMonth)) {
        weekEnd = lastDayOfMonth;
      }

      int weeklyIncome = 0;
      int weeklyExpense = 0;

      for (var transaction in transactions) {
        // Cek apakah transaksi berada dalam rentang minggu ini
        if (!transaction.date.isBefore(weekStart) && !transaction.date.isAfter(weekEnd.add(const Duration(days: 1)))) {
          if (transaction.type == 'income') {
            weeklyIncome += transaction.amount;
          } else {
            weeklyExpense += transaction.amount;
          }
        }
      }
      
      // Hanya tambahkan ke list jika ada aktivitas di minggu tersebut
      if (weeklyIncome > 0 || weeklyExpense > 0) {
        weeklySummaries.add(WeeklyTransactionSummary(
          startDate: weekStart,
          endDate: weekEnd,
          totalIncome: weeklyIncome,
          totalExpense: weeklyExpense,
        ));
      }
      
      // Lanjut ke minggu berikutnya
      weekStart = weekEnd.add(const Duration(days: 1));
    }
    
    return weeklySummaries.reversed.toList(); // Balik urutan agar minggu terbaru di atas
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransactionModel>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada transaksi untuk bulan ini.'));
        }

        final transactions = snapshot.data!;
        final weeklyData = _groupTransactionsByWeek(transactions);
        
        final totalIncome = transactions.where((t) => t.type == 'income').fold(0, (sum, item) => sum + item.amount);
        final totalExpense = transactions.where((t) => t.type == 'expense').fold(0, (sum, item) => sum + item.amount);
        
        return Column(
          children: [
            _buildOverallSummary(totalIncome, totalExpense),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchTransactions,
                child: ListView.builder(
                  itemCount: weeklyData.length,
                  itemBuilder: (context, index) {
                    return _buildWeekSummaryTile(weeklyData[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverallSummary(int income, int expense) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: Colors.amber.shade100,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem("Pemasukan", _currencyFormatter.format(income)),
            _buildSummaryItem("Pengeluaran", _currencyFormatter.format(expense)),
            _buildSummaryItem("Total", _currencyFormatter.format(income - expense)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(amount, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildWeekSummaryTile(WeeklyTransactionSummary summary) {
    final format = DateFormat('dd.MM');
    final dateRangeText = '${format.format(summary.startDate)} - ${format.format(summary.endDate)}';
    
    return ListTile(
      title: Text(dateRangeText),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currencyFormatter.format(summary.totalIncome), 
            style: const TextStyle(color: Colors.blue)
          ),
          const SizedBox(width: 16),
          Text(
            _currencyFormatter.format(summary.totalExpense), 
            style: const TextStyle(color: Colors.red)
          ),
        ],
      ),
    );
  }
}