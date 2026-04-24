// lib/view/dashboard.dart
// Landing / splash screen — completely refactored.
// Old yellow theme + orange 'C' logo removed entirely.

import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/view/login.dart';
import 'package:daily_cashapp/view/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Force light status-bar icons on the light background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Logo ──────────────────────────────────────────────────
              Image.asset(
                'assets/logo.png',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: AppSpacing.md),

              // ── App name ──────────────────────────────────────────────
              Text('Daily Cash', style: AppTextStyles.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Catat, kelola, dan kuasai\nkeuangan harian Anda.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // ── Feature highlights ────────────────────────────────────
              _FeatureRow(
                icon: Icons.receipt_long_rounded,
                color: AppColors.primary,
                label: 'Catat setiap transaksi harian',
              ),
              const SizedBox(height: AppSpacing.sm),
              _FeatureRow(
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.secondary,
                label: 'Pantau saldo & aset Anda',
              ),
              const SizedBox(height: AppSpacing.sm),
              _FeatureRow(
                icon: Icons.notifications_rounded,
                color: AppColors.warning,
                label: 'Reminder tagihan otomatis',
              ),

              const Spacer(flex: 3),

              // ── Primary CTA: Masuk ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        _fadeRoute(const LoginPage()),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
                    textStyle: AppTextStyles.buttonLarge,
                  ),
                  child: const Text('Masuk'),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Secondary CTA: Daftar ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        _fadeRoute(const RegisterPage()),
                      ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
                    textStyle: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  child: const Text('Daftar Sekarang'),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small feature highlight row
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.xsBR,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}
