import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const fontFamily = 'Poppins';

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.dark,
      error: AppColors.danger,
      onError: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.textLight,
      outline: AppColors.grey,
    ),
    fontFamily: fontFamily,
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.dark,
      error: AppColors.danger,
      onError: AppColors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textDark,
      outline: AppColors.grey,
    ),
    fontFamily: fontFamily,
    useMaterial3: true,
  );
}
