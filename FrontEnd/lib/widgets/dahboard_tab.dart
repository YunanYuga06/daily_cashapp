import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaksi_model.dart';
import '../service/api.service.dart';

class _SectionData {
  final String name;
  final double percent;
  final int amount;
  _SectionData(this.name, this.percent, this.amount);
}

class DashboardTab extends StatefulWidget {
  final DateTime currentMonth;
  const DashboardTab({super.key, required this.currentMonth});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  Future<SummaryModel>? _summaryFuture;
  int _selectedChart = 0;

  final NumberFormat _cur = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<Color> _incomeColors = [ Colors.blue, Colors.purple, Colors.lightBlueAccent, Colors.indigo ];
  final List<Color> _expenseColors = [ Colors.red, Colors.orange, Colors.green, Colors.brown ];

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  // 2. Method ini akan terpanggil setiap kali `currentMonth` dari parent berubah
  @override
  void didUpdateWidget(DashboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cek apakah bulan atau tahunnya berbeda
    if (oldWidget.currentMonth.month != widget.currentMonth.month ||
        oldWidget.currentMonth.year != widget.currentMonth.year) {
      // Jika berbeda, ambil ulang data ringkasan untuk bulan yang baru
      _fetchSummary();
    }
  }

  Future<void> _fetchSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && mounted) {
      setState(() {
        // 3. Gunakan `widget.currentMonth` untuk mengambil data, bukan DateTime.now()
        _summaryFuture = ApiService.getSummary(token, widget.currentMonth);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SummaryModel>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data ringkasan: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Tidak ada data transaksi.'));
        }

        final summary = snapshot.data!;
        return _buildDashboardContent(summary);
      },
    );
  }

  Widget _buildDashboardContent(SummaryModel summary) {
    final monthLabel = DateFormat.yMMMM('id').format(widget.currentMonth);
    
    final totalIncomeForChart = summary.totalIncome == 0 ? 1 : summary.totalIncome;
    final incomeChartData = summary.incomeByCategory.map((e) {
        final percent = (e.totalAmount / totalIncomeForChart) * 100;
        return _SectionData(e.categoryName, percent, e.totalAmount);
    }).toList();

    final totalExpenseForChart = summary.totalExpense == 0 ? 1 : summary.totalExpense;
    final expenseChartData = summary.expenseByCategory.map((e) {
        final percent = (e.totalAmount / totalExpenseForChart) * 100;
        return _SectionData(e.categoryName, percent, e.totalAmount);
    }).toList();

    final chartData = _selectedChart == 0 ? incomeChartData : expenseChartData;
    final chartColors = _selectedChart == 0 ? _incomeColors : _expenseColors;

    return RefreshIndicator(
      onRefresh: _fetchSummary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Ringkasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(monthLabel),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Pemasukan:', summary.totalIncome, Colors.blue),
                  const SizedBox(height: 4),
                  _buildSummaryRow('Pengeluaran:', summary.totalExpense, Colors.red),
                  const Divider(height: 20, thickness: 1),
                  _buildSummaryRow('Total:', summary.totalNet, Colors.black),
                ],
              ),
            ),

            const SizedBox(height: 24),
            ToggleButtons(
              isSelected: [_selectedChart == 0, _selectedChart == 1],
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: _selectedChart == 0 ? Colors.blue : Colors.red,
              onPressed: (i) => setState(() => _selectedChart = i),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Pemasukan')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Pengeluaran')),
              ],
            ),

            const SizedBox(height: 24),
            if (chartData.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text('Tidak ada data untuk ditampilkan di chart.'),
              )
            else
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections: List.generate(chartData.length, (i) {
                      final e = chartData[i];
                      return PieChartSectionData(
                        value: e.amount.toDouble(),
                        title: '${e.percent.toStringAsFixed(0)}%',
                        radius: 80,
                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        color: chartColors[i % chartColors.length],
                      );
                    }),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),

            const SizedBox(height: 16),
            ...List.generate(chartData.length, (i) {
                final e = chartData[i];
                final color = chartColors[i % chartColors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 16, height: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.name)),
                      Text(_cur.format(e.amount)),
                    ],
                  ),
                );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, int amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(
          _cur.format(amount),
          style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}