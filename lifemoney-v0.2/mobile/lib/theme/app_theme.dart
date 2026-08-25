import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF5F7FA);
  static const surface = Colors.white;
  static const ink = Color(0xFF132238);
  static const inkMuted = Color(0xFF667085);
  static const primary = Color(0xFF0C6E67);
  static const primaryDark = Color(0xFF084D49);
  static const primarySoft = Color(0xFFE8F5F2);
  static const navy = Color(0xFF16324F);
  static const navySoft = Color(0xFFEAF0F6);
  static const success = Color(0xFF1E8E5A);
  static const warning = Color(0xFFF0A43C);
  static const danger = Color(0xFFC94444);
  static const divider = Color(0xFFE6EAF0);
}

ThemeData buildLifeMoneyTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.navy,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    error: AppColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.divider,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: AppColors.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: AppColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: AppColors.inkMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        side: BorderSide(color: AppColors.divider),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: AppColors.inkMuted),
      floatingLabelStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: AppColors.danger),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primarySoft,
      height: 72,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
