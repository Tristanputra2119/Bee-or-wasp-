import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const BeeOrWaspApp(),
    ),
  );
}

class BeeOrWaspApp extends StatelessWidget {
  const BeeOrWaspApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Bee or Wasp Classifier',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          home: const HomeScreen(),
        );
      },
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: DarkColors.primary,
        secondary: DarkColors.accent,
        surface: DarkColors.surface,
        error: DarkColors.error,
      ),
      scaffoldBackgroundColor: DarkColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: DarkColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkColors.primary,
          foregroundColor: DarkColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DarkColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.button,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DarkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: LightColors.primary,
        secondary: LightColors.accent,
        surface: LightColors.surface,
        error: LightColors.error,
      ),
      scaffoldBackgroundColor: LightColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: LightColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: LightColors.card,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LightColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.button,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LightColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
