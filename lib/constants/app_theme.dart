import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const String appName = 'Ноокат 996';

  // Light Theme Colors
  static const lightPrimary = Color(0xFF1E3A8A);
  static const lightSecondary = Color(0xFF25D366);
  static const lightBackground = Color(0xFFF8F9FB);
  static const lightSurface = Colors.white;
  static const lightError = Color(0xFFDC2626);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightBorder = Color(0xFFE5E7EB);
  static const lightCardShadow = Color(0x1A000000);
  static const drawerButtonBg = Color(0xFF2563EB);

  // Dark Theme Colors
  static const darkPrimary = Color(0xFF1E3A8A);
  static const darkSecondary = Color(0xFF25D366);
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkCard = Color(0xFF1E293B);
  static const darkDrawer = Color(0xFF1E3A8A);
  static const darkError = Color(0xFFEF4444);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);

  static TextTheme _buildTextTheme(TextTheme base, bool isDark) {
    final color = isDark ? darkTextPrimary : lightTextPrimary;
    
    return base.copyWith(
      displayLarge: GoogleFonts.jost(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      ),
      displayMedium: GoogleFonts.jost(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      ),
      displaySmall: GoogleFonts.jost(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      ),
      headlineLarge: GoogleFonts.arsenal(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color,
      ),
      headlineMedium: GoogleFonts.arsenal(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: color,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: color,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: color,
      ),
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: isDark ? darkTextSecondary : lightTextSecondary,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        color: isDark ? darkTextSecondary : lightTextSecondary,
      ),
    );
  }

  static ThemeData get light {
    final base = ThemeData.light();
    final textTheme = _buildTextTheme(base.textTheme, false);

    return base.copyWith(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        error: lightError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
      ),
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSurface,
      dividerColor: lightBorder,
      primaryColor: lightPrimary,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: lightPrimary,
        textColor: lightTextPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 20,
        dense: true,
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 32,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark();
    final textTheme = _buildTextTheme(base.textTheme, true);

    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        error: darkError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      dividerColor: darkTextSecondary.withOpacity(0.1),
      primaryColor: darkPrimary,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkDrawer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white,
        textColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 20,
        dense: true,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
        space: 32,
      ),
    );
  }
}
