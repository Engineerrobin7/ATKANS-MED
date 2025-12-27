
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Existing Colors (kept for reference or light mode if needed later)
  static const primaryColor = Color(0xFF00695C); 
  static const secondaryColor = Color(0xFF00BFA5); 
  
  // New Theme Colors
  static const blackBackground = Color(0xFF000000);
  static const limeGreen = Color(0xFFC6FF00); // Lime Accent 400 - Vibrant
  static const darkSurface = Color(0xFF1E1E1E); // Slightly lighter black for cards
  static const whiteText = Colors.white;
  static const lightGreyText = Color(0xFFBDBDBD);

  static final TextTheme textTheme = GoogleFonts.outfitTextTheme();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: limeGreen,
      scaffoldBackgroundColor: blackBackground,
      colorScheme: const ColorScheme.dark(
        primary: limeGreen,
        secondary: limeGreen,
        surface: darkSurface,
        error: Color(0xFFCF6679),
        onPrimary: Colors.black, // Text on lime green should be black usually
        onSecondary: Colors.black,
        onSurface: whiteText,
      ),
      textTheme: textTheme.apply(
        bodyColor: whiteText,
        displayColor: whiteText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: blackBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteText),
        titleTextStyle: TextStyle(
          color: whiteText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1))),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: limeGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: limeGreen,
          foregroundColor: Colors.black, // Dark text on bright lime
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: limeGreen,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: limeGreen,
          side: const BorderSide(color: limeGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      iconTheme: const IconThemeData(
        color: limeGreen,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: limeGreen,
        textColor: whiteText,
      ),
       floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: limeGreen,
        foregroundColor: Colors.black,
      ),
    );
  }
}
