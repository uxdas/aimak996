import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projects/screens/full_image_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/core/providers/favorites_provider.dart';
import 'package:projects/core/providers/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import 'package:projects/features/home/ad_buttons_row.dart';
import 'dart:math';

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
  late AnimationController _imageBounceController;
  late Animation<double> _imageBounceAnimation;
  final List<Widget> _floatingHearts = [];

  @override
  void initState() {
    super.initState();

    // Heart animation controller
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.5)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_heartAnimationController);

    // Image bounce animation controller
    _imageBounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _imageBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageBounceController,
      curve: Curves.elasticOut,
    ));
  }

  void _onLike(FavoritesProvider favoritesProvider, AdModel ad) async {
    _heartAnimationController.forward(from: 0.0);
    final colors = [
      Colors.red,
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.deepPurple,
      Colors.pink,
      Colors.redAccent
    ];
    final random =
        Random(DateTime.now().millisecondsSinceEpoch + _floatingHearts.length);
    for (int i = 0; i < 12; i++) {
      // Угол от 70° до 110° (в радианах)
      final angle =
          (pi / 2) + (random.nextDouble() - 0.5) * (pi / 9); // pi/2 ± pi/18
      final distance = 80 + random.nextDouble() * 40;
      final dx = cos(angle) * distance;
      final dy = -sin(angle) * distance;
      final color = colors[random.nextInt(colors.length)];
      final size = 18.0 + random.nextDouble() * 14;
      final opacity = 0.7 + random.nextDouble() * 0.3;
      final rotation = (random.nextDouble() - 0.5) * 0.8;
      Future.delayed(Duration(milliseconds: i * 30), () {
        _addFloatingHeart(
          dx: dx,
          dy: dy,
          opacity: opacity,
          color: color,
          rotation: rotation,
          size: size,
        );
      });
    }
    await favoritesProvider.toggleFavorite(ad);
  }

  void _addFloatingHeart({
    double dx = 0,
    double dy = -80,
    double opacity = 1,
    required Color color,
    double rotation = 0,
    double size = 24,
  }) {
    final key = UniqueKey();
    setState(() {
      _floatingHearts.add(_FloatingHeart(
        key: key,
        dx: dx,
        dy: dy,
        opacity: opacity,
        color: color,
        rotation: rotation,
        size: size,
        onEnd: () {
          setState(() {
            _floatingHearts.removeWhere((w) => w.key == key);
          });
        },
      ));
    });
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _imageBounceController.dispose();
    super.dispose();
  }

  Widget _buildBounceWidget(Widget child) {
    return AnimatedBuilder(
      animation: _imageBounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_imageBounceAnimation.value * 10, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildFavoriteButton(
      bool isFavorite, FavoritesProvider favoritesProvider, AdModel ad) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ..._floatingHearts,
        AnimatedBuilder(
          animation: _heartScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _heartScaleAnimation.value,
              child: FloatingActionButton(
                heroTag: "fav_btn",
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () => _onLike(favoritesProvider, ad),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: isFavorite ? Colors.red : Colors.grey[600],
                  size: 24,
                ),
              ),
            );
          },
        ),
      ],
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
    final categoryName = ad.category;
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
                                            Icon(
                                              Icons.error_outline,
                                              size: 48,
                                              color: theme.colorScheme.error
                                                  .withOpacity(0.8),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'error_loading_image'.tr(),
                                              style: theme.textTheme.bodyMedium,
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
                        if (ad.images.length > 1)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                ad.images.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentSlide == index
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
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
}

class _FloatingHeart extends StatefulWidget {
  final VoidCallback onEnd;
  final double dx;
  final double dy;
  final double opacity;
  final Color color;
  final double rotation;
  final double size;
  const _FloatingHeart({
    super.key,
    required this.onEnd,
    this.dx = 0,
    this.dy = -80,
    this.opacity = 1,
    required this.color,
    this.rotation = 0,
    this.size = 24,
  });

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _move;
  late Animation<double> _fadeOut;
  late Animation<double> _scale;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _move = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fadeOut = Tween<double>(begin: widget.opacity, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _rotation =
        Tween<double>(begin: 0, end: widget.rotation).animate(_controller);
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onEnd();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Positioned(
        bottom: 0,
        left: widget.dx * _move.value,
        child: Opacity(
          opacity: _fadeOut.value,
          child: Transform.translate(
            offset: Offset(0, widget.dy * _move.value),
            child: Transform.rotate(
              angle: _rotation.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Icon(Icons.favorite,
                    color: widget.color, size: widget.size),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
