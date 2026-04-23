// lib/widgets/bottom_navbar.dart
// Modern floating pill-shaped bottom navigation bar.
// Uses google_nav_bar styled to match the AppColors design system.

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:daily_cashapp/config/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Floating card effect — sits above the scaffold background
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.pillBR,
        boxShadow: AppShadows.floating,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: GNav(
          // No background on the outer GNav — we handle it in the Container above
          backgroundColor: Colors.transparent,

          // Active tab pill
          color: AppColors.navInactive,
          activeColor: AppColors.navActive,
          tabBackgroundColor: AppColors.primary.withValues(alpha: 0.10),

          // Pill shape for active tab
          tabBorderRadius: AppRadius.pill,

          // Spacing & padding
          gap: AppSpacing.xs,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),

          // Text style
          textStyle: AppTextStyles.label.copyWith(
            color: AppColors.navActive,
            fontWeight: FontWeight.w600,
          ),

          // Duration for the pill expand/collapse animation
          duration: const Duration(milliseconds: 300),

          selectedIndex: selectedIndex,
          onTabChange: onTabChange,

          tabs: const [
            GButton(icon: Icons.receipt_long_rounded, text: 'Transaksi'),
            GButton(icon: Icons.account_balance_wallet_rounded, text: 'Aset'),
            GButton(icon: Icons.notifications_rounded, text: 'Reminder'),
            GButton(icon: Icons.person_rounded, text: 'Profil'),
          ],
        ),
      ),
    );
  }
}
