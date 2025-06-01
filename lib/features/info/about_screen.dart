// lib/features/info/about_screen.dart

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    final bgColor = theme.brightness == Brightness.dark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Биз жөнүндө'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ноокат 996',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Бул колдонмо Ноокат районундагы жарандар үчүн түзүлгөн. Максаты — сатып алуу, сатуу жана кызмат көрсөтүүлөрдү тез жана оңой табуу. Бул колдонмо аркылуу сиз жарыя берип, аймактагы башка адамдар менен байланышып, керектүү маалыматтарды тез таба аласыз.',
              style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Биздин максат:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Аймак ичиндеги байланыштарды бекемдөө\n'
                  '• Жергиликтүү экономиканы колдоо\n'
                  '• Жарнама берүү процессин жөнөкөйлөтүү\n'
                  '• Колдонуучуларга ыңгайлуу интерфейс сунуштоо',
              style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Text(
                '© 2025 Ноокат 996. Бардык укуктар корголгон.',
                style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
