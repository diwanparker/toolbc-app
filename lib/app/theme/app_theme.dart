import 'package:flutter/material.dart';

// Brand Primary Tokens (Sapphire & Ocean Azure)
const Color kPrimary = Color(0xFF1D4ED8); // Deep Trust Sapphire
const Color kPrimaryLight = Color(0xFF3B82F6); // Vibrant Blue
const Color kPrimaryDark = Color(0xFF1E40AF); // Royal Blue Accent
const Color kPrimaryGradientStart = Color(0xFF1E3A8A);
const Color kPrimaryGradientEnd = Color(0xFF0284C7);

// Background & Neutral Surface Tokens
const Color kBackground = Color(0xFFF8FAFC); // Clean Medical Slate Tint
const Color kSurface = Colors.white; // Pure Crisp Card Surface
const Color kSurfaceElevated = Color(0xFFFFFFFF);
const Color kSurfaceHover = Color(0xFFF1F5F9);

// Text & Ink Tokens
const Color kText = Color(0xFF0F172A); // Deep Slate Ink (High Contrast)
const Color kTextSecondary = Color(0xFF334155); // Slate Text
const Color kMuted = Color(0xFF64748B); // Muted Meta / Subtitle
const Color kBorder = Color(0xFFE2E8F0); // Subtle 1px Divider / Card Outline
const Color kBorderFocus = Color(0xFF3B82F6); // Active Focus Outline

// Clinical Semantic Status Tokens (WCAG AA Compliant)
const Color kSuccess = Color(0xFF059669); // Emerald Green
const Color kSoftGreen = Color(0xFFECFDF5);
const Color kBorderGreen = Color(0xFFA7F3D0);

const Color kWarning = Color(0xFFD97706); // Amber Gold
const Color kSoftAmber = Color(0xFFFFFBEB);
const Color kBorderAmber = Color(0xFFFDE68A);

const Color kDanger = Color(0xFFDC2626); // Crimson Coral
const Color kSoftRed = Color(0xFFFEF2F2);
const Color kBorderRed = Color(0xFFFECACA);

const Color kInfo = Color(0xFF0284C7); // Ocean Azure
const Color kSoftBlue = Color(0xFFF0F9FF);
const Color kBorderBlue = Color(0xFFBAE6FD);

// Subtle Multi-layer Diffuse Box Shadows
const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Color(0x080F172A),
    blurRadius: 4,
    offset: Offset(0, 1),
  ),
  BoxShadow(
    color: Color(0x0A0F172A),
    blurRadius: 16,
    offset: Offset(0, 4),
  ),
];

const List<BoxShadow> kHeroShadow = [
  BoxShadow(
    color: Color(0x331D4ED8),
    blurRadius: 24,
    offset: Offset(0, 12),
  ),
];

const List<BoxShadow> kButtonShadow = [
  BoxShadow(
    color: Color(0x291D4ED8),
    blurRadius: 12,
    offset: Offset(0, 4),
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
      secondary: kPrimaryLight,
      surface: kSurface,
      brightness: Brightness.light,
    ),
    textTheme: textTheme,
    cardTheme: CardThemeData(
      color: kSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kBorder),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: kText,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorderFocus, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDanger),
      ),
      hintStyle: const TextStyle(fontSize: 13, color: kMuted),
    ),
  );
}
