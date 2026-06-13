import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static const TextTheme _cairoTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: AppColors.forest,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: AppColors.forest,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.charcoalDark,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: AppColors.charcoalDark,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.charcoal,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.charcoal,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.goldDark,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.goldDark,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.goldDark,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // الخط الافتراضي للتطبيق
    fontFamily: 'Cairo',

    scaffoldBackgroundColor: AppColors.goldLight,

    textTheme: _cairoTextTheme,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      primary: AppColors.forest,
      secondary: AppColors.gold,
      surface: AppColors.white,
      background: AppColors.goldLight,
      error: AppColors.umber,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: AppColors.charcoal,
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        color: AppColors.charcoal,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      hintStyle: _cairoTextTheme.labelMedium,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.gold.withOpacity(0.35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.gold.withOpacity(0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.forest,
          width: 1.4,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.white,
        textStyle: _cairoTextTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(
          double.infinity,
          50,
        ),
      ),
    ),

    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}