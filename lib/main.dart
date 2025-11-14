import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nookat996/core/providers/favorites_provider.dart';
import 'package:nookat996/core/providers/theme_provider.dart';
import 'package:nookat996/core/providers/category_provider.dart';
import 'package:nookat996/core/providers/pinned_message_provider.dart';
import 'package:nookat996/core/providers/city_board_provider.dart';
import 'package:nookat996/core/providers/contact_info_provider.dart';
import 'package:nookat996/core/providers/search_provider.dart';
import 'package:nookat996/constants/app_theme.dart';
import 'package:nookat996/constants/app_colors.dart';
import 'package:nookat996/screens/splash_screen.dart';
import 'package:nookat996/cubits/navigation_cubit.dart';

// Local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Navigator key for showing dialogs/snackbars without BuildContext plumbing
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
const MethodChannel _androidNotifChannel =
    MethodChannel('kg.aimak996.nookat996/notifications');

// Android notification channel
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
  playSound: true,
);

// Show local notification for an FCM message
Future<void> showFlutterNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails details = NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    details,
    payload: message.data['route'] ?? '/',
  );
}

void handleNotificationNavigation(RemoteMessage message) {
  final route = message.data['route'] ?? '/';
  debugPrint('[FCM][NAV] route=$route');
  // TODO: integrate with your Navigator if needed.
}

Future<void> setupFlutterNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  await showFlutterNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      // iOS permission prompt
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      // Android 13+ runtime notification permission
      if (Platform.isAndroid) {
        final initial = await Permission.notification.status;
        debugPrint('Android notification permission (initial): $initial');
        var notifStatus = initial;
        if (!initial.isGranted) {
          notifStatus = await Permission.notification.request();
        }
        debugPrint('Android notification permission (after request): $notifStatus');
        if (notifStatus.isPermanentlyDenied) {
          debugPrint('Notification permission permanently denied. Opening app settings...');
          await openAppSettings();
        }
      }
      // Local notifications & foreground presentation
      await setupFlutterNotifications();

      final fcmToken = await messaging.getToken();
      debugPrint('FCM Token: $fcmToken');
      await FirebaseMessaging.instance.subscribeToTopic('all_users');

      // Background handler must be set early, before runApp
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler);

      // Foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            '[FCM][FG] notification=${message.notification?.title} | ${message.notification?.body} data=${message.data}');
        showFlutterNotification(message);
      });

      // App opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM][OPENED] data=${message.data}');
        handleNotificationNavigation(message);
      });
    } catch (e, st) {
      debugPrint('Firebase init failed: $e');
      debugPrint('$st');
    }
  }
  await EasyLocalization.ensureInitialized();

  // Получение и вывод FCM токена

  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('locale') ?? 'ru';

  // Зафиксировать ориентацию экрана в портретной
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enable edge-to-edge for Flutter content
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Set transparent system bars; icon brightness will be adjusted by themes/screens as needed
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: AppColors.primaryBlue,
    // Force light (white) icons/text regardless of app theme
    statusBarIconBrightness: Brightness.light, // Android
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark, // iOS: dark background implies light content
  ));

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ky'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      startLocale: Locale(langCode),
      child: const MyApp(),
    ),
  );

  // After first frame, drive a visible permission prompt UI for Android
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (Platform.isAndroid) {
      // Give the first frame a tiny time to mount a route with context
      await Future.delayed(const Duration(milliseconds: 200));
      await _ensureNotificationPermissionWithUI();
    }
  });
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
          navigatorKey: rootNavigatorKey,
          title: 'Ноокат 996',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light, // Android
              statusBarBrightness: Brightness.dark, // iOS
              systemNavigationBarColor: AppColors.primaryBlue,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
          home: SplashScreen(
            isDark: themeProvider.isDark,
            toggleTheme: themeProvider.toggleTheme,
          ),
        ),
      ),
    );
  }
}

Future<void> _ensureNotificationPermissionWithUI() async {
  try {
    final status = await Permission.notification.status;
    if (status.isGranted) {
      _showSnack('Уведомления уже разрешены');
      return;
    }

    final ctx = rootNavigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;

    final result = await showDialog<String>(
      context: ctx,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Разрешить уведомления'),
        content: const Text(
            'Чтобы получать важные сообщения, включите уведомления для приложения.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Позже'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('allow'),
            child: const Text('Разрешить'),
          ),
        ],
      ),
    );

    if (result == 'allow') {
      // First, try native Android 13+ system dialog explicitly
      try {
        await _androidNotifChannel.invokeMethod('requestPostNotifications');
      } catch (_) {}
      // Then, ask via permission_handler to unify status reporting
      var newStatus = await Permission.notification.request();
      _showSnack('Статус уведомлений: $newStatus');
      if (newStatus.isPermanentlyDenied) {
        _showSnack('Разрешение навсегда запрещено. Откроем настройки…');
        await openAppSettings();
      }
    }
  } catch (e) {
    _showSnack('Ошибка запроса уведомлений: $e');
  }
}

void _showSnack(String msg) {
  final ctx = rootNavigatorKey.currentState?.overlay?.context;
  if (ctx == null) return;
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
}
