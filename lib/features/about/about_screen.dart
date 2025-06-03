import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.store_rounded,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Classified Ads',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Версия 1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Мобильное приложение для просмотра и управления объявлениями. '
                    'Удобный интерфейс позволяет быстро находить интересующие '
                    'объявления, сохранять их в избранное и связываться с продавцами.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Возможности',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    Icons.photo_library_outlined,
                    'Просмотр объявлений с фотографиями',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.favorite_outline,
                    'Сохранение в избранное',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.phone_outlined,
                    'Быстрая связь с продавцом',
                  ),
                  _buildFeatureItem(
                    context,
                    FontAwesomeIcons.whatsapp,
                    'Интеграция с WhatsApp',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.dark_mode_outlined,
                    'Поддержка тёмной темы',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Разработка',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Приложение разработано с использованием Flutter - '
                    'современного фреймворка для создания кроссплатформенных '
                    'приложений от Google.',
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(
                        'https://github.com/YOUR_USERNAME/flutter_classified_ads',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const FaIcon(FontAwesomeIcons.github),
                    label: const Text('Исходный код на GitHub'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '© ${DateTime.now().year} Classified Ads',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
