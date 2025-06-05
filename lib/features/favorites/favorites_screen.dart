import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:projects/core/providers/favorites_provider.dart';
import 'package:projects/core/providers/theme_provider.dart';
import 'package:projects/core/widgets/app_drawer.dart';
import 'package:projects/data/services/ad_service.dart';
import 'package:projects/features/home/ad_card.dart';
import 'package:projects/data/models/ad_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favoriteIds = favoritesProvider.favorites;
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
          if (favoriteIds.isNotEmpty)
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
      body: favoriteIds.isEmpty
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
          : FutureBuilder<List<AdModel>>(
              future: AdService().fetchFavoriteAds(favoriteIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${"error_occurred".tr()}: ${snapshot.error}',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            (context as Element).markNeedsBuild();
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text('reload_again'.tr()),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: theme.colorScheme.onPrimary,
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final favoriteAds = snapshot.data ?? [];

                if (favoriteAds.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteAds.length,
                  itemBuilder: (_, i) {
                    final ad = favoriteAds[i];
                    return Dismissible(
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
                        favoritesProvider.toggleFavorite(ad.id.toString());

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('removed_from_favorites'.tr()),
                            action: SnackBarAction(
                              label: 'undo'.tr(),
                              onPressed: () {
                                favoritesProvider
                                    .toggleFavorite(ad.id.toString());
                              },
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: AdCard(ad: ad),
                    );
                  },
                );
              },
            ),
    );
  }
}
