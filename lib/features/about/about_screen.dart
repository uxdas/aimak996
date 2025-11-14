import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:nookat996/core/providers/contact_info_provider.dart';
import 'package:nookat996/features/about/feedback_screen.dart';
import 'dart:async';
import 'package:nookat996/features/about/city_boards_screen.dart';
import 'package:nookat996/constants/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Future<void> _launchWhatsApp(BuildContext context) async {
    try {
      final contactProvider = context.read<ContactInfoProvider>();
      final rawPhone = contactProvider.adminPhone; // take admin_phone
      final message = 'feedback_whatsapp_message'.tr();

      // Normalize: keep digits and '+', drop '+', convert leading 0 -> 996
      final cleaned = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
      String phone = cleaned;
      if (phone.startsWith('+')) phone = phone.substring(1);
      if (phone.startsWith('0')) phone = '996${phone.substring(1)}';

      // Try scheme first with optional text
      final schemeUri = Uri.parse(
          'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(schemeUri)) {
        final launched = await launchUrl(
          schemeUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('whatsapp_error'.tr())),
          );
        }
        return;
      }

      // Fallback to wa.me
      final webUri = Uri.parse(
          'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(webUri)) {
        final launched = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('whatsapp_error'.tr())),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('whatsapp_error'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('whatsapp_error'.tr())),
        );
      }
    }
  }

  Widget _buildSection({
    required String titleKey,
    required String contentKey,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleKey.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : theme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          contentKey.tr(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : Colors.white,
      appBar: AppBar(
        title: Text('about_company'.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? const Color(0xFF22336B)
                          : theme.primaryColor.computeLuminance() > 0.7
                              ? const Color(0xFF1565C0)
                              : theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    icon: const Icon(Icons.location_city, color: Colors.white),
                    label: Text(
                      'other_regions_button'.tr(),
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CityBoardsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 12),
                        child: Icon(Icons.info_outline,
                            color:
                                isDarkMode ? Colors.white : theme.primaryColor,
                            size: 28),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'about_us_title'.tr(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'about_us_content'.tr(),
                              style: TextStyle(
                                fontSize: 17,
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.85)
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(
                      thickness: 1.2,
                      color: isDarkMode ? Colors.white12 : Colors.black12),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 12),
                        child: Icon(Icons.phone_android,
                            color:
                                isDarkMode ? Colors.white : theme.primaryColor,
                            size: 28),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'about_app_title'.tr(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'about_app_text'.tr(),
                              style: TextStyle(
                                fontSize: 17,
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.85)
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(
                      thickness: 1.2,
                      color: isDarkMode ? Colors.white12 : Colors.black12),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 12),
                        child: Icon(Icons.message,
                            color:
                                isDarkMode ? Colors.white : theme.primaryColor,
                            size: 28),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'about_contact_title'.tr(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF25D366)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _launchWhatsApp(context),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'about_contact_button'.tr(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
