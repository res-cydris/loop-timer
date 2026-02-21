import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loop_timer/models/app_settings.dart';

/// Provides [ThemeData] for every theme identifier in [ThemeIds].
class AppThemes {
  AppThemes._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the full [ThemeData] for [themeId].
  static ThemeData themeData(String themeId) {
    switch (themeId) {
      case ThemeIds.light:
        return _lightTheme();
      case ThemeIds.modern:
        return _modernTheme();
      case ThemeIds.retro:
        return _retroTheme();
      case ThemeIds.rgb:
        return _rgbTheme();
      case ThemeIds.futuristic:
        return _futuristicTheme();
      case ThemeIds.colorblind:
        return _colorblindTheme();
      case ThemeIds.dark:
      default:
        return _darkTheme();
    }
  }

  /// Returns the primary accent [Color] for a theme — useful for widget
  /// accent painting outside the normal [ColorScheme] flow.
  static Color primaryColor(String themeId) {
    switch (themeId) {
      case ThemeIds.light:
        return const Color(0xFF6200EE);
      case ThemeIds.modern:
        return const Color(0xFFFF6B6B);
      case ThemeIds.retro:
        return const Color(0xFFFF6600);
      case ThemeIds.rgb:
        return const Color(0xFF00BFFF);
      case ThemeIds.futuristic:
        return const Color(0xFF00F5FF);
      case ThemeIds.colorblind:
        return const Color(0xFF0072B2);
      case ThemeIds.dark:
      default:
        return const Color(0xFFBB86FC);
    }
  }

