import 'package:flutter/material.dart';

class AppTheme {
  static const primaryGreen = Color(0xFF1B5E20);
  static const accentGreen = Color(0xFF4CAF50);
  static const lightBg = Color(0xFFF1F8E9);

  static const categoryColors = {
    'Education': Color(0xFF5C6BC0),
    'Health': Color(0xFFE53935),
    'Environment': Color(0xFF43A047),
    'Food': Color(0xFFFF8F00),
    'Shelter': Color(0xFF8D6E63),
    'Children': Color(0xFFEC407A),
    'Animals': Color(0xFF26C6DA),
    'Disaster Relief': Color(0xFFFF7043),
    'Human Rights': Color(0xFF7E57C2),
    'Other': Color(0xFF90A4AE),
  };

  static const categoryIcons = {
    'Education': Icons.school_outlined,
    'Health': Icons.favorite_outline,
    'Environment': Icons.eco_outlined,
    'Food': Icons.restaurant_outlined,
    'Shelter': Icons.home_outlined,
    'Children': Icons.child_care_outlined,
    'Animals': Icons.pets_outlined,
    'Disaster Relief': Icons.emergency_outlined,
    'Human Rights': Icons.people_outline,
    'Other': Icons.volunteer_activism_outlined,
  };

  static const paymentMethods = ['Cash', 'Credit Card', 'Bank Transfer', 'Crypto', 'Cheque', 'Online'];
  static const categories = [
    'Education', 'Health', 'Environment', 'Food', 'Shelter',
    'Children', 'Animals', 'Disaster Relief', 'Human Rights', 'Other',
  ];

  static ThemeData lightTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen, brightness: Brightness.light),
    scaffoldBackgroundColor: lightBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );

  static ThemeData darkTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen, brightness: Brightness.dark),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A2E1A),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: const Color(0xFF1E2E1E),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: const Color(0xFF1E2E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}