// lib/features/info/about_screen.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    final bgColor =
        theme.brightness == Brightness.dark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('about_title'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'home_title'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'about_description'.tr(),
              style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              'about_goals'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'about_goals_list'.tr(),
              style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Text(
                'about_copyright'.tr(),
                style:
                    TextStyle(fontSize: 14, color: textColor.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
