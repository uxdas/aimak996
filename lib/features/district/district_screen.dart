import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class DistrictScreen extends StatelessWidget {
  const DistrictScreen({super.key});

  Future<void> _launchMap() async {
    final uri = Uri.parse('https://goo.gl/maps/YQPJqFxmqcgNXn6B7');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDarkMode ? Colors.white70 : theme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colorScheme.surface : Colors.white,
      appBar: AppBar(
        title: Text('${'about'.tr()} 🏞️'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Историческая справка
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📜', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Text(
                        'district_history_title'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'district_history'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Общая информация
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              decoration: BoxDecoration(
                color: isDarkMode ? theme.colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  if (!isDarkMode)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_city, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        '${'district_center'.tr()}: ',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'district_center_value'.tr(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.people_outline, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      Text('${'district_population'.tr()}: ',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text('district_population_value'.tr(),
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.landscape, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      Text('${'district_area'.tr()}: ',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text('district_area_value'.tr(),
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.height, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: '${'district_elevation'.tr()}: ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: 'district_elevation_value'.tr(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Интересные факты
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌄', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Text(
                        'district_facts_title'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'district_facts'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
