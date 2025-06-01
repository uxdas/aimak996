import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/core/providers/favorites_provider.dart';
import 'package:projects/widgets/telegram_refresh_indicator.dart';

class AdCard extends StatelessWidget {
  final AdModel ad;
  final Future<void> Function()? onRefresh;

  const AdCard({
    super.key,
    required this.ad,
    this.onRefresh,
  });

  Widget _buildFavoriteButton(BuildContext context, bool isFavorite,
      FavoritesProvider favoritesProvider) {
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.circle,
      elevation: 2,
      color: theme.colorScheme.surface.withOpacity(0.9),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: favoritesProvider.isLoading
            ? null
            : () async {
                try {
                  await favoritesProvider.toggleFavorite(ad.id.toString());
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ошибка при обновлении избранного'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline,
              size: 20,
              color: isFavorite ? Colors.red : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider(BuildContext context) {
    final theme = Theme.of(context);

    if (ad.images.isEmpty) {
      return Container(
        height: 200,
        color: theme.colorScheme.surfaceVariant,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            color: theme.colorScheme.onSurfaceVariant,
            size: 32,
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: ad.images.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: ad.images[index],
            width: MediaQuery.sizeOf(context).width,
            height: 200,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 300),
            placeholder: (context, url) => Container(
              color: theme.colorScheme.surfaceVariant,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: theme.colorScheme.surfaceVariant,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(ad.id.toString());

    final dateTime = DateTime.tryParse(ad.createdAt) ?? DateTime.now();
    final timeStr = DateFormat('HH:mm').format(dateTime);
    final dateStr = DateFormat('dd.MM.yyyy').format(dateTime);

    final Widget cardContent = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildImageSlider(context),
              Positioned(
                right: 12,
                top: 12,
                child: _buildFavoriteButton(
                    context, isFavorite, favoritesProvider),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ad.title.isNotEmpty) ...[
                  Text(
                    ad.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  ad.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '$timeStr\n$dateStr',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('tel:${ad.phone}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const Icon(Icons.phone, size: 18),
                      label: Text(ad.phone),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        final uri = Uri.parse('https://wa.me/${ad.phone}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF25D366).withOpacity(0.1),
                      ),
                      icon: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Color(0xFF25D366),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onRefresh != null) {
      return TelegramRefreshIndicator(
        onRefresh: onRefresh!,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
