import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projects/features/favorites/favorites_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatelessWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const AppDrawer({super.key, required this.isDark, required this.toggleTheme});

  Future<void> _launchWhatsApp(String number) async {
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String labelKey,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: isDark ? Colors.grey.shade800 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FaIcon(icon, size: 20, color: isDark ? Colors.white : Colors.blue.shade900),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    labelKey.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.blue.shade900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLanguage(BuildContext context) async {
    final currentLang = context.locale.languageCode;
    final newLocale = currentLang == 'ru' ? const Locale('ky') : const Locale('ru');

    await context.setLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: isDark ? Colors.black : Colors.blue.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/drawer_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 220,
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'drawer_about'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'app_title'.tr(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'about'.tr(),
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              icon: FontAwesomeIcons.circlePlus,
              labelKey: 'drawer_add',
              onTap: () => _launchWhatsApp('996999109190'),
            ),
            _buildMenuButton(
              icon: Icons.favorite,
              labelKey: 'drawer_fav',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
            ),
            _buildMenuButton(
              icon: FontAwesomeIcons.users,
              labelKey: 'drawer_about_us',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('soon_available'.tr())),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleIconButton(icon: Icons.dark_mode, onTap: toggleTheme),
                  _CircleIconButton(icon: Icons.share, onTap: () {}),
                  _CircleIconButton(
                    icon: Icons.language,
                    onTap: () => _toggleLanguage(context),
                  ),
                  _CircleIconButton(icon: Icons.refresh, onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: Theme.of(context).primaryColor,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}
