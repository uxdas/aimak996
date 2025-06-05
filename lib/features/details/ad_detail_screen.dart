import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/data/services/ad_service.dart';
import 'package:projects/features/home/ad_buttons_row.dart';
import 'package:projects/core/providers/favorites_provider.dart';
import 'package:projects/screens/full_image_screen.dart';

class AdDetailScreen extends StatefulWidget {
  final AdModel ad;

  const AdDetailScreen({super.key, required this.ad});

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen>
    with TickerProviderStateMixin {
  int _currentSlide = 0;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late AnimationController _errorShakeController;
  late Animation<double> _errorShakeAnimation;
  late AnimationController _imageBounceController;
  late Animation<double> _imageBounceAnimation;

  @override
  void initState() {
    super.initState();

    // Heart animation controller
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

    // Error shake animation controller
    _errorShakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _errorShakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _errorShakeController,
        curve: Curves.elasticOut,
      ),
    );

    // Image bounce animation controller
    _imageBounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _imageBounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _imageBounceController,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _errorShakeController.dispose();
    _imageBounceController.dispose();
    super.dispose();
  }

  Widget _buildShakeWidget(Widget child) {
    return AnimatedBuilder(
      animation: _errorShakeAnimation,
      builder: (context, child) {
        final shakeValue = _errorShakeAnimation.value;
        final dx =
            (shakeValue * 10) * (1 - shakeValue) * (shakeValue < 0.5 ? 1 : -1);
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildBounceWidget(Widget child) {
    return AnimatedBuilder(
      animation: _imageBounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.7 + (_imageBounceAnimation.value * 0.3),
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildFavoriteButton(
      bool isFavorite, FavoritesProvider favoritesProvider, AdModel ad) {
    return AnimatedBuilder(
      animation: _heartScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _heartScaleAnimation.value,
          child: FloatingActionButton(
            heroTag: "fav_btn",
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () async {
              _heartAnimationController.forward().then((_) {
                _heartAnimationController.reverse();
              });
              await favoritesProvider.toggleFavorite(ad.id.toString());
            },
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: isFavorite ? Colors.red : Colors.grey[600],
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareButton(AdModel ad) {
    return FloatingActionButton(
      heroTag: "share_btn",
      mini: true,
      backgroundColor: Colors.white,
      onPressed: () {
        final shareText = '''
${ad.title}

${ad.description}

Телефон: ${ad.phone}

Скачай приложение Аймак 996: https://aimak996.kg
        ''';
        Share.share(shareText.trim());
      },
      child: Icon(
        Icons.share,
        color: Colors.grey[600],
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();
    final ad = widget.ad;
    final dateTime = DateTime.tryParse(ad.createdAt) ?? DateTime.now();
    final timeStr = DateFormat('HH:mm').format(dateTime);
    final dateStr = DateFormat('dd.MM.yyyy').format(dateTime);
    final categoryName = _getCategoryName(ad.categoryId);
    final isFavorite = favoritesProvider.isFavorite(ad.id.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('full_info'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images carousel
                if (ad.images.isNotEmpty) ...[
                  Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: ad.images.length,
                          options: CarouselOptions(
                            height: 300,
                            viewportFraction: 1.0,
                            enableInfiniteScroll: ad.images.length > 1,
                            onPageChanged: (index, _) {
                              setState(() => _currentSlide = index);
                            },
                          ),
                          itemBuilder: (context, index, _) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullImageScreen(
                                      imageUrl: ad.images[index],
                                      tag: 'detail-image-${ad.id}-$index',
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'detail-image-${ad.id}-$index',
                                child: CachedNetworkImage(
                                  imageUrl: ad.images[index],
                                  width: double.infinity,
                                  height: 300,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: theme.colorScheme.surfaceVariant,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    // Start bounce animation when image error occurs
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _imageBounceController
                                          .forward()
                                          .then((_) {
                                        _imageBounceController.reset();
                                      });
                                    });

                                    return _buildBounceWidget(
                                      Container(
                                        color: theme.colorScheme.surfaceVariant,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TweenAnimationBuilder<double>(
                                              duration: const Duration(
                                                  milliseconds: 800),
                                              tween:
                                                  Tween(begin: 0.0, end: 1.0),
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 48,
                                                    color: Colors.grey[400],
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Фото жүктөлгөн жок',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        if (ad.images.length > 1) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: ad.images.asMap().entries.map((entry) {
                              final isActive = entry.key == _currentSlide;
                              return Container(
                                width: isActive ? 12 : 8,
                                height: isActive ? 12 : 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? theme.primaryColor
                                      : Colors.grey.shade300,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Content card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          ad.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          ad.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Meta info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.category,
                                      size: 20, color: theme.primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    categoryName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 20, color: theme.primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$dateStr в $timeStr',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Contact buttons
                        AdButtonsRow(phone: ad.phone),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Space for floating buttons
              ],
            ),
          ),

          // Floating action buttons
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFavoriteButton(isFavorite, favoritesProvider, ad),
                const SizedBox(height: 12),
                _buildShareButton(ad),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'category_real_estate'.tr();
      case 2:
        return 'category_auto'.tr();
      case 3:
        return 'category_animals'.tr();
      case 4:
        return 'category_home'.tr();
      case 5:
        return 'category_services'.tr();
      case 7:
        return 'category_transport'.tr();
      case 9:
        return 'Жаңылыктар';
      default:
        return 'unknown_category'.tr();
    }
  }
}
