import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const String predictEndpoint = '/api/predict';
  static const String healthEndpoint = '/api/health';

  // Image Configuration
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;
}

// Dark Theme Colors
class DarkColors {
  static const Color primary = Color(0xFFFFC107);
  static const Color primaryDark = Color(0xFFFF8F00);
  static const Color accent = Color(0xFFFFB300);
  
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF21262D);
  static const Color card = Color(0xFF1C2128);
  
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);
  
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);
}

// Light Theme Colors
class LightColors {
  static const Color primary = Color(0xFFFF9800);
  static const Color primaryDark = Color(0xFFF57C00);
  static const Color accent = Color(0xFFFFB300);
  
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F3F5);
  static const Color card = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted = Color(0xFF718096);
  
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

// Dynamic colors based on theme
class AppColors {
  static Color primary(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.primary : LightColors.primary;
  
  static Color primaryDark(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.primaryDark : LightColors.primaryDark;
  
  static Color accent(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.accent : LightColors.accent;
  
  static Color background(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.background : LightColors.background;
  
  static Color surface(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.surface : LightColors.surface;
  
  static Color surfaceLight(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.surfaceLight : LightColors.surfaceLight;
  
  static Color card(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.card : LightColors.card;
  
  static Color textPrimary(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.textPrimary : LightColors.textPrimary;
  
  static Color textSecondary(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.textSecondary : LightColors.textSecondary;
  
  static Color textMuted(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.textMuted : LightColors.textMuted;
  
  static Color success(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.success : LightColors.success;
  
  static Color warning(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.warning : LightColors.warning;
  
  static Color error(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.error : LightColors.error;
  
  static Color info(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? DarkColors.info : LightColors.info;
  
  static const List<Color> chartColors = [
    Color(0xFFFFC107),
    Color(0xFFFF5722),
    Color(0xFF4CAF50),
    Color(0xFF9E9E9E),
  ];
}

class AppTextStyles {
  static TextStyle heading1(BuildContext context) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary(context),
    letterSpacing: -0.5,
  );
  
  static TextStyle heading2(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary(context),
  );
  
  static TextStyle heading3(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary(context),
  );
  
  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary(context),
    height: 1.5,
  );
  
  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted(context),
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

class ClassInfo {
  static const Map<String, String> displayNames = {
    'Lebah': 'Bee 🐝',
    'Tawon': 'Wasp 🐝',
    'Lainnya': 'Other Insect 🦗',
    'Bukan_Serangga': 'Not an Insect ❌',
  };
  
  static const Map<String, String> descriptions = {
    'Lebah': 'Pollinating insect with a fuzzy body',
    'Tawon': 'Predatory insect with a slender waist',
    'Lainnya': 'Other types of insects',
    'Bukan_Serangga': 'This is not an insect',
  };
  
  static const Map<String, Color> colors = {
    'Lebah': Color(0xFFFFC107),
    'Tawon': Color(0xFFFF5722),
    'Lainnya': Color(0xFF4CAF50),
    'Bukan_Serangga': Color(0xFF9E9E9E),
  };
  
  static const Map<String, IconData> icons = {
    'Lebah': Icons.emoji_nature,
    'Tawon': Icons.pest_control,
    'Lainnya': Icons.bug_report,
    'Bukan_Serangga': Icons.block,
  };
}
