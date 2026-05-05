import 'package:flutter/material.dart';

class AppTheme {
  // Primary Brand Colors
  static const Color primaryGreen = Color.fromARGB(255, 45, 66, 106);
  static const Color lightGreen = Color.fromARGB(255, 149, 174, 213);
  static const Color surfaceWhite = Color.fromARGB(255, 255, 253, 253);
  static const Color textDark = Color.fromARGB(255, 27, 39, 67);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        surface: const Color.fromARGB(255, 247, 244, 244),
      ),
      scaffoldBackgroundColor: surfaceWhite,
      
      // Setting up the look for AppBar across the whole app
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // Styling the "Chips" for the ingredient input screen
      chipTheme: ChipThemeData(
        backgroundColor: lightGreen.withOpacity(0.2),
        labelStyle: const TextStyle(color: textDark),
        secondarySelectedColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),

      // Customizing buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}