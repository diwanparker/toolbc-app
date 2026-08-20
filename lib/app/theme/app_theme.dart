import 'package:flutter/material.dart';

// =============================================================================
// BRAND & COLOR SYSTEM (Neo-Clean Medical & Clinical Grade)
// =============================================================================

// Primary Brand Tokens (Azure Blue & Cyan Palette)
const Color kPrimary = Color(0xFF0284C7); // Rich Azure Blue (Accessible & Trustworthy)
const Color kPrimaryDark = Color(0xFF0369A1); // Deep Ocean Navy
const Color kPrimaryLight = Color(0xFF38BDF8); // Vibrant Sky Blue
const Color kPrimaryAccent = Color(0xFF00A3FF); // Clean Cyan Accent
const Color kPrimaryGradientStart = Color(0xFF0284C7);
const Color kPrimaryGradientEnd = Color(0xFF0EA5E9);

// Neutral Background & Surface Tokens
const Color kBackground = Color(0xFFF8FAFC); // Ultra-clean subtle slate tint
const Color kSurface = Colors.white; // Pure crisp white card
const Color kSurfaceElevated = Color(0xFFFFFFFF);
const Color kSurfaceSubtle = Color(0xFFF1F5F9); // Light slate fill
const Color kSearchBg = Color(0xFFF1F5F9); // Input background

// Text & Ink Tokens (WCAG 2.1 AAA Compliant)
const Color kText = Color(0xFF0F172A); // Slate 900 Ultra Dark Ink
const Color kTextSecondary = Color(0xFF334155); // Slate 700 Subtitle Ink
const Color kMuted = Color(0xFF64748B); // Slate 500 Subtle Label
const Color kSubtle = Color(0xFF94A3B8); // Slate 400 Inactive / Placeholder
const Color kBorder = Color(0xFFE2E8F0); // Crisp 1px Surface Border
const Color kBorderLight = Color(0xFFF1F5F9);
const Color kBorderFocus = Color(0xFF0284C7); // Active Focus Outline

// Clinical Semantic Status Tokens (High Contrast & Clear)
const Color kSuccess = Color(0xFF059669); // Emerald Green 600
const Color kSuccessDark = Color(0xFF047857);
const Color kSoftGreen = Color(0xFFECFDF5);
const Color kBorderGreen = Color(0xFFA7F3D0);

const Color kWarning = Color(0xFFD97706); // Amber Gold 600
const Color kWarningDark = Color(0xFFB45309);
const Color kSoftAmber = Color(0xFFFFFBEB);
const Color kBorderAmber = Color(0xFFFDE68A);

const Color kDanger = Color(0xFFE11D48); // Rose Crimson 600
const Color kDangerDark = Color(0xFFBE123C);
const Color kSoftRed = Color(0xFFFFF1F2);
const Color kBorderRed = Color(0xFFFECDD3);

const Color kInfo = Color(0xFF0284C7); // Ocean Azure
const Color kSoftBlue = Color(0xFFF0F9FF);
const Color kBorderBlue = Color(0xFFBAE6FD);

const Color kPurple = Color(0xFF7C3AED); // AI Purple
const Color kSoftPurple = Color(0xFFF5F3FF);
const Color kBorderPurple = Color(0xFFDDD6FE);

// Service & Action Pastel Colors
const Color kPastelCyan = Color(0xFFE0F2FE);
const Color kPastelCyanFg = Color(0xFF0284C7);

const Color kPastelAmber = Color(0xFFFEF3C7);
const Color kPastelAmberFg = Color(0xFFD97706);

const Color kPastelGreen = Color(0xFFDCFCE7);
const Color kPastelGreenFg = Color(0xFF16A34A);

const Color kPastelPurple = Color(0xFFF3E8FF);
const Color kPastelPurpleFg = Color(0xFF7C3AED);

const Color kPastelRose = Color(0xFFFFE4E6);
const Color kPastelRoseFg = Color(0xFFE11D48);

const Color kPastelBlue = Color(0xFFEFF6FF);
const Color kPastelBlueFg = Color(0xFF2563EB);

// =============================================================================
// MODERN MULTI-LAYER DIFFUSE BOX SHADOWS
// =============================================================================

const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Color(0x080F172A),
    blurRadius: 16,
    offset: Offset(0, 6),
  ),
  BoxShadow(
    color: Color(0x040F172A),
    blurRadius: 4,
    offset: Offset(0, 1),
  ),
];

const List<BoxShadow> kFloatingShadow = [
  BoxShadow(
    color: Color(0x140F172A),
    blurRadius: 28,
    offset: Offset(0, 10),
  ),
  BoxShadow(
    color: Color(0x060F172A),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];

const List<BoxShadow> kHeroShadow = [
  BoxShadow(
    color: Color(0x330284C7),
    blurRadius: 26,
    offset: Offset(0, 10),
  ),
];

const List<BoxShadow> kButtonShadow = [
  BoxShadow(
    color: Color(0x300284C7),
    blurRadius: 16,
    offset: Offset(0, 6),
  ),
];

const List<BoxShadow> kSuccessButtonShadow = [
  BoxShadow(
    color: Color(0x30059669),
    blurRadius: 16,
    offset: Offset(0, 6),
  ),
];

// =============================================================================
// THEME DATA GENERATOR
// =============================================================================

ThemeData buildAppTheme() {
  const textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
      color: kText,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: kText,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: kText,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: kText,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: kText,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: kText,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: kTextSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: kText,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: kMuted,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: kBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      primary: kPrimary,
      secondary: kPrimaryDark,
      surface: kSurface,
      brightness: Brightness.light,
    ),
    textTheme: textTheme,
    cardTheme: CardThemeData(
      color: kSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kBorder),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: kText,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSearchBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kBorderFocus, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kDanger),
      ),
      hintStyle: const TextStyle(fontSize: 13, color: kSubtle, fontWeight: FontWeight.w400),
    ),
  );
}
