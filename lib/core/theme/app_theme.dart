import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF0B6E4F);
  static const Color primaryLight = Color(0xFF16A873);
  static const Color primaryLighter = Color(0xFFE9FFF5);
  static const Color primaryGlow = Color(0xFF24D39B);
  static const Color ink = Color(0xFF0D1F1A);

  static const Color secondary = Color(0xFFFF6F61);
  static const Color secondaryLight = Color(0xFFFFEEE9);

  static const Color accent = Color(0xFF3577FF);
  static const Color amber = Color(0xFFFFB020);
  static const Color cyan = Color(0xFF00B8D9);

  static const Color background = Color(0xFFF5F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDF4F0);
  static const Color outline = Color(0xFFDCE8E2);

  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF52615B);
  static const Color textTertiary = Color(0xFF87938E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF10B981);
  static const Color warning = amber;
  static const Color error = Color(0xFFEF4444);
  static const Color info = accent;

  static const List<Color> primaryGradientColors = [
    Color(0xFF085C43),
    Color(0xFF11A46F),
    Color(0xFF42DFA6),
  ];
  static const List<Color> heroGradientColors = [
    Color(0xFF071D19),
    Color(0xFF0A6847),
    Color(0xFF18C98C),
  ];
  static const List<Color> cardGradientColors = [
    Color(0xFFFFFFFF),
    Color(0xFFEFFFF7),
    Color(0xFFFFF6EF),
  ];
  static const List<Color> blueGradientColors = [
    Color(0xFF112A66),
    Color(0xFF3577FF),
  ];
}

class AppTheme {
  static const primary = AppColors.primary;

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLighter,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryLight,
          tertiary: AppColors.accent,
          surface: AppColors.surface,
          surfaceContainerHighest: AppColors.surfaceVariant,
          error: AppColors.error,
          onPrimary: AppColors.textOnPrimary,
          onSurface: AppColors.textPrimary,
          outline: AppColors.outline,
        );

    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,

      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        backgroundColor: AppColors.surface.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.ink,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.ink : AppColors.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 23,
            color: selected ? Colors.white : AppColors.textTertiary,
          );
        }),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 54),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outline, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 54),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.primary : null,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryLighter,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFF0F0F0),
        thickness: 1,
      ),
    );
  }

  // ======== GRADIENT HELPERS ========
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: AppColors.primaryGradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get heroGradient => const LinearGradient(
    colors: AppColors.heroGradientColors,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get cardGradient => const LinearGradient(
    colors: AppColors.cardGradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => const LinearGradient(
    colors: [Color(0xFF3577FF), Color(0xFF00B8D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get blueGradient => const LinearGradient(
    colors: AppColors.blueGradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ======== SHADOW HELPERS ========
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0B6E4F).withValues(alpha: 0.1),
      blurRadius: 26,
      offset: const Offset(0, 14),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: const Color(0xFF0B6E4F).withValues(alpha: 0.16),
      blurRadius: 14,
      offset: const Offset(0, 6),
      spreadRadius: -6,
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF0D1F1A).withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 9),
    ),
  ];

  static List<BoxShadow> get liquidShadow => [
    BoxShadow(
      color: const Color(0xFF0D1F1A).withValues(alpha: 0.08),
      blurRadius: 30,
      offset: const Offset(0, 16),
      spreadRadius: -10,
    ),
  ];
}
