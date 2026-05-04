part of flutter_tbc;

const Color kPrimary = Color(0xFF2563EB);
const Color kPrimaryDark = Color(0xFF1D4ED8);
const Color kBackground = Color(0xFFF4F6FA);
const Color kSurface = Colors.white;
const Color kText = Color(0xFF0F172A);
const Color kMuted = Color(0xFF6B7280);
const Color kBorder = Color(0xFFE5E7EB);
const Color kSoftBlue = Color(0xFFEFF6FF);
const Color kSoftGreen = Color(0xFFF0FDF4);
const Color kSoftAmber = Color(0xFFFFF7ED);
const Color kSoftRed = Color(0xFFFEF2F2);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: kBackground,
    colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.light),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'Inter'),
      bodyLarge: TextStyle(fontFamily: 'Inter'),
      titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
    ),
  );
}
