import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projects/features/favorites/favorites_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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
                FaIcon(icon,
                    size: 20,
                    color: isDark ? Colors.white : Colors.blue.shade900),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labelKey.tr(),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.blue.shade900,
                        fontSize: 16,
                      ),
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
    final newLocale =
        currentLang == 'ru' ? const Locale('ky') : const Locale('ru');

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
            SizedBox(
              height: 286,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/header_drawer.jpg",
                    fit: BoxFit.fill,
                    width: MediaQuery.sizeOf(context).width,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: SizedBox(
                        height: 25,
                        width: 135,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              side: const BorderSide(
                                  color: Colors.white, width: 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: const BorderSide(color: Colors.white))),
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 25,
                                width: 135,
                                child: Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5, sigmaY: 5),
                                      child: Container(
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Район жонундо',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.0,
                                    letterSpacing: 0.02,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ноокат 996'.toUpperCase(),
                style: GoogleFonts.jost(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: 0.02,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '''Ноокат району үчүн 
сатып алуу жана сатуу
мобилдик тиркеме ''',
                style: GoogleFonts.jost(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            const Divider(color: Color(0xff7D7D7D), thickness: 0.5),
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
