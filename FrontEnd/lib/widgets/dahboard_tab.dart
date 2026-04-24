import 'package:daily_cashapp/config/app_theme.dart';
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
  int _selectedChart = 0; // 0 = income, 1 = expense
  int? _touchedIndex;

  final NumberFormat _cur = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<Color> _incomeColors = [
    AppColors.income,
    AppColors.primary,
    AppColors.primaryLight,
    Color(0xFF52D9BC),
    Color(0xFF7B94F9),
  ];
  final List<Color> _expenseColors = [
    AppColors.expense,
    AppColors.warning,
    Color(0xFFFF9A9A),
    Color(0xFFFFCA80),
    Color(0xFFFF7043),
  ];

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  @override
  void didUpdateWidget(DashboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth.month != widget.currentMonth.month ||
        oldWidget.currentMonth.year != widget.currentMonth.year) {
      _fetchSummary();
    }
  }

  Future<void> _fetchSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && mounted) {
      setState(() {
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
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return _buildEmptyState();
        }
        return _buildContent(snapshot.data!);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: Icon(
                Icons.bar_chart_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tidak ada data transaksi',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Mulai tambahkan transaksi untuk\nmelihat ringkasan bulan ini.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: Icon(
                Icons.cloud_off_outlined,
                size: 72,
                color: AppColors.expense,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Gagal memuat data', style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SummaryModel summary) {
    final monthLabel = DateFormat.yMMMM('id').format(widget.currentMonth);

    final totalIncome = summary.totalIncome == 0 ? 1 : summary.totalIncome;
    final incomeChartData =
        summary.incomeByCategory.map((e) {
          final percent = (e.totalAmount / totalIncome) * 100;
          return _SectionData(e.categoryName, percent, e.totalAmount);
        }).toList();

    final totalExpense = summary.totalExpense == 0 ? 1 : summary.totalExpense;
    final expenseChartData =
        summary.expenseByCategory.map((e) {
          final percent = (e.totalAmount / totalExpense) * 100;
          return _SectionData(e.categoryName, percent, e.totalAmount);
        }).toList();

    final chartData = _selectedChart == 0 ? incomeChartData : expenseChartData;
    final chartColors = _selectedChart == 0 ? _incomeColors : _expenseColors;
    final isIncomeMode = _selectedChart == 0;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchSummary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(summary, monthLabel),
            const SizedBox(height: AppSpacing.lg),
            Text('Distribusi Kategori', style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.md),
            _buildToggle(isIncomeMode),
            const SizedBox(height: AppSpacing.lg),
            if (chartData.isEmpty)
              _buildChartEmpty()
            else
              _buildChartSection(chartData, chartColors),
            if (chartData.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildLegend(chartData, chartColors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(SummaryModel summary, String monthLabel) {
    final net = summary.totalNet;
    final isPositive = net >= 0;

    return Container(
      width: double.infinity,
      decoration: AppDecorations.gradientCard(
        gradient: AppColors.primaryGradient,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  monthLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  label: 'Pemasukan',
                  amount: summary.totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  iconBg: AppColors.income,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSummaryMetric(
                  label: 'Pengeluaran',
                  amount: summary.totalExpense,
                  icon: Icons.arrow_upward_rounded,
                  iconBg: AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 1,
            color: AppColors.textOnPrimary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Bersih',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                ),
              ),
              Text(
                _cur.format(net),
                style: AppTextStyles.amountMedium.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: isPositive ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String label,
    required int amount,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: AppColors.textOnPrimary),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _cur.format(amount),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(bool isIncomeMode) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          _buildToggleOption(
            label: 'Pemasukan',
            index: 0,
            isSelected: isIncomeMode,
            selectedColor: AppColors.income,
          ),
          _buildToggleOption(
            label: 'Pengeluaran',
            index: 1,
            isSelected: !isIncomeMode,
            selectedColor: AppColors.expense,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required int index,
    required bool isSelected,
    required Color selectedColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap:
            () => setState(() {
              _selectedChart = index;
              _touchedIndex = null;
            }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.xs + 2),
            boxShadow: isSelected ? AppShadows.card : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? selectedColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Opacity(
            opacity: 0.3,
            child: Icon(
              Icons.donut_large_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tidak ada data untuk ditampilkan',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<_SectionData> chartData, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                sections: List.generate(chartData.length, (i) {
                  final e = chartData[i];
                  final isTouched = _touchedIndex == i;
                  return PieChartSectionData(
                    value: e.amount.toDouble(),
                    title: isTouched ? '${e.percent.toStringAsFixed(1)}%' : '',
                    radius: isTouched ? 90 : 75,
                    titleStyle: AppTextStyles.buttonSmall,
                    color: colors[i % colors.length],
                    badgeWidget: isTouched ? null : null,
                  );
                }),
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      setState(() => _touchedIndex = null);
                      return;
                    }
                    setState(() {
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
          ),
          // Center label shown below when a section is tapped
          if (_touchedIndex != null && _touchedIndex! < chartData.length) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(chartData[_touchedIndex!].name, style: AppTextStyles.heading3),
            Text(
              _cur.format(chartData[_touchedIndex!].amount),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors[_touchedIndex! % colors.length],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend(List<_SectionData> chartData, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rincian Kategori', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(chartData.length, (i) {
            final e = chartData[i];
            final color = colors[i % colors.length];
            final isTouched = _touchedIndex == i;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color:
                    isTouched
                        ? color.withValues(alpha: 0.08)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      e.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _cur.format(e.amount),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${e.percent.toStringAsFixed(1)}%',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
