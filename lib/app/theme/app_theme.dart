import 'package:flutter/material.dart';

// Brand Primary Tokens (Neo-Clean Cyan / Azure Blue from reference)
const Color kPrimary = Color(0xFF00A3FF); // Bright Clean Cyan Blue (Reference Accent)
const Color kPrimaryDark = Color(0xFF0284C7); // Deep Cyan Accent
const Color kPrimaryLight = Color(0xFF38BDF8); // Sky Blue
const Color kPrimaryGradientStart = Color(0xFF0284C7);
const Color kPrimaryGradientEnd = Color(0xFF00A3FF);

// Background & Neutral Surface Tokens
const Color kBackground = Color(0xFFF8FAFC); // Ultra-clean light background
const Color kSurface = Colors.white; // Pure crisp white card
const Color kSurfaceElevated = Color(0xFFFFFFFF);
const Color kSurfaceHover = Color(0xFFF1F5F9);
const Color kSearchBg = Color(0xFFF1F5F9); // Light gray input fill

// Text & Ink Tokens
const Color kText = Color(0xFF1E293B); // Slate 800 Dark Ink
const Color kTextSecondary = Color(0xFF475569); // Slate 600
const Color kMuted = Color(0xFF94A3B8); // Slate 400 Muted
const Color kBorder = Color(0xFFE2E8F0); // Subtle 1px Divider / Card Outline
const Color kBorderFocus = Color(0xFF00A3FF); // Active Focus Outline

// Reference Pastel Colors for Circular Quick Actions
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

// Clinical Semantic Status Tokens (WCAG AA Compliant)
const Color kSuccess = Color(0xFF16A34A); // Emerald Green
const Color kSoftGreen = Color(0xFFDCFCE7);
const Color kBorderGreen = Color(0xFF86EFAC);

const Color kWarning = Color(0xFFD97706); // Amber Gold
const Color kSoftAmber = Color(0xFFFEF3C7);
const Color kBorderAmber = Color(0xFFFDE68A);

const Color kDanger = Color(0xFFE11D48); // Rose Crimson
const Color kSoftRed = Color(0xFFFFE4E6);
const Color kBorderRed = Color(0xFFFECDD3);

const Color kInfo = Color(0xFF0284C7); // Ocean Azure
const Color kSoftBlue = Color(0xFFE0F2FE);
const Color kBorderBlue = Color(0xFFBAE6FD);

// Subtle Multi-layer Diffuse Box Shadows
const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Color(0x060F172A),
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
  BoxShadow(
    color: Color(0x040F172A),
    blurRadius: 2,
    offset: Offset(0, 1),
  ),
];

const List<BoxShadow> kFloatingShadow = [
  BoxShadow(
    color: Color(0x120F172A),
    blurRadius: 24,
    offset: Offset(0, 8),
  ),
  BoxShadow(
    color: Color(0x060F172A),
    blurRadius: 6,
    offset: Offset(0, 2),
  ),
];

const List<BoxShadow> kHeroShadow = [
  BoxShadow(
    color: Color(0x2800A3FF),
    blurRadius: 24,
    offset: Offset(0, 10),
  ),
];

const List<BoxShadow> kButtonShadow = [
  BoxShadow(
    color: Color(0x3300A3FF),
    blurRadius: 14,
    offset: Offset(0, 5),
  ),
];

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
      fontWeight: FontWeight.w700,
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
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
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
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kBorderFocus, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kDanger),
      ),
      hintStyle: const TextStyle(fontSize: 13, color: kMuted),
    ),
  );
}
