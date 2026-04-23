// lib/config/app_theme.dart
// Daily CashApp — Centralized Design System (Material 3 / Clean Minimalism)
//
// CHANGELOG vs previous version
// ─────────────────────────────
// FIX 1 — TabBarTheme: removed deprecated 'labelStyle' / 'unselectedLabelStyle'
//          (they were TextStyle const, not MaterialStateProperty — caused type
//          error in Flutter ≥ 3.16). Tab text styling is now applied directly
//          on the TabBar widget in app_bar.dart, which still accepts a plain
//          TextStyle. Only TabBarTheme changed to require MaterialStateProperty.
//
// FIX 2 — CardTheme: removed the explicit `color:` field. In Material 3 the
//          card colour is resolved from ColorScheme.surface automatically.
//          Setting it explicitly caused a conflict when the framework applied
//          the M3 tonal-elevation colour overlay on top. Instead we set
//          `surfaceTintColor: Colors.transparent` to keep cards pure white and
//          `elevation: 0` so no overlay is ever applied.
//
// FIX 3 — DialogTheme: removed `const` keyword from the constructor call.
//          `titleTextStyle` and `contentTextStyle` reference AppTextStyles
//          constants that contain Color values — those are not compile-time
//          constants in all Flutter versions, making `const DialogTheme(...)`
//          illegal. Removing `const` fixes the error without changing behaviour.
//
// FIX 4 — AppTheme shim class added at the bottom.
//          The four CRUD pages (pilih_item_page, tambah_aset, tambah_reminder,
//          tambah_transaksi) all reference the OLD single-class API, e.g.:
//            AppTheme.surface, AppTheme.heading2, AppTheme.primaryBlue,
//            AppTheme.spacingLarge, AppTheme.borderRadius, AppTheme.buttonText
//          Renaming that class to AppThemeData broke every one of those sites.
//          The shim re-exposes every old symbol as a redirect to the new class,
//          so those pages compile without changes. Migrate them to AppColors /
//          AppTextStyles / AppSpacing / AppRadius at your own pace, then delete
//          the shim class.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════════════════════════════════════════
// 1.  COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F6EF7);
  static const Color primaryLight = Color(0xFF7B94F9);
  static const Color primaryDark = Color(0xFF2E4DD4);
  static const Color secondary = Color(0xFF25C8A0);
  static const Color secondaryLight = Color(0xFFE6FAF5);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color income = Color(0xFF25C8A0);
  static const Color expense = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFA940);
  static const Color error = Color(0xFFFF4D4F);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF0F2FF);
  static const Color border = Color(0xFFE8EAEF);
  static const Color inputFill = Color(0xFFF0F2FF);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Shimmer ───────────────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFEEF0F6);
  static const Color shimmerHighlight = Color(0xFFF8F9FF);

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navActive = Color(0xFF4F6EF7);
  static const Color navInactive = Color(0xFF9CA3AF);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F6EF7), Color(0xFF7B94F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF25C8A0), Color(0xFF52D9BC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF9A9A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 2.  TYPOGRAPHY
// ══════════════════════════════════════════════════════════════════════════════
abstract final class AppTextStyles {
  static const String _fontFamily = 'Roboto';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle amountLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle amountIncome = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.income,
  );

  static const TextStyle amountExpense = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.expense,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    letterSpacing: 0.2,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 3.  SPACING
// ══════════════════════════════════════════════════════════════════════════════
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 16.0,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 12.0,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 4.  BORDER RADII
// ══════════════════════════════════════════════════════════════════════════════
abstract final class AppRadius {
  static const double xs = 6.0;
  static const double sm = 12.0;
  static const double card = 16.0;
  static const double lg = 20.0;
  static const double modal = 28.0;
  static const double pill = 100.0;

  static final BorderRadius xsBR = BorderRadius.circular(xs);
  static final BorderRadius smBR = BorderRadius.circular(sm);
  static final BorderRadius cardBR = BorderRadius.circular(card);
  static final BorderRadius lgBR = BorderRadius.circular(lg);
  static final BorderRadius modalBR = BorderRadius.only(
    topLeft: Radius.circular(modal),
    topRight: Radius.circular(modal),
  );
  static final BorderRadius pillBR = BorderRadius.circular(pill);
}

// ══════════════════════════════════════════════════════════════════════════════
// 5.  SHADOWS
// ══════════════════════════════════════════════════════════════════════════════
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D1A1D2E), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x081A1D2E), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1A4F6EF7), blurRadius: 20, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0F1A1D2E), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> input = [
    BoxShadow(color: Color(0x1A4F6EF7), blurRadius: 8, offset: Offset(0, 2)),
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
// 6.  DECORATION HELPERS
// ══════════════════════════════════════════════════════════════════════════════
abstract final class AppDecorations {
  static BoxDecoration card({Color? color}) => BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: AppRadius.cardBR,
    boxShadow: AppShadows.card,
  );

  static BoxDecoration elevated({Color? color}) => BoxDecoration(
    color: color ?? AppColors.surfaceElevated,
    borderRadius: AppRadius.lgBR,
    boxShadow: AppShadows.card,
  );

  static BoxDecoration input({bool focused = false}) => BoxDecoration(
    color: AppColors.inputFill,
    borderRadius: AppRadius.smBR,
    border: Border.all(
      color: focused ? AppColors.primary : AppColors.border,
      width: focused ? 1.5 : 1.0,
    ),
    boxShadow: focused ? AppShadows.input : null,
  );

  static BoxDecoration pill({required Color color, double opacity = 0.12}) =>
      BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: AppRadius.pillBR,
      );

  static BoxDecoration gradientCard({
    required LinearGradient gradient,
    double radius = AppRadius.card,
  }) => BoxDecoration(
    gradient: gradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: AppShadows.floating,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 7.  MATERIAL 3 ThemeData  (entry-point: AppTheme.light())
// ══════════════════════════════════════════════════════════════════════════════
// NOTE: The public-facing class is still called `AppTheme` (see Section 8).
//       The actual ThemeData builder lives here as a private helper so that
//       the shim class below can simply call _buildTheme() without circular
//       symbol dependencies.
ThemeData _buildTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.surfaceElevated,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: Color(0xFF0D6B56),
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.background,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    shadow: Color(0x1A1A1D2E),
    scrim: Color(0x801A1D2E),
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.surface,
    inversePrimary: AppColors.primaryLight,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',

    // ── AppBar ───────────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.heading1,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),

    // ── Card ─────────────────────────────────────────────────────────────────
    // FIX 2: No explicit `color:` — M3 resolves it from ColorScheme.surface.
    // surfaceTintColor: transparent prevents the tonal-elevation blue tint.
    cardTheme: CardThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      margin: EdgeInsets.zero,
    ),

    // ── Elevated Button ──────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        textStyle: AppTextStyles.buttonLarge,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
      ),
    ),

    // ── Text Button ──────────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),

    // ── Outlined Button ──────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),

    // ── FAB ──────────────────────────────────────────────────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBR),
    ),

    // ── Input Decoration ─────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      hintStyle: AppTextStyles.inputHint,
      labelStyle: AppTextStyles.inputLabel,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.smBR,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBR,
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBR,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBR,
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBR,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),

    // ── Chip ─────────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.inputFill,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.label,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // ── Tab Bar ───────────────────────────────────────────────────────────────
    // FIX 1: labelStyle / unselectedLabelStyle removed from TabBarTheme.
    // They now need MaterialStateProperty<TextStyle?> in Flutter ≥ 3.16 but
    // the old code passed a plain const TextStyle → type error.
    // Tab text styles are applied directly on the TabBar widget in app_bar.dart.
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    ),

    // ── Divider ───────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // ── Bottom Sheet ─────────────────────────────────────────────────────────
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      modalBarrierColor: const Color(0x661A1D2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.modal),
          topRight: Radius.circular(AppRadius.modal),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.border,
      elevation: 0,
    ),

    // ── Dialog ───────────────────────────────────────────────────────────────
    // FIX 3: Removed `const` — DialogTheme with titleTextStyle /
    // contentTextStyle cannot be const because the TextStyle values are not
    // compile-time constants in all Flutter versions.
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBR),
      titleTextStyle: AppTextStyles.heading2,
      contentTextStyle: AppTextStyles.bodyMedium,
    ),

    // ── SnackBar ─────────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.surface,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),

    // ── List Tile ─────────────────────────────────────────────────────────────
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      titleTextStyle: AppTextStyles.bodyLarge,
      subtitleTextStyle: AppTextStyles.bodySmall,
      iconColor: AppColors.textSecondary,
    ),

    // ── Bottom Navigation Bar ─────────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navBackground,
      selectedItemColor: AppColors.navActive,
      unselectedItemColor: AppColors.navInactive,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 8.  AppTheme — PUBLIC API  (backward-compatible shim)
