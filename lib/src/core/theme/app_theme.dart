import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final appThemeProvider = Provider<AppTheme>((ref) {
  return AppTheme();
});

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF0A3A6D); // Dark Academic Blue
  static const Color secondaryColor = Color(0xFFFBB03B); // Warm Accent
  static const Color backgroundColor = Color(0xFFF5F5F7); // Off-white
  static const Color errorColor = Color(0xFFD32F2F);

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        error: errorColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        displayMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
