import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.softPink,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.softPink,
        primary: AppColors.softPink,
        secondary: AppColors.gold,
        surface: AppColors.white,
      ),
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(color: AppColors.darkGray, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.playfairDisplay(color: AppColors.darkGray, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.lato(color: AppColors.darkGray),
        bodyMedium: GoogleFonts.lato(color: AppColors.darkGray),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkGray),
        titleTextStyle: TextStyle(
          color: AppColors.darkGray,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Playfair Display',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blushPink,
          foregroundColor: AppColors.darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        hintStyle: GoogleFonts.lato(color: AppColors.lightGray),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.gold,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.white12,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.gold,
        surface: Color(0xFF1E1E1E),
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.playfairDisplayTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(color: AppColors.white, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.playfairDisplay(color: AppColors.white, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.lato(color: Colors.white70),
        bodyMedium: GoogleFonts.lato(color: Colors.white60),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Playfair Display',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        hintStyle: GoogleFonts.lato(color: Colors.white30),
      ),
    );
  }
}
