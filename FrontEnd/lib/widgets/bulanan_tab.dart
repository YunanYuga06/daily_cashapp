import 'package:daily_cashapp/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaksi_model.dart';
import '../service/api.service.dart';

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

  int get net => totalIncome - totalExpense;
}

class BulananTab extends StatefulWidget {
  final DateTime currentMonth;

  const BulananTab({Key? key, required this.currentMonth}) : super(key: key);

  @override
  State<BulananTab> createState() => _BulananTabState();
}

class _BulananTabState extends State<BulananTab> {
  Future<List<TransactionModel>>? _transactionsFuture;

  final NumberFormat _fmt = NumberFormat.currency(
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

  List<WeeklyTransactionSummary> _groupByWeek(
    List<TransactionModel> transactions,
  ) {
    if (transactions.isEmpty) return [];

    final summaries = <WeeklyTransactionSummary>[];
    final firstDay = DateTime(
      widget.currentMonth.year,
      widget.currentMonth.month,
      1,
    );
    final lastDay = DateTime(
      widget.currentMonth.year,
      widget.currentMonth.month + 1,
      0,
    );

    DateTime weekStart = firstDay;
    while (weekStart.isBefore(lastDay) || weekStart.isAtSameMomentAs(lastDay)) {
      DateTime weekEnd = weekStart.add(const Duration(days: 6));
      if (weekEnd.isAfter(lastDay)) weekEnd = lastDay;

      int weeklyIncome = 0;
      int weeklyExpense = 0;

      for (final tx in transactions) {
        final txDay = DateTime(tx.date.year, tx.date.month, tx.date.day);
        if (!txDay.isBefore(weekStart) && !txDay.isAfter(weekEnd)) {
          if (tx.type == 'income' || tx.type == 'pemasukan') {
            weeklyIncome += tx.amount;
          } else {
            weeklyExpense += tx.amount;
          }
        }
      }

      if (weeklyIncome > 0 || weeklyExpense > 0) {
        summaries.add(
          WeeklyTransactionSummary(
            startDate: weekStart,
            endDate: weekEnd,
            totalIncome: weeklyIncome,
            totalExpense: weeklyExpense,
          ),
        );
      }

      weekStart = weekEnd.add(const Duration(days: 1));
    }

    return summaries.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransactionModel>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Gagal memuat data: ${snapshot.error}',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _EmptyState(onRefresh: _fetchTransactions);
        }

        final transactions = snapshot.data!;
        final weeklyData = _groupByWeek(transactions);

        final totalIncome = transactions
            .where((t) => t.type == 'income' || t.type == 'pemasukan')
            .fold(0, (s, t) => s + t.amount);
        final totalExpense = transactions
            .where((t) => t.type == 'expense' || t.type == 'pengeluaran')
            .fold(0, (s, t) => s + t.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero summary card
            _MonthlySummaryCard(
              income: totalIncome,
              expense: totalExpense,
              formatter: _fmt,
              month: widget.currentMonth,
            ),

            // Section label
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Text(
                'Ringkasan per Minggu',
                style: AppTextStyles.heading3,
              ),
            ),

            // Weekly list
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _fetchTransactions,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    80,
                  ),
                  itemCount: weeklyData.length,
                  itemBuilder:
                      (context, index) => _WeekRow(
                        summary: weeklyData[index],
                        index: index,
                        total: weeklyData.length,
                        formatter: _fmt,
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  final int income;
  final int expense;
  final NumberFormat formatter;
  final DateTime month;

  const _MonthlySummaryCard({
    required this.income,
    required this.expense,
    required this.formatter,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final net = income - expense;
    final isPositive = net >= 0;
    final netColor = isPositive ? AppColors.income : AppColors.expense;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.gradientCard(
        gradient: AppColors.primaryGradient,
        radius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month label
          Text(
            DateFormat('MMMM yyyy', 'id').format(month),
            style: AppTextStyles.label.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Net amount
          Text(
            formatter.format(net),
            style: AppTextStyles.amountLarge.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          Text(
            isPositive ? 'Surplus bulan ini' : 'Defisit bulan ini',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Container(
            height: 1,
            color: AppColors.textOnPrimary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.md),

          // Income / Expense row
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Pemasukan',
                  amount: formatter.format(income),
                  iconColor: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatPill(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Pengeluaran',
                  amount: formatter.format(expense),
                  iconColor: AppColors.expense,
                ),
              ),
            ],
          ),

          // Net savings progress bar
          const SizedBox(height: AppSpacing.md),
          _SavingsBar(income: income, expense: expense),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color iconColor;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.amount,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.14),
        borderRadius: AppRadius.smBR,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.22),
              borderRadius: AppRadius.xsBR,
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  amount,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsBar extends StatelessWidget {
  final int income;
  final int expense;

  const _SavingsBar({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final ratio = income == 0 ? 0.0 : (expense / income).clamp(0.0, 1.0);
    final spentPct = (ratio * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const SizedBox(height: AppSpacing.xs)],
    );
  }
}

class _WeekRow extends StatelessWidget {
  final WeeklyTransactionSummary summary;
  final int index;
  final int total;
  final NumberFormat formatter;

  const _WeekRow({
    required this.summary,
    required this.index,
    required this.total,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.net >= 0;
    final netColor = isPositive ? AppColors.income : AppColors.expense;
    final weekLabel = 'Minggu ${total - index}'; // most-recent week = Minggu N

    // Short date range label
    final shortFmt = DateFormat('dd MMM', 'id');
    final dateRange =
        '${shortFmt.format(summary.startDate)} – ${shortFmt.format(summary.endDate)}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppDecorations.card(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smBR,
                  ),
                  child: Center(
                    child: Text(
                      '${total - index}',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(weekLabel, style: AppTextStyles.heading3),
                    Text(dateRange, style: AppTextStyles.caption),
                  ],
                ),
                const Spacer(),
                // Net badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: AppDecorations.pill(color: netColor),
                  child: Text(
                    '${isPositive ? '+' : ''}${formatter.format(summary.net)}',
                    style: AppTextStyles.caption.copyWith(
                      color: netColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Pemasukan',
                    amount: formatter.format(summary.totalIncome),
                    color: AppColors.income,
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.border),
                Expanded(
                  child: _DetailItem(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Pengeluaran',
                    amount: formatter.format(summary.totalExpense),
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(
                  amount,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRefresh(),
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Text('Belum Ada Transaksi', style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tambahkan transaksi pertama Anda\nagar ringkasan bulanan muncul di sini.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
