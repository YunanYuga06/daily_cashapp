import 'package:daily_cashapp/pages/halaman_crud/tambah_transaksi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaksi_model.dart';
import '../models/budget.dart'; // Category ada di sini
import '../models/asset_model.dart'; // AssetModel ada di sini
import '../service/api.service.dart';

class HarianTab extends StatefulWidget {
  final DateTime currentMonth; 
  
  const HarianTab({Key? key, required this.currentMonth}) : super(key: key);

  @override
  State<HarianTab> createState() => _HarianTabState();
}

class _HarianTabState extends State<HarianTab> {
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
  void didUpdateWidget(covariant HarianTab oldWidget) {
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
        final groupedByDate = _groupTransactionsByDate(transactions);
        final sortedDates = groupedByDate.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return Column(
          children: [
            _buildSummaryCard(transactions),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchTransactions,
                child: ListView.builder(
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final transactionsOnDate = groupedByDate[date]!;
                    return _buildDailyTransactionCard(date, transactionsOnDate);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Map<DateTime, List<TransactionModel>> _groupTransactionsByDate(List<TransactionModel> transactions) {
    final Map<DateTime, List<TransactionModel>> data = {};
    for (var transaction in transactions) {
      final dateOnly = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      if (data[dateOnly] == null) {
        data[dateOnly] = [];
      }
      data[dateOnly]!.add(transaction);
    }
    return data;
  }

  Widget _buildSummaryCard(List<TransactionModel> transactions) {
    final totalIncome = transactions.where((t) => t.type == 'income').fold(0, (sum, item) => sum + item.amount);
    final totalExpense = transactions.where((t) => t.type == 'expense').fold(0, (sum, item) => sum + item.amount);
    final netTotal = totalIncome - totalExpense;

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: Colors.amber.shade100,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem("Pemasukan", _currencyFormatter.format(totalIncome)),
            _buildSummaryItem("Pengeluaran", _currencyFormatter.format(totalExpense)),
            _buildSummaryItem("Total", _currencyFormatter.format(netTotal)),
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
  
  Widget _buildDailyTransactionCard(DateTime date, List<TransactionModel> transactions) {
    final dailyIncome = transactions.where((t) => t.type == 'income').fold(0, (sum, item) => sum + item.amount);
    final dailyExpense = transactions.where((t) => t.type == 'expense').fold(0, (sum, item) => sum + item.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        children: [
           Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('d MMMM yyyy', 'id').format(date), style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(_currencyFormatter.format(dailyIncome), style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(_currencyFormatter.format(dailyExpense), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...transactions.map((tx) => _buildTransactionTile(tx)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel tx) {
    final bool isExpense = tx.type == 'expense';
    return Dismissible(
      key: Key(tx.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Konfirmasi Hapus"),
              content: Text("Apakah Anda yakin ingin menghapus transaksi '${tx.category.name}' sebesar ${_currencyFormatter.format(tx.amount)}?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Hapus",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      
      onDismissed: (direction) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null) {
          try {
            await ApiService.deleteTransaction(token, tx.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaksi berhasil dihapus')),
              );
              _fetchTransactions();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menghapus transaksi: $e')),
              );
              _fetchTransactions();
            }
          }
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransaksi(existingTransaction: tx), 
            ),
          ).then((_) {
            _fetchTransactions();
          });
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: isExpense ? Colors.red : Colors.blue,
            ),
          ),
          title: Text(tx.category.name),
          subtitle: Text(tx.description ?? 'Tanpa Catatan'),
          trailing: Text(
            _currencyFormatter.format(tx.amount),
            style: TextStyle(
              color: isExpense ? Colors.red : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}