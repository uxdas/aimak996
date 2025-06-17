import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nookat996/screens/full_image_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nookat996/data/models/ad_model.dart';
import 'package:nookat996/core/providers/favorites_provider.dart';
import 'package:nookat996/core/providers/theme_provider.dart';
import 'package:nookat996/core/providers/category_provider.dart';
import 'package:nookat996/core/providers/contact_info_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nookat996/features/home/ad_buttons_row.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:nookat996/utils/sound_helper.dart';
import 'package:nookat996/core/models/category.dart';
import 'package:nookat996/core/widgets/category_chip.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

class AdDetailScreen extends StatefulWidget {
  final AdModel ad;

  const AdDetailScreen({
    super.key,
    required this.ad,
  });

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentImageIndex = 0;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late AnimationController _imageBounceController;
  late Animation<double> _imageBounceAnimation;
  final List<Widget> _floatingHearts = [];
  late AnimationController _fireController;
  late Animation<double> _fireScale;
  late Animation<double> _fireFade;
  bool _showFire = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

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

    _fireController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fireScale = Tween<double>(begin: 0.7, end: 2.2).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.elasticOut),
    );
    _fireFade = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeOut),
    );
  }

  void _onLike(FavoritesProvider favoritesProvider, AdModel ad) async {
    await SoundHelper.playIfEnabled('sounds/like.wav');
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

  void _onFavoritePressed(bool isFavorite, AdModel ad) async {
    if (!isFavorite) {
      setState(() => _showFire = true);
      _fireController.forward(from: 0.0).then((_) {
        setState(() => _showFire = false);
      });
    }
    context.read<FavoritesProvider>().toggleFavorite(ad);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartAnimationController.dispose();
    _imageBounceController.dispose();
    _fireController.dispose();
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

  void _shareToWhatsApp(String text) async {
    final url = 'https://wa.me/?text=${Uri.encodeComponent(text)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareToTelegram(String text) async {
    final url = 'https://t.me/share/url?url=${Uri.encodeComponent(text)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareToInstagram() async {
    const url = 'instagram://app';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareOther(BuildContext context, String text) {
    Share.share(text);
  }

  void showShareDialog(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
              title: const Text('WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                _shareToWhatsApp(text);
              },
            ),
            ListTile(
              leading:
                  const FaIcon(FontAwesomeIcons.telegram, color: Colors.blue),
              title: const Text('Telegram'),
              onTap: () {
                Navigator.pop(context);
                _shareToTelegram(text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: const Text('Instagram'),
              onTap: () {
                Navigator.pop(context);
                _shareToInstagram();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Другие приложения'),
              onTap: () {
                Navigator.pop(context);
                _shareOther(context, text);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ad = widget.ad;
    final dateTime = DateTime.tryParse(ad.createdAt) ?? DateTime.now();
    final dateStr = DateFormat('dd.MM.yyyy').format(dateTime);
    final isFavorite = context.watch<FavoritesProvider>().isFavorite(ad.id);
    final blue = Colors.blue;
    final blueAccent = Colors.blueAccent;
    final deepBlue = const Color(0xFF1565C0);
    final grey = Colors.grey[400]!;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
        ),
        toolbarHeight: 56,
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Галерея
                      Stack(
                        children: [
                          SizedBox(
                            height: 270,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: ad.images.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FullImageScreen(
                                          images: ad.images,
                                          initialIndex: index,
                                          tag: 'ad-detail-image-${ad.id}-',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'ad-detail-image-${ad.id}-$index',
                                    child: CachedNetworkImage(
                                      imageUrl: ad.images[index],
                                      width: double.infinity,
                                      height: 270,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: theme.colorScheme.surfaceVariant,
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: theme.colorScheme.surfaceVariant,
                                        child: const Icon(Icons.broken_image,
                                            size: 48),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (ad.images.length > 1)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    ad.images.asMap().entries.map((entry) {
                                  return Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(
                                        _currentImageIndex == entry.key
                                            ? 0.9
                                            : 0.4,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                      // Описание
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.description,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E3A8A)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: const Color(0xFF1E3A8A),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat('dd.MM.yyyy').format(
                                                DateTime.parse(ad.createdAt)),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1E3A8A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              height: 48,
                              margin: const EdgeInsets.only(top: 24, bottom: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: blue, width: 1.5),
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.grey[200],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          bottomLeft: Radius.circular(24),
                                        ),
                                        onTap: () async {
                                          print(
                                              '[AdDetail] Phone number: ${ad.phone}');
                                          final phone =
                                              ad.phone.replaceAll(' ', '');
                                          if (phone.isNotEmpty) {
                                            final uri = Uri.parse('tel:$phone');
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(uri,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            }
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.phone,
                                                color: blue, size: 22),
                                            const SizedBox(width: 8),
                                            Text(
                                              ad.phone.isNotEmpty
                                                  ? ad.phone
                                                  : 'Нет номера',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                      color: blue,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 32,
                                    color: blue.withOpacity(0.18),
                                  ),
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(24),
                                          bottomRight: Radius.circular(24),
                                        ),
                                        onTap: () async {
                                          final phone =
                                              ad.phone.replaceAll(' ', '');
                                          final uri =
                                              Uri.parse('https://wa.me/$phone');
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Не удалось открыть WhatsApp'),
                                              ),
                                            );
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FaIcon(FontAwesomeIcons.whatsapp,
                                                color: const Color(0xFF25D366),
                                                size: 22),
                                            const SizedBox(width: 8),
                                            Text(
                                              'WhatsApp',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                color: const Color(0xFF25D366),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, _) {
                    final isFavorite = favoritesProvider.isFavorite(ad.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onLike(favoritesProvider, ad),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.local_fire_department_rounded
                                        : Icons.local_fire_department_outlined,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                    size: 32,
                                    key: ValueKey<bool>(isFavorite),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                    onPressed: () {
                      final shareText = '''
${ad.title}

${ad.description}

Телефон: ${ad.phone}

Скачай приложение Аймак 996: https://aimak996.kg
                      ''';
                      showShareDialog(context, shareText.trim());
                    },
                    splashRadius: 24,
                  ),
                ),
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
