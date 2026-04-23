// lib/widgets/app_bar.dart
// Modern, clean AppBar for the Transaksi page.
// Replaces the old solid-orange AppBar with a light, minimal header.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_cashapp/config/app_theme.dart';

PreferredSizeWidget buildTransaksiAppBar({
  required DateTime currentMonth,
  required VoidCallback onNextMonth,
  required VoidCallback onPreviousMonth,
  required TabController tabController,
}) {
  final monthLabel = DateFormat.yMMMM('id').format(currentMonth);

  return _TransaksiAppBar(
    monthLabel: monthLabel,
    onNextMonth: onNextMonth,
    onPreviousMonth: onPreviousMonth,
    tabController: tabController,
  );
}

class _TransaksiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String monthLabel;
  final VoidCallback onNextMonth;
  final VoidCallback onPreviousMonth;
  final TabController tabController;

  const _TransaksiAppBar({
    required this.monthLabel,
    required this.onNextMonth,
    required this.onPreviousMonth,
    required this.tabController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 52); // header + tab bar

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  // Month navigator
                  _MonthNavigator(
                    label: monthLabel,
                    onPrev: onPreviousMonth,
                    onNext: onNextMonth,
                  ),

                  const Spacer(),

                  // Search icon
                  _HeaderIconButton(
                    icon: Icons.search_rounded,
                    onTap: () {}, // TODO: wire up search
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Filter icon
                  _HeaderIconButton(
                    icon: Icons.tune_rounded,
                    onTap: () {}, // TODO: wire up filter
                  ),
                ],
              ),
            ),

            // ── Tab bar ──────────────────────────────────────────────────
            _ModernTabBar(controller: tabController),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: AppRadius.smBR,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavArrow(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(label, style: AppTextStyles.heading3),
          ),
          _NavArrow(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBR,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBR,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: AppRadius.smBR,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ModernTabBar extends StatelessWidget {
  final TabController controller;

  const _ModernTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: AppRadius.smBR,
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: controller,
        // Custom indicator — a filled pill inside the track
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.smBR,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
        unselectedLabelStyle: AppTextStyles.label,
        padding: const EdgeInsets.all(3),
        tabs: const [
          Tab(text: 'Harian'),
          Tab(text: 'Bulanan'),
          Tab(text: 'Anggaran'),
          Tab(text: 'Dashboard'),
        ],
      ),
    );
  }
}
