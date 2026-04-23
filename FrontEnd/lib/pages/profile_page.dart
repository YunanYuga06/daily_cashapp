// lib/pages/profile_page.dart
// Step 2 refactor: modern card design, premium visual language.

import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/pages/halaman_crud/edit_profile.dart';
import 'package:daily_cashapp/view/dashboard.dart';
import 'package:daily_cashapp/widgets/kategori.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../service/api.service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<ProfileModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userFuture = _fetchUser();
    });
  }

  Future<ProfileModel> _fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      _logout();
      throw Exception('Sesi berakhir. Silakan login kembali.');
    }
    return ApiService.getCurrentUser(token);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<ProfileModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat profil: ${snapshot.error}',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data profil tidak ditemukan.'));
          }

          final user = snapshot.data!;
          return _buildContent(user);
        },
      ),
    );
  }

  Widget _buildContent(ProfileModel user) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          80,
        ),
        children: [
          Text('Profil', style: AppTextStyles.heading1),
          Text('Kelola akun Anda', style: AppTextStyles.bodySmall),

          const SizedBox(height: AppSpacing.lg),
          _ProfileHeroCard(user: user),

          const SizedBox(height: AppSpacing.lg),
          Text('Pengaturan Akun', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          _MenuCard(
            children: [
              _MenuItem(
                icon: Icons.edit_rounded,
                iconColor: AppColors.primary,
                label: 'Edit Profil',
                subtitle: 'Ubah nama, email, atau foto',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                  if (result == true) _loadUserData();
                },
              ),
              const _MenuDivider(),
              _MenuItem(
                icon: Icons.category_rounded,
                iconColor: AppColors.secondary,
                label: 'Kategori',
                subtitle: 'Kelola kategori transaksi',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KategoriPage()),
                    ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          Text('Akun', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),

          _MenuCard(
            children: [
              _MenuItem(
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
                label: 'Logout',
                subtitle: 'Keluar dari akun ini',
                onTap: _logout,
                textColor: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final ProfileModel user;

  const _ProfileHeroCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.gradientCard(
        gradient: AppColors.primaryGradient,
        radius: AppRadius.card,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                width: 2,
              ),
              image:
                  (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                      ? DecorationImage(
                        image: NetworkImage(user.imageUrl!),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                (user.imageUrl == null || user.imageUrl!.isEmpty)
                    ? const Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: AppColors.textOnPrimary,
                    )
                    : null,
          ),
          const SizedBox(width: AppSpacing.md),
          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.8),
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

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 64, color: AppColors.border);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.xsBR,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