// ══════════════════════════════════════════════════════════════════════════════
// The class is intentionally named `AppTheme` (same as the old file) so that:
//   • main.dart:  theme: AppTheme.light()          ← still works unchanged
//   • CRUD pages: AppTheme.surface / .heading2 …   ← still compile unchanged
//
// Every symbol that existed in the old AppTheme is re-exposed here as a
// redirect to the appropriate new class.  New code should use AppColors /
// AppTextStyles / AppSpacing / AppRadius directly.
// ══════════════════════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._(); // prevent instantiation

  /// Entry-point used in main.dart:  theme: AppTheme.light()
  static ThemeData light() => _buildTheme();

  // ── Colors (old API → new AppColors) ──────────────────────────────────────
  static const Color primaryOrange =
      AppColors.primary; // old orange → new primary
  static const Color primaryBlue = AppColors.primary;
  static const Color primaryYellow =
      AppColors.background; // old yellow bg → new bg
  static const Color surface = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color income = AppColors.income;
  static const Color expense = AppColors.expense;
  static const Color border = AppColors.border;
  static const Color disabled = AppColors.textHint;

  // ── Typography (old API → new AppTextStyles) ──────────────────────────────
  static const TextStyle heading1 = AppTextStyles.heading1;
  static const TextStyle heading2 = AppTextStyles.heading2;
  static const TextStyle amountText = AppTextStyles.amountMedium;
  static const TextStyle transactionTitle = AppTextStyles.bodyLarge;
  static const TextStyle transactionSubtitle = AppTextStyles.bodySmall;
  static const TextStyle inputLabel = AppTextStyles.inputLabel;
  static const TextStyle buttonText = AppTextStyles.buttonLarge;

  // ── Spacing (old API → new AppSpacing) ────────────────────────────────────
  static const double spacingSmall = AppSpacing.sm; // 8
  static const double spacingMedium = AppSpacing.md; // 16
  static const double spacingLarge = AppSpacing.lg; // 24

  // ── Shape (old API → new AppRadius) ───────────────────────────────────────
  // Old value was BorderRadius.circular(12).
  // New AppRadius.cardBR = 16 px.  If a page needs exactly 12 px use
  // AppRadius.smBR directly.  For the shim we preserve semantic intent.
  static final BorderRadius borderRadius = AppRadius.cardBR;
}
