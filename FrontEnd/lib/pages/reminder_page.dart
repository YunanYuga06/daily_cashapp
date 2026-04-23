// lib/pages/reminder_page.dart
// Step 2 refactor: modern card design, premium visual language.

import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/pages/halaman_crud/tambah_reminder.dart';
import 'package:daily_cashapp/view/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';
import '../service/api.service.dart';

// Map period string → color accent
Color _periodColor(String period) {
  switch (period.toLowerCase()) {
    case 'harian':
      return AppColors.secondary;
    case 'mingguan':
      return AppColors.primary;
    case 'bulanan':
      return AppColors.warning;
    default:
      return AppColors.textSecondary;
  }
}

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  Future<List<ReminderModel>>? _remindersFuture;
  final DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      setState(() => _remindersFuture = null);
      return;
    }
    setState(() {
      _remindersFuture = ApiService.getReminders(token, _currentMonth);
    });
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahReminderPage()),
    );
    if (result == true && mounted) _fetchReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(), Expanded(child: _buildBody())],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reminder', style: AppTextStyles.heading1),
              Text(
                'Tagihan & pengingat keuangan',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: _navigateAndRefresh,
            borderRadius: AppRadius.smBR,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.smBR,
                boxShadow: AppShadows.input,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.textOnPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text('Tambah', style: AppTextStyles.buttonSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_remindersFuture == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Silakan login untuk melihat reminder.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed:
                  () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (r) => false,
                  ),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<ReminderModel>>(
      future: _remindersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal memuat data.\n${snapshot.error}',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada pengingat untuk bulan ini.\nTekan Tambah untuk menambahkan.',
              textAlign: TextAlign.center,
            ),
          );
        }

        final reminders = snapshot.data!;

        // Separate upcoming vs past
        final now = DateTime.now();
        final upcoming =
            reminders.where((r) => !r.date.isBefore(now)).toList()
              ..sort((a, b) => a.date.compareTo(b.date));
        final past =
            reminders.where((r) => r.date.isBefore(now)).toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchReminders,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              80,
            ),
            children: [
              if (upcoming.isNotEmpty) ...[
                _SectionLabel(
                  label: 'Akan Datang',
                  icon: Icons.upcoming_rounded,
                  color: AppColors.primary,
                ),
                ...upcoming.map(
                  (r) => _ReminderCard(reminder: r, onChanged: _fetchReminders),
                ),
              ],
              if (past.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _SectionLabel(
                  label: 'Sudah Lewat',
                  icon: Icons.history_rounded,
                  color: AppColors.textSecondary,
                ),
                ...past.map(
                  (r) => _ReminderCard(
                    reminder: r,
                    isPast: true,
                    onChanged: _fetchReminders,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionLabel({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.heading3.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final bool isPast;
  final VoidCallback onChanged;

  const _ReminderCard({
    required this.reminder,
    this.isPast = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isPast ? AppColors.textHint : _periodColor(reminder.period);
    final daysLeft = reminder.date.difference(DateTime.now()).inDays;

    return Dismissible(
      key: Key('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _deleteReminder(context),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: AppRadius.cardBR,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: AppColors.error),
            const SizedBox(height: 2),
            Text(
              'Hapus',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TambahReminderPage(existingReminder: reminder),
            ),
          );
          if (result == true) onChanged();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: AppDecorations.card(
            color:
                isPast
                    ? AppColors.surface.withValues(alpha: 0.6)
                    : AppColors.surface,
          ),
          child: Row(
            children: [
              // Bell icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBR,
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Description + amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isPast
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${NumberFormat.decimalPattern('id').format(reminder.amount)}',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Period chip
                        _Chip(label: reminder.period, color: accentColor),
                        const SizedBox(width: AppSpacing.xs),
                        // Due date
                        _Chip(
                          label: DateFormat(
                            'dd MMM',
                            'id',
                          ).format(reminder.date),
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Days left badge
              if (!isPast)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        daysLeft <= 3
                            ? AppColors.error.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: AppRadius.smBR,
                  ),
                  child: Text(
                    daysLeft == 0 ? 'Hari ini' : '$daysLeft hari',
                    style: AppTextStyles.caption.copyWith(
                      color:
                          daysLeft <= 3 ? AppColors.error : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Hapus Pengingat?'),
          content: Text(
            "Yakin ingin menghapus '${reminder.description}'?",
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

  Future<void> _deleteReminder(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;
    try {
      await ApiService.deleteReminder(token, reminder.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengingat berhasil dihapus')),
        );
        onChanged();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        onChanged();
      }
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: AppDecorations.pill(color: color),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
