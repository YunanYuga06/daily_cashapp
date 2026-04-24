import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/pages/halaman_crud/edit_anggaran.dart';
import 'package:daily_cashapp/service/api.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetTab extends StatefulWidget {
  final DateTime currentMonth;
  const BudgetTab({super.key, required this.currentMonth});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  Future<List<BudgetModel>>? _budgetsFuture;

  final NumberFormat _fmt = NumberFormat.currency(
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
            Exception('Sesi tidak valid. Silakan login kembali.'),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggaran berhasil dihapus')),
        );
        _fetchBudgets();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, BudgetModel budget) {
    showDialog(
      context: context,
      builder:
          (BuildContext ctx) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Text(
              'Apakah Anda yakin ingin menghapus anggaran untuk "${budget.category.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Batal',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _deleteBudget(budget.id);
                },
                child: Text(
                  'Hapus',
                  style: AppTextStyles.label.copyWith(color: AppColors.expense),
                ),
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
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final budgets = snapshot.data!;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchBudgets,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: budgets.length,
            itemBuilder: (context, index) => _buildBudgetCard(budgets[index]),
          ),
        );
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
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Belum ada anggaran',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tekan tombol (+) untuk mulai\nmengatur anggaran bulan ini.',
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

  Widget _buildBudgetCard(BudgetModel budget) {
    final double spent = budget.spent.toDouble();
    final double total = budget.amount.toDouble();
    final double percentUsed =
        (total > 0) ? (spent / total).clamp(0.0, 1.0) : 0.0;

    final now = DateTime.now();
    final endDate = budget.lastPeriod;
    int remainingDays =
        endDate.isAfter(now) ? endDate.difference(now).inDays + 1 : 1;
    if (remainingDays <= 0) remainingDays = 1;

    final dailyLimit = (total > spent) ? ((total - spent) / remainingDays) : 0;
    final bool isWarning = percentUsed >= 0.8;
    final Color progressColor =
        isWarning ? AppColors.expense : AppColors.income;
    final Color progressBg =
        isWarning
            ? AppColors.expense.withValues(alpha: 0.12)
            : AppColors.income.withValues(alpha: 0.12);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.pie_chart_outline_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.category.name,
                        style: AppTextStyles.heading3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(_fmt.format(total), style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                // More options
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
                  elevation: 4,
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditAnggaranPage(budget: budget),
                        ),
                      );
                      if (result == true) _fetchBudgets();
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, budget);
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text('Edit', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.expense,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.expense,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt.format(spent),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(percentUsed * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: LinearProgressIndicator(
                value: percentUsed,
                minHeight: 10,
                backgroundColor: progressBg,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Terpakai', style: AppTextStyles.caption),
                Text(_fmt.format(total), style: AppTextStyles.caption),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: 'Sisa Anggaran',
                      value: _fmt.format(
                        (total - spent).clamp(0, double.infinity),
                      ),
                      color:
                          total > spent ? AppColors.income : AppColors.expense,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Batas Harian',
                      value: _fmt.format(dailyLimit),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Warning chip if over 80%
            if (isWarning) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: AppDecorations.pill(
                  color: AppColors.expense,
                  opacity: 0.1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: AppColors.expense,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Anggaran hampir habis!',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
