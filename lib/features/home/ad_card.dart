import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:projects/data/models/ad_model.dart';
import 'package:projects/core/providers/favorites_provider.dart';

class AdCard extends StatelessWidget {
  final AdModel ad;

  const AdCard({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(ad.id.toString());

    final dateTime = DateTime.tryParse(ad.createdAt) ?? DateTime.now();
    final timeStr = DateFormat('HH:mm').format(dateTime);
    final dateStr = DateFormat('dd.MM.yyyy').format(dateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Фото + лайк
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: ad.images.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: ad.images.first,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                )
                    : Container(color: Colors.grey.shade300),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: InkWell(
                  onTap: () => favoritesProvider.toggleFavorite(ad.id.toString()),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// Текстовая часть
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  ad.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),

                /// Время, дата, звонок
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('$timeStr | $dateStr',
                            style: theme.textTheme.labelSmall),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        final uri = Uri.parse('tel:${ad.phone}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const Icon(Icons.phone, color: Colors.green),
                    ),
                    IconButton(
                      onPressed: () async {
                        final uri = Uri.parse('https://wa.me/${ad.phone}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
