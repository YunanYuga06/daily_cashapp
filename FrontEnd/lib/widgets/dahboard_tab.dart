import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // 0 = Pemasukan, 1 = Pengeluaran
  int _selected = 0;

  // Dummy data pemasukan
  final _incomeData = <_SectionData>[
    _SectionData('Gaji Bulanan', 60, 1000000),
    _SectionData('Freelance', 30, 400000),
    _SectionData('Uang Saku', 10, 300000),
  ];

  // Dummy data pengeluaran
  final _expenseData = <_SectionData>[
    _SectionData('Makan', 40, 400000),
    _SectionData('Transport', 35, 350000),
    _SectionData('Hiburan', 25, 250000),
  ];

  // Warna untuk masing‑masing slice pemasukan
  final List<Color> _incomeColors = [
    Colors.blue,
    Colors.purple,
    Colors.lightBlueAccent,
  ];

  // Warna untuk masing‑masing slice pengeluaran
  final List<Color> _expenseColors = [
    Colors.red,
    Colors.orange,
    Colors.green,
  ];

  final NumberFormat _cur = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.yMMMM('id').format(DateTime.now());
    final data = _selected == 0 ? _incomeData : _expenseData;
    final colors = _selected == 0 ? _incomeColors : _expenseColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // === Ringkasan Bulanan ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Ringkasan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(monthLabel),
                    // placeholder lingkaran
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(value: 0),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pemasukan:'),
                    Text(_cur.format(0),
                        style: const TextStyle(color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pengeluaran:'),
                    Text(_cur.format(0),
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:'),
                    Text(_cur.format(0)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // === Toggle Pemasukan / Pengeluaran ===
          ToggleButtons(
            isSelected: [_selected == 0, _selected == 1],
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: Colors.blue,
            onPressed: (i) => setState(() => _selected = i),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Pemasukan'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Pengeluaran'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // === Pie Chart ===
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: List.generate(data.length, (i) {
                  final e = data[i];
                  return PieChartSectionData(
                    value: e.percent.toDouble(),
                    title: '${e.percent}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    color: colors[i % colors.length], // warna per slice
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // === Legend / Table ===
          Column(
            children: List.generate(data.length, (i) {
              final e = data[i];
              final color = colors[i % colors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${e.percent}% ${e.name}')),
                    Text(_cur.format(e.amount)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SectionData {
  final String name;
  final int percent;
  final int amount;
  _SectionData(this.name, this.percent, this.amount);
}
