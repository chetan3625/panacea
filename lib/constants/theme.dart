import 'package:flutter/material.dart';

/// Colors sampled from the "Mobile Apps Prototyping Kit" image.
/// Sampled: primary, text, background, primary container, outline.
/// Estimated (typical for this kit's style): secondary text, disabled, error, success.
class AppColors {
  AppColors._();

  static const Color primary = Color(
    0xFF006FFD,
  ); // buttons, toggles, sent bubbles
  static const Color primaryContainer = Color(
    0xFFEAF2FF,
  ); // selected chips, image placeholders
  static const Color background = Color(0xFFF8F9FE); // page background
  static const Color surface = Color(0xFFFFFFFF); // cards, inputs, sheets
  static const Color textPrimary = Color(0xFF1F2024); // headings
  static const Color textSecondary = Color(
    0xFF71727A,
  ); // body / hints (estimated)
  static const Color outline = Color(0xFFE9E9F1); // borders, dividers
  static const Color disabled = Color(0xFFC5C6CC); // (estimated)
  static const Color error = Color(0xFFFF3B30); // (estimated)
  static const Color success = Color(0xFF3AC0A0); // (estimated)
}

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'PanaceaSans';

  static final ColorScheme _colorScheme = const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.primary,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
    error: AppColors.error,
    onError: Colors.white,
  );

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.outline,
    splashFactory: InkRipple.splashFactory,

    // ---------- Typography ----------
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),

    // ---------- App bar ----------
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),

    // ---------- Buttons ----------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.disabled,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // ---------- Inputs ----------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      border: _border(AppColors.outline),
      enabledBorder: _border(AppColors.outline),
      focusedBorder: _border(AppColors.primary, 1.5),
      errorBorder: _border(AppColors.error),
      focusedErrorBorder: _border(AppColors.error, 1.5),
    ),

    // ---------- Cards / chips / lists ----------
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outline),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primaryContainer,
      side: const BorderSide(color: AppColors.outline),
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
      space: 1,
    ),

    // ---------- Selection controls ----------
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.disabled,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.transparent,
      ),
      side: const BorderSide(color: AppColors.disabled, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.disabled,
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.outline,
      thumbColor: AppColors.primary,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.outline,
    ),

    // ---------- Navigation / sheets / dialogs ----------
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      dividerColor: AppColors.outline,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
