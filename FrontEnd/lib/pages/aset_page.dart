// lib/pages/aset_page.dart
// Step 2 refactor: modern card design, premium visual language.

import 'package:daily_cashapp/config/app_theme.dart';
import 'package:daily_cashapp/models/asset_model.dart';
import 'package:daily_cashapp/pages/halaman_crud/tambah_aset.dart';
import 'package:daily_cashapp/service/api.service.dart';
import 'package:daily_cashapp/view/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Map asset type → icon
IconData _iconForType(String type) {
  switch (type.toLowerCase()) {
    case 'tabungan':
    case 'bank':
      return Icons.account_balance_rounded;
    case 'tunai':
    case 'cash':
      return Icons.payments_rounded;
    case 'investasi':
      return Icons.trending_up_rounded;
    case 'properti':
      return Icons.home_rounded;
    default:
      return Icons.account_balance_wallet_rounded;
  }
}

// Map index → gradient so each card looks distinct
final List<LinearGradient> _cardGradients = [
  AppColors.primaryGradient,
  AppColors.incomeGradient,
  AppColors.expenseGradient,
  const LinearGradient(
    colors: [Color(0xFF7B5EA7), Color(0xFF9B7EC8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];

class HalamanAset extends StatefulWidget {
  const HalamanAset({super.key});

  @override
  State<HalamanAset> createState() => _HalamanAsetState();
}

class _HalamanAsetState extends State<HalamanAset> {
  Future<List<AssetModel>>? _assetsFuture;

  bool _isLoading = true;

  final NumberFormat _fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      setState(() {
        _assetsFuture = null;
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _assetsFuture = ApiService.getAssets(token);
      _isLoading = false;
    });
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahAsetPage()),
    );
    if (result == true && mounted) _fetchAssets();
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

  // ── Modern inline header (no AppBar widget) ──────────────────────────────
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
              Text('Aset', style: AppTextStyles.heading1),
              Text(
                'Kelola keuangan & dompet Anda',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          // Add button
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
    // if (_isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    if (_assetsFuture == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Silakan login untuk melihat aset.',
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

    return FutureBuilder<List<AssetModel>>(
      future: _assetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal memuat aset.\n${snapshot.error}',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }

        final assets = snapshot.data ?? [];
        if (assets.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _fetchAssets,
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Text(
                    'Belum ada aset.\nTekan Tambah untuk menambahkan.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }

        // Total balance card + list
        final totalBalance = assets.fold(0, (sum, a) => sum + a.currentAmount);

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchAssets,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              80,
            ),
            children: [
              // Total balance hero card
              _TotalBalanceCard(
                total: _fmt.format(totalBalance),
                assetCount: assets.length,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Dompet & Rekening', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              // Asset cards
              ...assets.asMap().entries.map(
                (e) => _AssetCard(
                  asset: e.value,
                  gradient: _cardGradients[e.key % _cardGradients.length],
                  formatter: _fmt,
                  onChanged: _fetchAssets,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Total balance hero
// ─────────────────────────────────────────────────────────────────────────────
class _TotalBalanceCard extends StatelessWidget {
  final String total;
  final int assetCount;

  const _TotalBalanceCard({required this.total, required this.assetCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.gradientCard(
        gradient: AppColors.primaryGradient,
        radius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Kekayaan',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            total,
            style: AppTextStyles.amountLarge.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$assetCount aset terdaftar',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual asset card with swipe-to-delete
// ─────────────────────────────────────────────────────────────────────────────
class _AssetCard extends StatelessWidget {
  final AssetModel asset;
  final LinearGradient gradient;
  final NumberFormat formatter;
  final VoidCallback onChanged;

  const _AssetCard({
    required this.asset,
    required this.gradient,
    required this.formatter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('asset_${asset.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _deleteAsset(context),
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
              builder: (_) => TambahAsetPage(existingAsset: asset),
            ),
          );
          if (result == true) onChanged();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: AppDecorations.card(),
          child: Row(
            children: [
              // Icon in gradient circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: AppRadius.smBR,
                ),
                child: Icon(
                  _iconForType(asset.assetType),
                  color: AppColors.textOnPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Name + type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.assetName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (asset.assetType.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(asset.assetType, style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
              ),
              // Amount
              Text(
                formatter.format(asset.currentAmount),
                style: AppTextStyles.amountMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 20,
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
          title: const Text('Hapus Aset?'),
          content: Text(
            "Yakin ingin menghapus '${asset.assetName}'?\n\nAset yang sudah memiliki transaksi tidak dapat dihapus.",
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

  Future<void> _deleteAsset(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;
    try {
      await ApiService.deleteAsset(token, asset.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aset berhasil dihapus')));
        onChanged();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal menghapus! Pastikan aset tidak terikat transaksi.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        onChanged();
      }
    }
  }
}
