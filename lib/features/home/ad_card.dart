import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/ad_model.dart';
import '../../core/providers/favorites_provider.dart';
import '../../screens/full_image_screen.dart';
import '../details/ad_detail_screen.dart';
import '../../widgets/telegram_refresh_indicator.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import '../../utils/sound_helper.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import '../../core/providers/category_provider.dart';

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
  late AnimationController _fireAnimationController;
  Animation<double> _heartScaleAnimation = const AlwaysStoppedAnimation(1.0);
  Animation<double> _fireScale = const AlwaysStoppedAnimation(1.0);
  Animation<double> _fireFade = const AlwaysStoppedAnimation(1.0);
  bool _showFire = false;
  final List<Widget> _floatingHearts = [];

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fireAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.5)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_heartAnimationController);

    _fireScale = Tween<double>(begin: 0.7, end: 2.2).animate(
      CurvedAnimation(
          parent: _fireAnimationController, curve: Curves.elasticOut),
    );
    _fireFade = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _fireAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _fireAnimationController.dispose();
    super.dispose();
  }

  void _onLike(FavoritesProvider favoritesProvider) async {
    await SoundHelper.playIfEnabled('sounds/like.wav');
    setState(() => _showFire = true);
    _fireAnimationController.forward(from: 0.0).then((_) {
      setState(() => _showFire = false);
    });
    await favoritesProvider.toggleFavorite(widget.ad);
  }

  Widget _buildFavoriteButton(BuildContext context, bool isFavorite,
      FavoritesProvider favoritesProvider) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _heartScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _heartScaleAnimation.value,
              child: Material(
                type: MaterialType.circle,
                elevation: 2,
                color: Colors.white.withOpacity(0.2),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: favoritesProvider.isLoading
                      ? null
                      : () => _onLike(favoritesProvider),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isFavorite
                                ? Icon(
                                    Icons.local_fire_department_rounded,
                                    color: Colors.red,
                                    size: 32,
                                  )
                                : Icon(
                                    Icons.local_fire_department_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (_showFire)
          Positioned(
            left: -20,
            top: -20,
            right: -20,
            bottom: -20,
            child: Center(
              child: ScaleTransition(
                scale: _fireScale,
                child: FadeTransition(
                  opacity: _fireFade,
                  child: Icon(
                    Icons.local_fire_department,
                    color: Colors.deepOrange.withOpacity(0.85),
                    size: 60,
                    shadows: [
                      Shadow(
                        color: Colors.orange.withOpacity(0.7),
                        blurRadius: 16,
                        offset: const Offset(0, 0),
                      ),
                      Shadow(
                        color: Colors.yellow.withOpacity(0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
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
                      images: widget.ad.images,
                      initialIndex: index,
                      tag: 'ad-image-${widget.ad.id}-',
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, _) {
                final isFavorite = favoritesProvider.isFavorite(widget.ad.id);
                return AnimatedBuilder(
                  animation: _heartScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _heartScaleAnimation.value,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _onLike(favoritesProvider),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.blue),
          onPressed: () {
            Share.share('${widget.ad.category}\n${widget.ad.description}');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(widget.ad.id);

    final dateTime = DateTime.tryParse(widget.ad.createdAt) ?? DateTime.now();
    final timeStr = DateFormat('HH:mm').format(dateTime);
    final dateStr = DateFormat('dd.MM.yyyy').format(dateTime);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Widget cardContent = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
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
                if (widget.ad.categoryId != 0) ...[
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, _) {
                      final category = categoryProvider
                          .getCategoryById(widget.ad.categoryId);
                      final categoryName = category?.getLocalizedName(
                              Localizations.localeOf(context)) ??
                          '';
                      return Text(
                        categoryName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      );
                    },
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
                          _isExpanded ? 'collapse'.tr() : 'load_more'.tr(),
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
                if (widget.ad.images.isEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.blue),
                        onPressed: () {
                          Share.share(
                              '${widget.ad.category}\n${widget.ad.description}');
                        },
                      ),
                    ],
                  ),
                ],
                Row(
                  children: [
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
                        await _playTapSound();
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
                        widget.ad.phone.replaceAll(' ', ''),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF008B85),
                        shape: BoxShape.circle,
                        boxShadow: isDark
                            ? []
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
                          await _playTapSound();
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
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 0),
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
      onTap: () async {
        await SoundHelper.playIfEnabled('sounds/open_full_ad.mp3');
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

  Future<void> _playTapSound() async {
    await SoundHelper.playIfEnabled('sounds/call_tap.wav');
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
