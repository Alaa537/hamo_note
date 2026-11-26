import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional palette: deep navy + white + gold/yellow accents
class AppColors {
  static const bg = Color(0xFF0B0F1A);
  static const bg2 = Color(0xFF111827);
  static const card = Color(0xFF151C2C);
  static const cardLight = Color(0xFF1C2538);
  static const green = Color(0xFF22C55E);
  static const greenDark = Color(0xFF16A34A);
  static const gold = Color(0xFFFBBF24); // primary yellow/gold
  static const goldSoft = Color(0xFFFDE68A);
  static const red = Color(0xFFEF4444);
  static const text = Color(0xFFF8FAFC);
  static const textDim = Color(0xFF94A3B8);
  static const border = Color(0xFF243044);
  static const white = Color(0xFFFFFFFF);
}

class AppLightColors {
  static const bg = Color(0xFFF8FAFC);
  static const bg2 = Color(0xFFF1F5F9);
  static const card = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFF8FAFC);
  static const green = Color(0xFF16A34A);
  static const greenDark = Color(0xFF15803D);
  static const gold = Color(0xFFD97706); // warm professional gold
  static const goldSoft = Color(0xFFFEF3C7);
  static const red = Color(0xFFDC2626);
  static const text = Color(0xFF0F172A);
  static const textDim = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const white = Color(0xFFFFFFFF);
}

extension AppCtx on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get appBg => Theme.of(this).scaffoldBackgroundColor;
  Color get appCard => isDark ? AppColors.card : AppLightColors.card;
  Color get appCardLight =>
      isDark ? AppColors.cardLight : AppLightColors.cardLight;
  Color get appText => isDark ? AppColors.text : AppLightColors.text;
  Color get appTextDim => isDark ? AppColors.textDim : AppLightColors.textDim;
  Color get appBorder => isDark ? AppColors.border : AppLightColors.border;
  Color get appGreen => isDark ? AppColors.green : AppLightColors.green;
  Color get appGreenDark =>
      isDark ? AppColors.greenDark : AppLightColors.greenDark;
  Color get appRed => isDark ? AppColors.red : AppLightColors.red;
  Color get appGold => isDark ? AppColors.gold : AppLightColors.gold;
  Color get appGoldSoft =>
      isDark ? AppColors.goldSoft : AppLightColors.goldSoft;
  Color get appWhite => AppColors.white;
}

class AppTheme {
  static ThemeData _base({
    required Brightness brightness,
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
      brightness: brightness,
      scaffoldBackgroundColor: bg,
    );
    return base.copyWith(
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: gold,
        onPrimary: Colors.black,
        secondary: green,
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
        iconTheme: IconThemeData(color: gold),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          borderSide: BorderSide(color: gold, width: 1.5),
        ),
        hintStyle: TextStyle(color: textDim),
        labelStyle: TextStyle(color: textDim),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: gold.withOpacity(0.45),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle:
              GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: GoogleFonts.cairo(color: text, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.cairo(
          color: text, fontSize: 18, fontWeight: FontWeight.w800,
        ),
        contentTextStyle: GoogleFonts.cairo(color: textDim, fontSize: 14),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    );
  }

  static ThemeData get dark {
    return _base(
      brightness: Brightness.dark,
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
  }

  static ThemeData get light {
    return _base(
      brightness: Brightness.light,
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
  }
}


class AppBackgrounds {
  static const names = [
    'كلاسيك',
    'ذهبي ناعم',
    'منتصف الليل',
    'نعناعي',
    'وردي',
  ];

  static List<Color> colors(int style, bool isDark) {
    if (isDark) {
      switch (style) {
        case 1:
          return [const Color(0xFF1A1408), const Color(0xFF0B0F1A)];
        case 2:
          return [const Color(0xFF0A0E1A), const Color(0xFF1E1B4B)];
        case 3:
          return [const Color(0xFF0A1F1A), const Color(0xFF0B0F1A)];
        case 4:
          return [const Color(0xFF1A0A14), const Color(0xFF0B0F1A)];
        default:
          return [const Color(0xFF0B0F1A), const Color(0xFF0B0F1A)];
      }
    } else {
      switch (style) {
        case 1:
          return [const Color(0xFFFFFBEB), const Color(0xFFF8FAFC)];
        case 2:
          return [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)];
        case 3:
          return [const Color(0xFFECFDF5), const Color(0xFFF8FAFC)];
        case 4:
          return [const Color(0xFFFDF2F8), const Color(0xFFF8FAFC)];
        default:
          return [const Color(0xFFF8FAFC), const Color(0xFFF8FAFC)];
      }
    }
  }
}
