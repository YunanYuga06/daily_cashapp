// lib/widgets/harian_tab.dart
// Step 2 refactor: modern card design, premium visual language.
// All hardcoded colors/styles replaced with AppColors / AppTextStyles.

import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/pages/halaman_crud/tambah_transaksi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaksi_model.dart';
import '../service/api.service.dart';

class HarianTab extends StatefulWidget {
  final DateTime currentMonth;

  const HarianTab({Key? key, required this.currentMonth}) : super(key: key);

  @override
  State<HarianTab> createState() => _HarianTabState();
}

class _HarianTabState extends State<HarianTab> {
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
          return Center(
            child: Text(
              'Gagal memuat data: ${snapshot.error}',
              style: AppTextStyles.bodyMedium,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada transaksi untuk bulan ini.',
              style: AppTextStyles.bodyMedium,
            ),
          );
        }

        final transactions = snapshot.data!;
        final grouped = _groupByDate(transactions);
        final sortedDates =
            grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return Column(
          children: [
            _SummaryCard(transactions: transactions, formatter: _fmt),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _fetchTransactions,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    // Extra bottom padding so FAB doesn't overlap last item
                    80,
                  ),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    return _DailyGroup(
                      date: date,
                      transactions: grouped[date]!,
                      formatter: _fmt,
                      onDeleted: _fetchTransactions,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<DateTime, List<TransactionModel>> _groupByDate(
    List<TransactionModel> txs,
  ) {
    final map = <DateTime, List<TransactionModel>>{};
    for (final tx in txs) {
      final key = DateTime(tx.date.year, tx.date.month, tx.date.day);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary card — gradient hero at the top of the list
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final NumberFormat formatter;

  const _SummaryCard({required this.transactions, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0, (s, t) => s + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0, (s, t) => s + t.amount);
    final net = totalIncome - totalExpense;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.gradientCard(
        gradient: AppColors.primaryGradient,
        radius: AppRadius.card,
      ),
      child: Column(
        children: [
          // Net balance label
          Text(
            'Saldo Bulan Ini',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatter.format(net),
            style: AppTextStyles.amountLarge.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Divider
          Container(
            height: 1,
            color: AppColors.textOnPrimary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.md),
          // Income / Expense row
          Row(
            children: [
              Expanded(
                child: _SummaryPill(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Pemasukan',
                  amount: formatter.format(totalIncome),
                  iconColor: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryPill(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Pengeluaran',
                  amount: formatter.format(totalExpense),
                  iconColor: AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color iconColor;

  const _SummaryPill({
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
        color: AppColors.textOnPrimary.withValues(alpha: 0.15),
        borderRadius: AppRadius.smBR,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: AppRadius.xsBR,
            ),
            child: Icon(icon, size: 16, color: iconColor),
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

// ─────────────────────────────────────────────────────────────────────────────
// Daily group — date header + list of transaction tiles
// ─────────────────────────────────────────────────────────────────────────────
class _DailyGroup extends StatelessWidget {
  final DateTime date;
  final List<TransactionModel> transactions;
  final NumberFormat formatter;
  final VoidCallback onDeleted;

  const _DailyGroup({
    required this.date,
    required this.transactions,
    required this.formatter,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final dailyIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0, (s, t) => s + t.amount);
    final dailyExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0, (s, t) => s + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Date header ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Day number badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.xsBR,
                ),
                child: Center(
                  child: Text(
                    DateFormat('dd').format(date),
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Day + Month
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE', 'id').format(date),
                    style: AppTextStyles.label,
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'id').format(date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const Spacer(),
              // Daily summary chips
              _AmountChip(
                amount: formatter.format(dailyIncome),
                color: AppColors.income,
              ),
              const SizedBox(width: AppSpacing.xs),
              _AmountChip(
                amount: formatter.format(dailyExpense),
                color: AppColors.expense,
              ),
            ],
          ),
        ),

        // ── Transaction card ──────────────────────────────────────────
        Container(
          decoration: AppDecorations.card(),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children:
                transactions
                    .asMap()
                    .entries
                    .map(
                      (entry) => _TransactionTile(
                        tx: entry.value,
                        formatter: formatter,
                        isLast: entry.key == transactions.length - 1,
                        onDeleted: onDeleted,
                      ),
                    )
                    .toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String amount;
  final Color color;

  const _AmountChip({required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: AppDecorations.pill(color: color),
      child: Text(
        amount,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual transaction tile with swipe-to-delete
// ─────────────────────────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final NumberFormat formatter;
  final bool isLast;
  final VoidCallback onDeleted;

  const _TransactionTile({
    required this.tx,
    required this.formatter,
    required this.isLast,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == 'expense';
    final accentColor = isExpense ? AppColors.expense : AppColors.income;

    return Dismissible(
      key: Key('tx_${tx.id}'),
      direction: DismissDirection.endToStart,
      // NOTE: Delete confirmation → Step 6 (BottomSheet). For now keep alert.
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (direction) => _deleteTransaction(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.error.withValues(alpha: 0.15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: AppColors.error, size: 22),
            const SizedBox(height: 2),
            Text(
              'Hapus',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransaksi(existingTransaction: tx),
            ),
          );
          onDeleted(); // refresh even on edit
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              child: Row(
                children: [
                  // Category icon bubble
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.smBR,
                    ),
                    child: Icon(
                      isExpense
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Title + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.category.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (tx.description != null &&
                            tx.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            tx.description!,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Amount
                  Text(
                    '${isExpense ? '-' : '+'}${formatter.format(tx.amount)}',
                    style: (isExpense
                            ? AppTextStyles.amountExpense
                            : AppTextStyles.amountIncome)
                        .copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            // Divider between tiles (skip on last)
            if (!isLast)
              Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.md + 44 + AppSpacing.md,
                color: AppColors.border,
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hapus Transaksi?'),
            content: Text(
              'Transaksi "${tx.category.name}" sebesar '
              '${formatter.format(tx.amount)} akan dihapus permanen.',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Hapus', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;
    try {
      await ApiService.deleteTransaction(token, tx.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus')),
        );
        onDeleted();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        onDeleted();
      }
    }
  }
}
