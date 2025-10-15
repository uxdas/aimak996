import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:nookat996/core/providers/category_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isKyrgyz = context.locale.languageCode == 'ky';

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('language'.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLanguageButton(
              context,
              'Русский',
              isKyrgyz ? true : false,
              () async {
                final newLocale = const Locale('ru');
                await context.setLocale(newLocale);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('locale', newLocale.languageCode);
                Provider.of<CategoryProvider>(context, listen: false)
                    .notifyLanguageChanged();
              },
            ),
            const SizedBox(height: 16),
            _buildLanguageButton(
              context,
              'Кыргызча',
              isKyrgyz ? false : true,
              () async {
                final newLocale = const Locale('ky');
                await context.setLocale(newLocale);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('locale', newLocale.languageCode);
                Provider.of<CategoryProvider>(context, listen: false)
                    .notifyLanguageChanged();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor
                : isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDarkMode
                        ? Colors.white
                        : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
