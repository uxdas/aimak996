import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:projects/constants/app_colors.dart';

class AppTheme {
  static const String appName = 'Ноокат 996';

  static ThemeData get light {
    final base = ThemeData.light();

    return base.copyWith(
      actionIconTheme: ActionIconThemeData(
          drawerButtonIconBuilder: (context) =>
              SvgPicture.asset('assets/icon/drawer_icon.svg')),
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBlue,
      primaryColor: AppColors.primaryBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'Arsenal',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: base.textTheme
          .copyWith(
            bodySmall: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: AppColors.textDark,
            ),
            bodyMedium: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: AppColors.textDark,
            ),
            bodyLarge: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: AppColors.textDark,
            ),
            titleSmall: const TextStyle(
              fontFamily: 'Arsenal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
            titleMedium: const TextStyle(
              fontFamily: 'Arsenal',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            titleLarge: const TextStyle(
              fontFamily: 'Arsenal',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            headlineLarge: const TextStyle(
              fontFamily: 'Arsenal',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            labelSmall: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              color: Colors.grey,
            ),
            labelMedium: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlue,
            ),
          )
          .apply(
            fontFamily: 'Roboto', // Базовый
            bodyColor: AppColors.textDark,
            displayColor: AppColors.textDark,
          ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentBlue,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primaryBlue,
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      actionIconTheme: ActionIconThemeData(
          drawerButtonIconBuilder: (context) =>
              SvgPicture.asset('assets/icon/drawer_icon.svg')),
      scaffoldBackgroundColor: Colors.black,
      primaryColor: AppColors.primaryBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'Arsenal',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: base.textTheme
          .copyWith(
            bodyMedium: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Colors.white,
            ),
            titleMedium: const TextStyle(
              fontFamily: 'Arsenal',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            headlineLarge: const TextStyle(
              fontFamily: 'Arsenal',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            labelSmall: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              color: Colors.grey,
            ),
            labelMedium: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          )
          .apply(
            fontFamily: 'Roboto',
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
    );
  }
}
