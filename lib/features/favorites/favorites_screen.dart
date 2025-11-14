import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nookat996/core/providers/favorites_provider.dart';
import 'package:nookat996/core/providers/theme_provider.dart';
import 'package:nookat996/core/widgets/app_drawer.dart';
import 'package:nookat996/features/home/ad_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favoriteAds = favoritesProvider.favoritesList;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: AppDrawer(
        isDark: themeProvider.isDark,
        toggleTheme: themeProvider.toggleTheme,
      ),
      appBar: AppBar(
        title: Text('favorites_title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (favoriteAds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'clear_all'.tr(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('clear_favorites'.tr()),
                    content: Text('clear_favorites_confirm'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('cancel'.tr()),
                      ),
                      TextButton(
                        onPressed: () {
                          favoritesProvider.clearAll();
                          Navigator.pop(ctx);
                        },
                        child: Text('delete'.tr()),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: favoriteAds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: isDark ? Colors.white54 : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_favorites'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(5),
              itemCount: favoriteAds.length,
              itemBuilder: (_, i) {
                final ad = favoriteAds[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey(ad.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      color: theme.colorScheme.error,
                      child: Icon(
                        Icons.delete,
                        color: theme.colorScheme.onError,
                      ),
                    ),
                    onDismissed: (_) {
                      favoritesProvider.toggleFavorite(ad);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('removed_from_favorites'.tr()),
                          action: SnackBarAction(
                            label: 'undo'.tr(),
                            onPressed: () {
                              favoritesProvider.toggleFavorite(ad);
                            },
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    child: AdCard(ad: ad),
                  ),
                );
              },
            ),
    );
  }
}
