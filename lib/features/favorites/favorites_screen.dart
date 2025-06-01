import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projects/core/providers/favorites_provider.dart';
import 'package:projects/data/services/ad_service.dart';
import 'package:projects/features/home/ad_card.dart';
import 'package:projects/data/models/ad_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final favoriteIds = favoritesProvider.favorites;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Жаккандар'),
        actions: [
          if (favoriteIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Очистить всё',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Очистить избранное?'),
                    content: const Text(
                        'Вы уверены, что хотите удалить все избранные объявления?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          favoritesProvider.clearAll();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Удалить'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: FutureBuilder<List<AdModel>>(
        future: AdService().fetchAds(),
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
                    'Ката чыкты: ${snapshot.error}',
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
                    label: const Text('Кайра жүктөө'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimary,
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }

          final allAds = snapshot.data ?? [];
          final favoriteAds = allAds
              .where((ad) => favoriteIds.contains(ad.id.toString()))
              .toList();

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
                    'Пока нет избранных',
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
                      content: const Text('Убрано из избранного'),
                      action: SnackBarAction(
                        label: 'Отменить',
                        onPressed: () {
                          favoritesProvider.toggleFavorite(ad.id.toString());
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
