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
                    content: const Text('Вы уверены, что хотите удалить все избранные объявления?'),
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
              child: Text(
                'Ката чыкты: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final allAds = snapshot.data ?? [];
          final favoriteAds = allAds
              .where((ad) => favoriteIds.contains(ad.id.toString()))
              .toList();

          if (favoriteAds.isEmpty) {
            return const Center(child: Text('Пока нет избранных'));
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
                  color: Colors.red.shade400,
                  child: const Icon(Icons.delete, color: Colors.white),
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
