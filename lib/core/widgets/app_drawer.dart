import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:projects/features/favorites/favorites_screen.dart';
import 'package:projects/features/about/about_screen.dart';
import 'package:projects/features/about/feedback_screen.dart';
import 'package:projects/features/about/developer_screen.dart';
import 'package:projects/features/district/district_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/core/widgets/theme_toggle_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';

class AppDrawer extends StatefulWidget {
  static const String _whatsappNumber = '996999109190';

  final bool isDark;
  final VoidCallback toggleTheme;

  const AppDrawer({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    super.initState();
    _playDrawerSound();
  }

  Future<void> _playDrawerSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/drawer_open.wav'), volume: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: isDarkMode ? theme.colorScheme.surface : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 286,
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/header_drawer.jpg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 286,
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DistrictScreen(),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Ошибка перехода в "О районе": $e')),
                              );
                            }
                            _playDrawerSound();
                          },
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white, width: 1),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: Center(
                              child: Text(
                                'drawer_district'.tr(),
                                style: const TextStyle(
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
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOOKAT 996',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Arsenal',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 36,
                    color:
                        isDarkMode ? theme.colorScheme.onSurface : Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Ноокат району үчүн\nсатып алуу жана сатуу\nмобилдик тиркемеси',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode
                        ? theme.colorScheme.onSurface.withOpacity(0.7)
                        : const Color(0xFF757575),
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(
            context: context,
            icon: Icons.add_circle_outline,
            title: 'add_ad'.tr(),
            onTap: () async {
              Navigator.pop(context);
              await _playDrawerSound();
              try {
                await _launchWhatsApp(context, AppDrawer._whatsappNumber);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка открытия WhatsApp: $e')),
                );
              }
            },
          ),
          const SizedBox(height: 4),
          _buildDrawerItem(
            context: context,
            icon: Icons.favorite_border,
            title: 'favorites'.tr(),
            onTap: () async {
              Navigator.pop(context);
              await _playDrawerSound();
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка перехода в избранное: $e')),
                );
              }
            },
          ),
          const SizedBox(height: 4),
          _buildDrawerItem(
            context: context,
            icon: Icons.info_outline,
            title: 'drawer_about_us'.tr(),
            onTap: () async {
              Navigator.pop(context);
              await _playDrawerSound();
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка перехода в "О нас": $e')),
                );
              }
            },
          ),
          const Spacer(),
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
                ThemeToggleButton(
                    isDark: widget.isDark, toggleTheme: widget.toggleTheme),
                _buildCircleButton(
                  context,
                  Icons.share,
                  () {
                    Share.share('share_text'.tr());
                  },
                ),
                const LanguageToggleSwitch(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context, String number) async {
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('whatsapp_error'.tr())),
      );
    }
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSubItem = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSubItem ? 32 : 16,
        vertical: 4,
      ),
      child: Material(
        color: isDarkMode
            ? theme.colorScheme.surface.withOpacity(isSubItem ? 0.5 : 0.8)
            : const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: isSubItem ? 8 : 12),
            decoration: isDarkMode
                ? BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.18),
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Row(
              children: [
                if (isSubItem) const SizedBox(width: 8),
                Icon(
                  icon,
                  size: isSubItem ? 20 : 22,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSubItem ? 14 : 15,
                    fontWeight: isSubItem ? FontWeight.w400 : FontWeight.w500,
                    color: isDarkMode
                        ? theme.colorScheme.onSurface.withOpacity(0.95)
                        : const Color(0xFF1E3A8A),
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
    final theme = Theme.of(context);

    return Material(
      color: isDarkMode
          ? theme.colorScheme.surface.withOpacity(0.7)
          : const Color(0xFFE8F0FE),
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: isDarkMode
                ? theme.colorScheme.primary
                : const Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }
}

class LanguageToggleSwitch extends StatefulWidget {
  const LanguageToggleSwitch({super.key});

  @override
  State<LanguageToggleSwitch> createState() => _LanguageToggleSwitchState();
}

class _LanguageToggleSwitchState extends State<LanguageToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    final isKyrgyz = context.locale.languageCode == 'ky';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final newLocale = isKyrgyz ? const Locale('ru') : const Locale('ky');
          await context.setLocale(newLocale);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('locale', newLocale.languageCode);
          setState(() {});
        },
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/kg_flag.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.sync_alt, size: 18, color: Colors.blueAccent),
              const SizedBox(width: 6),
              ClipOval(
                child: Image.asset(
                  'assets/images/ru_flag.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
