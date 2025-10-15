// lib/utils/theme_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemePrefs {
  static const _key = 'is_dark_mode';

  static Future<void> save(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }

  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}
