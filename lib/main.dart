import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

import 'package:projects/core/providers/favorites_provider.dart';
import 'package:projects/core/providers/search_provider.dart';
import 'package:projects/core/providers/theme_provider.dart';
import 'package:projects/core/providers/category_provider.dart';
import 'package:projects/constants/app_theme.dart';
import 'package:projects/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('locale') ?? 'ru';

  _testApi(); // Тестовый вызов

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ky'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      startLocale: Locale(langCode),
      child: const AppRoot(),
    ),
  );
}

// Тестовый метод для проверки API
Future<void> _testApi() async {
  try {
    developer.log('Starting API test');
    final response = await http.get(
      Uri.parse('http://5.59.233.32:8080/categories/get'),
      headers: {
        'Accept': '*/*',
      },
    );
    developer.log('Response status: ${response.statusCode}');
    developer.log('Response body: ${response.body}');
  } catch (e, stack) {
    developer.log('API test error', error: e, stackTrace: stack);
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Аймак 996',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: SplashScreen(
            isDark: themeProvider.isDark,
            toggleTheme: themeProvider.toggleTheme,
          ),
        ),
      ),
    );
  }
}
