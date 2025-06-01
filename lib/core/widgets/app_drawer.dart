import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:projects/features/favorites/favorites_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/core/widgets/theme_toggle_button.dart';

class AppDrawer extends StatelessWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const AppDrawer({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  Future<void> _launchWhatsApp(String number) async {
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      BuildContext context, IconData icon, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color:
          isDarkMode ? Colors.white.withOpacity(0.1) : const Color(0xFFE8F0FE),
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Верхняя часть с изображением
          SizedBox(
            height: 286,
            child: Stack(
              children: [
                // Фоновое изображение
                Image.asset(
                  "assets/images/header_drawer.jpg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 286,
                ),
                // Прозрачная кнопка "Район жөнүндө"
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white, width: 1),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Center(
                          child: Text(
                            'Район жөнүндө',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Заголовок и описание
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'НООКАТ 996',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDarkMode
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Ноокат району үчүн\nсатып алуу жана сатуу\nмобилдик тиркеме',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          // Кнопки меню
          _buildDrawerItem(
            context: context,
            icon: Icons.add_circle_outline,
            title: 'Жарыя беруу',
            onTap: () => _launchWhatsApp('996999109190'),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.favorite_border,
            title: 'Жаккандар',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.group_outlined,
            title: 'Биз жөнүндө',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('soon_available'.tr())),
              );
            },
          ),
          const Spacer(),
          // Нижняя панель с кнопками
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Theme.of(context).dividerColor,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ThemeToggleButton(isDark: isDark, toggleTheme: toggleTheme),
                _buildCircleButton(context, Icons.share, () {}),
                _buildCircleButton(
                  context,
                  Icons.language,
                  () async {
                    final prefs = await SharedPreferences.getInstance();
                    final currentLocale = context.locale.languageCode;
                    final newLocale = currentLocale == 'ky' ? 'ru' : 'ky';
                    await context.setLocale(Locale(newLocale));
                    await prefs.setString('locale', newLocale);
                  },
                ),
                _buildCircleButton(context, Icons.refresh, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
