import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nookat996/core/providers/favorites_provider.dart';
import 'package:nookat996/core/providers/theme_provider.dart';
import 'package:nookat996/core/providers/category_provider.dart';
import 'package:nookat996/core/providers/pinned_message_provider.dart';
import 'package:nookat996/core/providers/city_board_provider.dart';
import 'package:nookat996/core/providers/contact_info_provider.dart';
import 'package:nookat996/core/providers/search_provider.dart';
import 'package:nookat996/constants/app_theme.dart';
import 'package:nookat996/screens/splash_screen.dart';
import 'package:nookat996/cubits/navigation_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Получение и вывод FCM токена

  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('locale') ?? 'ru';

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ky'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      startLocale: Locale(langCode),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<CategoryProvider>(
            create: (_) => CategoryProvider()),
        ChangeNotifierProvider<FavoritesProvider>(
            create: (_) => FavoritesProvider()),
        ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),
        ChangeNotifierProvider<PinnedMessageProvider>(
            create: (_) => PinnedMessageProvider()),
        ChangeNotifierProvider<CityBoardProvider>(
            create: (_) => CityBoardProvider()),
        ChangeNotifierProvider<ContactInfoProvider>(
            create: (_) => ContactInfoProvider()),
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Ноокат 996',
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
