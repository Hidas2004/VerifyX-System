import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// APP THEME - Cấu hình theme toàn app
/// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  /// Theme sáng (Light Theme)
  static ThemeData lightTheme = ThemeData(
    // ==================== COLOR SCHEME ====================
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    
    // ==================== SCAFFOLD ====================
    scaffoldBackgroundColor: AppColors.background,
    
    // ==================== APP BAR ====================
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: AppSizes.appBarElevation,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: AppSizes.fontLG,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    // ==================== BUTTON ====================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLG,
          vertical: AppSizes.paddingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingSM,
        ),
      ),
    ),
    
    // ==================== INPUT DECORATION ====================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      
      // Border mặc định
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: BorderSide.none,
      ),
      
      // Border khi enabled
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      
      // Border khi focused
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      
      // Border khi error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      
      // Border khi error + focused
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      
      // Content padding
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.paddingMD,
      ),
    ),
    
    // ==================== CARD ====================
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.paddingSM,
      ),
    ),
    
    // ==================== DIVIDER ====================
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: AppSizes.paddingMD,
    ),
    
    // ==================== ICON ====================
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: AppSizes.iconMD,
    ),
    
    // ==================== TEXT ====================
    textTheme: const TextTheme(
      // Display (Large titles)
      displayLarge: TextStyle(
        fontSize: AppSizes.font3XL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: AppSizes.font2XL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: AppSizes.fontXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      
      // Headline (Section titles)
      headlineLarge: TextStyle(
        fontSize: AppSizes.fontXL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: AppSizes.fontLG,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      
      // Body (Regular text)
      bodyLarge: TextStyle(
        fontSize: AppSizes.fontMD,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: AppSizes.fontSM,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: AppSizes.fontXS,
        color: AppColors.textDisabled,
      ),
      
      // Label (Buttons, small text)
      labelLarge: TextStyle(
        fontSize: AppSizes.fontMD,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontSize: AppSizes.fontSM,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: AppSizes.fontXS,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
