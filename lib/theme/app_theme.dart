import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const background = Color(0xFFF3F6FB);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE4E9F1);
  static const text = Color(0xFF18212F);
  static const secondary = Color(0xFF5D6B80);
  static const muted = Color(0xFF8F9BAD);
  static const primary = Color(0xFF185FA5);
  static const primaryLight = Color(0xFFE6F1FB);
  static const success = Color(0xFF2F7D4F);
  static const successLight = Color(0xFFE5F4EA);
  static const warning = Color(0xFFA5650B);
  static const warningLight = Color(0xFFFDF0D9);
  static const danger = Color(0xFFA32D2D);
  static const dangerLight = Color(0xFFFCEBEB);

  // Compatibility names used by the existing screens during the UI migration.
  static const backgroundLegacy = background;
  static const surface = card;
  static const primaryContainer = primaryLight;
  static const textPrimary = text;
  static const textSecondary = secondary;
  static const outline = border;
  static const disabled = muted;
  static const error = danger;
}

abstract final class AppRadii {
  static const card = 16.0;
  static const control = 12.0;
  static const chip = 16.0;
  static const sheet = 24.0;
}

abstract final class AppTheme {
  static const fontFamily = 'Inter';
  static ThemeData get light {
    final scheme = const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.success,
      onSecondary: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.secondary,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      error: AppColors.danger,
      onError: Colors.white,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.text),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
      bodyLarge: GoogleFonts.inter(fontSize: 14, color: AppColors.text),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.secondary),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary),
    );
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(color: AppColors.muted),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(44, 44),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.chip)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.success,
        linearTrackColor: AppColors.card,
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  static OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.control),
    borderSide: BorderSide(color: color, width: width),
  );
}