  /// Returns `true` when the theme has a dark background.
  static bool isDark(String themeId) {
    switch (themeId) {
      case ThemeIds.light:
      case ThemeIds.modern:
      case ThemeIds.colorblind:
        return false;
      default:
        return true;
    }
  }

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static ThemeData _darkTheme() {
    const bg = Color(0xFF0D0D0D);
    const surface = Color(0xFF1E1E1E);
    const accent = Color(0xFFBB86FC);
    const onSurface = Colors.white;

    final colorScheme = ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.black,
      secondary: const Color(0xFF03DAC6),
      onSecondary: Colors.black,
      surface: surface,
      onSurface: onSurface,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
    );

    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: accent.withAlpha(76),
        overlayColor: accent.withAlpha(51),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withAlpha(127)
              : Colors.grey.withAlpha(76),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent.withAlpha(76)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent.withAlpha(76)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      iconTheme: const IconThemeData(color: onSurface),
    );
  }

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  static ThemeData _lightTheme() {
    const bg = Color(0xFFFAFAFA);
    const surface = Color(0xFFFFFFFF);
    const accent = Color(0xFF6200EE);
    const onSurface = Color(0xFF1C1B1F);

    final colorScheme = ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      secondary: const Color(0xFF03DAC6),
      onSecondary: Colors.black,
      surface: surface,
      onSurface: onSurface,
      error: const Color(0xFFB00020),
      onError: Colors.white,
    );

    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        shadowColor: Colors.black12,
        titleTextStyle: GoogleFonts.inter(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: accent.withAlpha(51),
        overlayColor: accent.withAlpha(31),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withAlpha(127)
              : Colors.grey.withAlpha(76),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        labelStyle: TextStyle(color: onSurface.withAlpha(178)),
        hintStyle: TextStyle(color: onSurface.withAlpha(102)),
      ),
      iconTheme: const IconThemeData(color: onSurface),
    );
  }

  // ---------------------------------------------------------------------------
  // Modern theme
  // ---------------------------------------------------------------------------

  static ThemeData _modernTheme() {
    const bg = Color(0xFFF5F5F5);
    const surface = Color(0xFFFFFFFF);
    const accent = Color(0xFFFF6B6B);
    const onSurface = Color(0xFF2D2D2D);

    final colorScheme = ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      secondary: const Color(0xFF4ECDC4),
      onSecondary: Colors.white,
      surface: surface,
      onSurface: onSurface,
      error: const Color(0xFFE53935),
      onError: Colors.white,
    );

    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          color: onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
          elevation: 4,
          shadowColor: accent.withAlpha(127),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.black.withAlpha(13), width: 1.5),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: accent.withAlpha(51),
        overlayColor: accent.withAlpha(31),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withAlpha(127)
              : Colors.grey.withAlpha(76),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        labelStyle: TextStyle(color: onSurface.withAlpha(153)),
        hintStyle: TextStyle(color: onSurface.withAlpha(102)),
      ),
      iconTheme: const IconThemeData(color: onSurface),
    );
  }

  // ---------------------------------------------------------------------------
  // Retro theme
  // ---------------------------------------------------------------------------

  static ThemeData _retroTheme() {
    const bg = Color(0xFF1A0A00);
    const surface = Color(0xFF2A1500);
    const accent = Color(0xFFFF6600);
    const secondary = Color(0xFF00FF41);
    const onSurface = Color(0xFFFF6600);

    final colorScheme = ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.black,
      secondary: secondary,
      onSecondary: Colors.black,
      surface: surface,
      onSurface: onSurface,
      error: const Color(0xFFFF3333),
      onError: Colors.black,
    );

    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      textTheme: GoogleFonts.vt323TextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: accent,
        elevation: 0,
        titleTextStyle: GoogleFonts.vt323(
          color: accent,
          fontSize: 26,
          letterSpacing: 2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: accent,
          side: const BorderSide(color: accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.vt323(
            fontSize: 20,
            letterSpacing: 2,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: accent, width: 1),
        ),
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: accent.withAlpha(51),
        overlayColor: accent.withAlpha(51),
        trackHeight: 3,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withAlpha(127)
              : Colors.grey.withAlpha(76),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: accent, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: accent.withAlpha(127), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: secondary, width: 2),
        ),
        labelStyle: TextStyle(color: accent.withAlpha(178), fontFamily: 'VT323'),
        hintStyle: TextStyle(color: accent.withAlpha(102), fontFamily: 'VT323'),
      ),
      iconTheme: const IconThemeData(color: accent),
    );
  }

  // ---------------------------------------------------------------------------
  // RGB / Gaming theme
  // ---------------------------------------------------------------------------

  static ThemeData _rgbTheme() {
    const bg = Color(0xFF0A0A0A);
    const surface = Color(0xFF141414);
    const accent = Color(0xFF00BFFF);
    const secondary = Color(0xFFFF00FF);
    const onSurface = Colors.white;

    final colorScheme = ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.black,
      secondary: secondary,
      onSecondary: Colors.black,
      surface: surface,
      onSurface: onSurface,
      error: const Color(0xFFFF3333),
      onError: Colors.black,
    );

    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      textTheme: GoogleFonts.rajdhaniTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: accent,
        elevation: 0,
        titleTextStyle: GoogleFonts.rajdhani(
          color: accent,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: accent.withAlpha(76), width: 1),
        ),
        elevation: 4,
        shadowColor: accent.withAlpha(51),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: secondary,
        inactiveTrackColor: accent.withAlpha(51),
        overlayColor: accent.withAlpha(51),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withAlpha(127)
              : Colors.grey.withAlpha(76),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent.withAlpha(76)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent.withAlpha(76)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      iconTheme: const IconThemeData(color: accent),
    );
  }

  // ---------------------------------------------------------------------------
  // Futuristic theme
  // ---------------------------------------------------------------------------

  static ThemeData _futuristicTheme() {
    const bg = Color(0xFF04080F);
    const surface = Color(0xFF0A1628);
    const accent = Color(0xFF00F5FF);
    const secondary = Color(0xFF7B2FBE);
    const onSurface = Colors.white;

    final colorScheme = ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.black,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: onSurface,
      error: const Color(0xFFFF4444),
      onError: Colors.black,
    );

    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      textTheme: GoogleFonts.orbitronTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: accent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: accent,
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          color: accent,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: accent,
          side: const BorderSide(color: accent, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0xFF00F5FF), width: 1),
        ),
        elevation: 0,
        shadowColor: accent.withAlpha(102),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: accent.withAlpha(51),
        overlayColor: accent.withAlpha(51),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withAlpha(127)
              : Colors.grey.withAlpha(76),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: accent.withAlpha(102)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: accent.withAlpha(102)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        labelStyle: TextStyle(color: accent.withAlpha(178)),
        hintStyle: TextStyle(color: accent.withAlpha(102)),
      ),
      iconTheme: const IconThemeData(color: accent),
    );
  }

  // ---------------------------------------------------------------------------
  // Colorblind-accessible theme
  // ---------------------------------------------------------------------------

  static ThemeData _colorblindTheme() {
    const bg = Color(0xFFFFFFFF);
    const surface = Color(0xFFF8F8F8);
    const accent = Color(0xFF0072B2); // blue — safe for all forms of CVD
    const secondary = Color(0xFFE69F00); // amber
    const onSurface = Color(0xFF000000);

    final colorScheme = ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.black,
      surface: surface,
      onSurface: onSurface,
      error: const Color(0xFF56B4E9), // sky blue — avoids red/green
      onError: Colors.black,
    );

    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ).copyWith(
        // Larger text sizes for accessibility
        bodyLarge: GoogleFonts.roboto(
          fontSize: 18,
          color: onSurface,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 16,
          color: onSurface,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 14,
          color: onSurface,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.roboto(
          fontSize: 24,
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.roboto(
          fontSize: 20,
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.roboto(
          color: onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF000000), width: 1.5),
        ),
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: const Color(0xFFCCCCCC),
        overlayColor: accent.withAlpha(51),
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withAlpha(127)
              : Colors.grey.withAlpha(76),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black54, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 2.5),
        ),
        labelStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: Colors.black54, fontSize: 16),
      ),
      iconTheme: const IconThemeData(color: onSurface, size: 28),
    );
  }
}
