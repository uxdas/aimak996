import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nookat996/features/favorites/favorites_screen.dart';
import 'package:nookat996/features/about/about_screen.dart';
import 'package:nookat996/features/about/feedback_screen.dart';
import 'package:nookat996/features/about/developer_screen.dart';
import 'package:nookat996/features/district/district_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nookat996/core/widgets/theme_toggle_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:nookat996/core/providers/theme_provider.dart';
import 'package:nookat996/utils/sound_helper.dart';
import 'package:nookat996/utils/theme_prefs.dart';
import 'package:nookat996/core/providers/category_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nookat996/core/providers/contact_info_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDrawer extends StatefulWidget {
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

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  bool _isSoundEnabled = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSoundState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSoundState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  void _toggleSound() {
    setState(() {
      _isSoundEnabled = !_isSoundEnabled;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('sound_enabled', _isSoundEnabled);
    });
  }

  Future<void> _playDrawerSound() async {
    if (!_isSoundEnabled) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPlayTime = prefs.getInt('last_sound_play_time') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if (currentTime - lastPlayTime >= 300) {
        await _audioPlayer.play(AssetSource('sounds/drawer_click.mp3'));
        await prefs.setInt('last_sound_play_time', currentTime);
      }
    } catch (e) {
      debugPrint('Ошибка воспроизведения звука: $e');
    }
  }

  Future<void> _playTestSound() async {
    if (!_isSoundEnabled) return;
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/like.wav'), volume: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Drawer(
      width: 320,
      backgroundColor:
          isDarkMode ? theme.colorScheme.surface : const Color(0xFFF4F8FD),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 286,
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/drawe.png",
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
                  'drawer_subtitle'.tr(),
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
            title: 'drawer_add_ad'.tr(),
            onTap: () async {
              Navigator.pop(context);
              await _playDrawerSound();
              try {
                final contactProvider = context.read<ContactInfoProvider>();
                final phone =
                    contactProvider.moderatorPhone.replaceAll(' ', '');
                await _launchWhatsApp(
                  context,
                  phone,
                  contactProvider.uploadText,
                );
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
            padding: EdgeInsets.only(
              top: 16,
              bottom: 16 + bottomInset,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildThemeToggleButton(),
                      _buildShareButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSoundButton(),
                      _buildLanguageButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _launchWhatsApp(
    BuildContext context,
    String number,
    String message,
  ) async {
    try {
      // Normalize: keep digits and '+', drop '+', convert leading 0 -> 996
      final cleaned = number.replaceAll(RegExp(r'[^0-9+]'), '');
      String phone = cleaned;
      if (phone.startsWith('+')) phone = phone.substring(1);
      if (phone.startsWith('0')) phone = '996${phone.substring(1)}';

      final schemeUri = Uri.parse(
          'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}');
      final hasScheme = await canLaunchUrl(schemeUri);
      if (hasScheme) {
        final launched = await launchUrl(
          schemeUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('whatsapp_error'.tr())),
          );
        }
        return;
      }

      // Fallback to web
      final webUri = Uri.parse(
          'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
      final hasWeb = await canLaunchUrl(webUri);
      if (hasWeb) {
        final launched = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('whatsapp_error'.tr())),
          );
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('whatsapp_error'.tr())),
      );
    } catch (e) {
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
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
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

  Widget _buildThemeToggleButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          widget.toggleTheme();
        },
        child: Container(
          width: 90,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFE3F2FD).withOpacity(0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white : theme.colorScheme.primary,
              width: 1.2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 6,
                top: 8,
                child: Icon(
                  Icons.light_mode,
                  size: 20,
                  color: isDark
                      ? (isDark ? Colors.white : const Color(0xFF2563EB))
                      : Colors.white.withOpacity(0.6),
                ),
              ),
              Positioned(
                right: 6,
                top: 8,
                child: Icon(
                  Icons.dark_mode,
                  size: 20,
                  color: isDark
                      ? Colors.white.withOpacity(0.6)
                      : (isDark ? Colors.white : const Color(0xFF2563EB)),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: isDark ? 50 : 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white : theme.colorScheme.primary,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _toggleSound();
        },
        child: Container(
          width: 90,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFE3F2FD).withOpacity(0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white : theme.colorScheme.primary,
              width: 1.2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 6,
                top: 8,
                child: Icon(
                  Icons.volume_off,
                  size: 20,
                  color: _isSoundEnabled
                      ? (isDark ? Colors.white : const Color(0xFF2563EB))
                      : Colors.white.withOpacity(0.6),
                ),
              ),
              Positioned(
                right: 6,
                top: 8,
                child: Icon(
                  Icons.volume_up,
                  size: 20,
                  color: _isSoundEnabled
                      ? Colors.white.withOpacity(0.6)
                      : (isDark ? Colors.white : const Color(0xFF2563EB)),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: _isSoundEnabled ? 50 : 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white : theme.colorScheme.primary,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = context.locale;
    final isKyrgyz = currentLocale.languageCode == 'ky';

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final newLocale = isKyrgyz ? const Locale('ru') : const Locale('ky');
          await context.setLocale(newLocale);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('locale', newLocale.languageCode);
          // Уведомляем CategoryProvider о смене языка
          Provider.of<CategoryProvider>(context, listen: false)
              .notifyLanguageChanged();
          if (mounted) setState(() {});

          // Log current app version using package_info_plus
          try {
            final info = await PackageInfo.fromPlatform();
            debugPrint('[App Version] version: ${info.version}, build: ${info.buildNumber}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Версия приложения: ${info.version} (build ${info.buildNumber})'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            debugPrint('[App Version] failed to read version: $e');
          }
        },
        child: Container(
          width: 90,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFE3F2FD).withOpacity(0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white : theme.colorScheme.primary,
              width: 1.2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 6,
                top: 8,
                child: Opacity(
                  opacity: isKyrgyz ? 0.6 : 1.0,
                  child: Image.asset(
                    'assets/images/kg_flag.png',
                    width: 20,
                    height: 20,
                    cacheWidth: 40,
                    cacheHeight: 40,
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 8,
                child: Opacity(
                  opacity: isKyrgyz ? 1.0 : 0.6,
                  child: Image.asset(
                    'assets/images/ru_flag.png',
                    width: 20,
                    height: 20,
                    cacheWidth: 40,
                    cacheHeight: 40,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: isKyrgyz ? 4 : 50,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white : theme.colorScheme.primary,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Share.share(
              'https://play.google.com/store/apps/details?id=com.aimak996.aimak');
        },
        child: Container(
          width: 90,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFE3F2FD).withOpacity(0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white : theme.colorScheme.primary,
              width: 1.2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.share,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF2563EB),
            ),
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

class _LanguageToggleSwitchState extends State<LanguageToggleSwitch>
    with TickerProviderStateMixin {
  final bool _pressed = false;
  late AnimationController _iconController;
  late AnimationController _swapController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKyrgyz = context.locale.languageCode == 'ky';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final bgColor = _pressed
        ? theme.colorScheme.primary.withOpacity(0.15)
        : theme.colorScheme.surface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final newLocale = isKyrgyz ? const Locale('ru') : const Locale('ky');
          await context.setLocale(newLocale);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('locale', newLocale.languageCode);
          // Уведомляем CategoryProvider о смене языка
          Provider.of<CategoryProvider>(context, listen: false)
              .notifyLanguageChanged();
          if (mounted) setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white : theme.dividerColor,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: ClipOval(
                  key: ValueKey(isKyrgyz ? 'ru' : 'kg'),
                  child: Image.asset(
                    isKyrgyz
                        ? 'assets/images/ru_flag.png'
                        : 'assets/images/kg_flag.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              RotationTransition(
                turns: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                  parent: _iconController,
                  curve: Curves.easeOutCubic,
                )),
                child: const Icon(Icons.sync_alt,
                    size: 18, color: Colors.blueAccent),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: ClipOval(
                  key: ValueKey(isKyrgyz ? 'kg' : 'ru'),
                  child: Image.asset(
                    isKyrgyz
                        ? 'assets/images/kg_flag.png'
                        : 'assets/images/ru_flag.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
