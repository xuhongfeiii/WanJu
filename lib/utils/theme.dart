import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final TextStyle _serifBase = GoogleFonts.getFont(
    'Noto Serif SC',
    fontSize: 14,
  );

  // Light theme colors
  static const Color primary = Color(0xFF7EC8C8);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF666666);
  static const Color outline = Color(0xFFEEEEEE);
  static const Color accentMintLight = Color(0x337EC8C8);

  // Dark theme colors
  static const Color primaryDark = Color(0xFF7EC8C8);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color onSurfaceVariantDark = Color(0xFF9E9E9E);
  static const Color outlineDark = Color(0xFF2C2C2C);

  // Shared colors
  static Color outlineFaded = const Color(0xFFEEEEEE).withValues(alpha: 0.5);
  static Color surfaceLowOpacity = const Color(0xFFFFFFFF).withValues(alpha: 0.85);
  static Color blackLowOpacity = const Color(0xFF000000).withValues(alpha: 0.08);
  static Color blackMidOpacity = const Color(0xFF000000).withValues(alpha: 0.06);
  static Color onSurfaceVariantFaded = const Color(0xFF666666).withValues(alpha: 0.5);

  // Text styles
  static TextStyle headlineLg = _serifBase.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  static TextStyle headlineMd = _serifBase.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
  );

  static TextStyle bodyMd = _serifBase.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static TextStyle bodySm = _serifBase.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
  );

  static TextStyle labelSm = _serifBase.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );

  static TextStyle labelXs = _serifBase.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    letterSpacing: 0.02,
  );
  
  // Border radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 9999;
  
  // Spacing
  static const double containerMargin = 20;
  static const double cardGap = 16;
  static const double stackGap = 12;
  static const double chipPaddingX = 12;
  static const double chipPaddingY = 6;
  static const double sectionPadding = 24;
  
  // Shadows
  static const BoxShadow whisperShadow = BoxShadow(
    color: Color(0x0F000000),
    offset: Offset(0, 1),
    blurRadius: 3,
  );
  
  static const BoxShadow enhancedShadow = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 4),
    blurRadius: 12,
  );
}

class AppColors {
  final bool isDark;
  AppColors(this.isDark);

  Color get primary => AppTheme.primary;
  Color get background => isDark ? AppTheme.backgroundDark : AppTheme.background;
  Color get surface => isDark ? AppTheme.surfaceDark : AppTheme.surface;
  Color get onSurface => isDark ? AppTheme.onSurfaceDark : AppTheme.onSurface;
  Color get onSurfaceVariant => isDark ? AppTheme.onSurfaceVariantDark : AppTheme.onSurfaceVariant;
  Color get outline => isDark ? AppTheme.outlineDark : AppTheme.outline;
  Color get outlineFaded => isDark
      ? AppTheme.outlineDark.withValues(alpha: 0.5)
      : AppTheme.outlineFaded;
  Color get surfaceLowOpacity => isDark
      ? AppTheme.surfaceDark.withValues(alpha: 0.85)
      : AppTheme.surfaceLowOpacity;
  Color get onSurfaceVariantFaded => isDark
      ? AppTheme.onSurfaceVariantDark.withValues(alpha: 0.5)
      : AppTheme.onSurfaceVariantFaded;
  Color get inputFill => isDark
      ? AppTheme.outlineDark.withValues(alpha: 0.5)
      : AppTheme.outline.withValues(alpha: 0.3);

  static AppColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppColors(isDark);
  }
}