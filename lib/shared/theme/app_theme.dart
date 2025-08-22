import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00FF00); // Neon Green conforme wireframe
  static const Color backgroundColor = Color(0xFF000000); // Black background
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF2A2A2A);
  static const Color errorColor = Color(0xFFFF5555);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.grey[500]),
        errorStyle: const TextStyle(color: errorColor),
      ),
      
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: backgroundColor,
        modalBackgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
      
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      
      tabBarTheme: const TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryColor,
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      
      dividerTheme: DividerThemeData(
        color: Colors.grey[800],
        thickness: 1,
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}