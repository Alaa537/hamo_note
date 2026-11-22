import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0A0E1A);
  static const bg2 = Color(0xFF0E1524);
  static const card = Color(0xFF141C2E);
  static const cardLight = Color(0xFF1A2332);
  static const green = Color(0xFF00E676);
  static const greenDark = Color(0xFF00C853);
  static const gold = Color(0xFFFFD54F);
  static const red = Color(0xFFFF5252);
  static const text = Color(0xFFF5F7FA);
  static const textDim = Color(0xFF8A93A8);
  static const border = Color(0xFF1E2A40);
}

class AppLightColors {
  static const bg = Color(0xFFF5F7FA);
  static const bg2 = Color(0xFFEEF2F7);
  static const card = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFF3F6FA);
  static const green = Color(0xFF00A650);
  static const greenDark = Color(0xFF00893F);
  static const gold = Color(0xFFD4A017);
  static const red = Color(0xFFE53935);
  static const text = Color(0xFF1A1F2E);
  static const textDim = Color(0xFF6B7280);
  static const border = Color(0xFFE3E8EF);
}

extension AppCtx on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get appBg => Theme.of(this).scaffoldBackgroundColor;
  Color get appCard => isDark ? AppColors.card : AppLightColors.card;
  Color get appCardLight => isDark ? AppColors.cardLight : AppLightColors.cardLight;
  Color get appText => isDark ? AppColors.text : AppLightColors.text;
  Color get appTextDim => isDark ? AppColors.textDim : AppLightColors.textDim;
  Color get appBorder => isDark ? AppColors.border : AppLightColors.border;
  Color get appGreen => isDark ? AppColors.green : AppLightColors.green;
  Color get appGreenDark => isDark ? AppColors.greenDark : AppLightColors.greenDark;
  Color get appRed => isDark ? AppColors.red : AppLightColors.red;
  Color get appGold => isDark ? AppColors.gold : AppLightColors.gold;
}

class AppTheme {
  static ThemeData _base({
    required Color bg,
    required Color card,
    required Color cardLight,
    required Color green,
    required Color greenDark,
    required Color gold,
    required Color red,
    required Color text,
    required Color textDim,
    required Color border,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
    );
    return base.copyWith(
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: green,
        onPrimary: Colors.black,
        secondary: gold,
        onSecondary: Colors.black,
        error: red,
        onError: Colors.white,
        surface: card,
        onSurface: text,
      ),
      scaffoldBackgroundColor: bg,
      cardColor: card,
      canvasColor: bg,
      dividerColor: border,
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: green),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: green, width: 1.5),
        ),
        hintStyle: TextStyle(color: textDim),
        labelStyle: TextStyle(color: textDim),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: green,
        foregroundColor: Colors.black,
      ),
    );
  }

  static ThemeData get dark {
    final t = _base(
      bg: AppColors.bg,
      card: AppColors.card,
      cardLight: AppColors.cardLight,
      green: AppColors.green,
      greenDark: AppColors.greenDark,
      gold: AppColors.gold,
      red: AppColors.red,
      text: AppColors.text,
      textDim: AppColors.textDim,
      border: AppColors.border,
    );
    return t.copyWith(brightness: Brightness.dark);
  }

  static ThemeData get light {
    final t = _base(
      bg: AppLightColors.bg,
      card: AppLightColors.card,
      cardLight: AppLightColors.cardLight,
      green: AppLightColors.green,
      greenDark: AppLightColors.greenDark,
      gold: AppLightColors.gold,
      red: AppLightColors.red,
      text: AppLightColors.text,
      textDim: AppLightColors.textDim,
      border: AppLightColors.border,
    );
    return t.copyWith(brightness: Brightness.light);
  }
}
