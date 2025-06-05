import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:projects/screens/full_image_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/core/providers/favorites_provider.dart';
import 'package:projects/widgets/telegram_refresh_indicator.dart';
import 'package:projects/features/details/ad_detail_screen.dart';
import 'package:share_plus/share_plus.dart';

class AdCard extends StatefulWidget {
  final AdModel ad;
  final Future<void> Function()? onRefresh;

  const AdCard({
    super.key,
    required this.ad,
    this.onRefresh,
  });

  @override
  State<AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> with TickerProviderStateMixin {
  bool _isExpanded = false;
  int _currentImageIndex = 0;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  Widget _buildFavoriteButton(BuildContext context, bool isFavorite,
      FavoritesProvider favoritesProvider) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _heartScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _heartScaleAnimation.value,
          child: Material(
            type: MaterialType.circle,
            elevation: 2,
            color: theme.colorScheme.surface.withOpacity(0.9),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: favoritesProvider.isLoading
                  ? null
                  : () async {
                      try {
                        _heartAnimationController.forward().then((_) {
                          _heartAnimationController.reverse();
                        });
                        await favoritesProvider
                            .toggleFavorite(widget.ad.id.toString());
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
                    color:
                        isFavorite ? Colors.red : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSlider(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.ad.images.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: widget.ad.images.length,
          options: CarouselOptions(
            height: 200,
            viewportFraction: 1.0,
            enableInfiniteScroll: widget.ad.images.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final imageUrl = widget.ad.images[index];
            final tag = 'ad-image-${widget.ad.id}-$index';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImageScreen(
                      imageUrl: imageUrl,
                      tag: tag,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: tag,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
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
                ),
              ),
            );
          },
        ),
        if (widget.ad.images.length > 1) ...[
          // Navigation arrows
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withOpacity(0),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.white,
                    onPressed: () {
                      if (_currentImageIndex > 0) {
                        setState(() {
                          _currentImageIndex--;
                        });
                      }
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    color: Colors.white,
                    onPressed: () {
                      if (_currentImageIndex < widget.ad.images.length - 1) {
                        setState(() {
                          _currentImageIndex++;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bullets indicator
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.ad.images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      _currentImageIndex == entry.key ? 0.9 : 0.4,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(widget.ad.id.toString());

    final dateTime = DateTime.tryParse(widget.ad.createdAt) ?? DateTime.now();
    final timeStr = DateFormat('HH:mm').format(dateTime);
    final dateStr = DateFormat('dd.MM.yyyy').format(dateTime);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Widget cardContent = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildImageSlider(context),
              if (widget.ad.images.isNotEmpty) ...[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _buildFavoriteButton(
                      context, isFavorite, favoritesProvider),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.ad.title.isNotEmpty) ...[
                  Text(
                    widget.ad.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.ad.description,
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.69),
                        height: 1.4,
                      ),
                    ),
                    if (_needsExpansion(context)) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        child: Text(
                          _isExpanded ? 'Свернуть' : 'Ещё',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Share button
                    IconButton(
                      onPressed: () {
                        final shareText = '''
${widget.ad.title}

${widget.ad.description}

Телефон: ${widget.ad.phone}

Скачай приложение Аймак 996: https://aimak996.kg
                        ''';
                        Share.share(shareText.trim());
                      },
                      icon: const Icon(Icons.share),
                      tooltip: 'Поделиться',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () async {
                        final phone = widget.ad.phone.replaceAll(' ', '');
                        final uri = Uri.parse('tel:$phone');

                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Не удалось открыть приложение телефона')),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        elevation: isDark ? 0 : 12,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(12),
                        minimumSize: const Size(44, 44),
                        fixedSize: const Size.fromHeight(44),
                        side: isDark
                            ? BorderSide(
                                color: theme.colorScheme.outline,
                                width: 1,
                              )
                            : BorderSide.none,
                      ),
                      icon: const Icon(Icons.phone, size: 20),
                      label: Text(
                        widget.ad.phone,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF008B85),
                        shape: BoxShape.circle,
                        boxShadow: isDark
                            ? [] // Без тени в тёмной теме
                            : const [
                                BoxShadow(
                                  color: Color.fromARGB(155, 0, 139, 132),
                                  blurRadius: 4,
                                  offset: Offset(0, 3),
                                  spreadRadius: 1,
                                ),
                              ],
                      ),
                      child: IconButton(
                        onPressed: () async {
                          final uri =
                              Uri.parse('https://wa.me/${widget.ad.phone}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                        ),
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

    if (widget.onRefresh != null) {
      return TelegramRefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: cardContent,
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdDetailScreen(ad: widget.ad),
          ),
        );
      },
      child: cardContent,
    );
  }

  bool _needsExpansion(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.ad.description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.4,
            ),
      ),
      maxLines: 3,
      textDirection: Directionality.of(context),
    )..layout(
        maxWidth: MediaQuery.of(context).size.width - 32); // 32 = padding * 2

    return textPainter.didExceedMaxLines;
  }
}
