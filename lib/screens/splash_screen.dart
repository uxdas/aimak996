import 'dart:async';
  import 'dart:math';
  import 'package:flutter/material.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter_svg/flutter_svg.dart';
  import 'package:nookat996/features/home/home_screen.dart';
  import 'package:audioplayers/audioplayers.dart';
  import '../utils/sound_helper.dart';

class SplashScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const SplashScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  bool _isNavigating = false;
  late final String _splashPath;
  bool _imageReady = false;
  // Animations for visual effects
  late final AnimationController _kenBurnsController;
  late final Animation<double> _kbScale;
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // Use a single optimized splash image (pre-declared in pubspec)
    _splashPath = 'assets/splashes/splash_1.JPG';

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Ken Burns: slow scale in/out
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
    _kbScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _kenBurnsController, curve: Curves.easeInOut),
    );

    // Pulse for ornament and text glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    // Precache the splash image at device pixel resolution, then start 1s fade animation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      final dpr = MediaQuery.of(context).devicePixelRatio;
      // Account for Ken Burns scale (up to ~1.08), use a small headroom 1.1
      final targetW = (size.width * dpr * 1.1).clamp(1, 8192).toInt();
      final targetH = (size.height * dpr * 1.1).clamp(1, 8192).toInt();
      final imageProvider = ResizeImage(
        AssetImage(_splashPath),
        width: targetW,
        height: targetH,
      );
      try {
        await precacheImage(imageProvider, context);
      } catch (_) {
        // ignore and proceed; errorBuilder will handle display fallback
      }
      if (!mounted) return;
      setState(() => _imageReady = true);
      // Show splash for exactly 1 second once image is ready
      _controller.forward().then((_) => _navigateToHome());
    });
  }

  Future<void> _navigateToHome() async {
    if (_isNavigating || !mounted) return;

    _isNavigating = true;

    try {

      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            isDark: widget.isDark,
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при запуске приложения: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      _isNavigating = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _kenBurnsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prepare styled title and measure its width to size the ornament SVG
    const String titleText = 'Ноокат 996';
    const TextStyle titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 44,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    );
    final textPainter = TextPainter(
      text: const TextSpan(text: titleText, style: titleStyle),
      textDirection: Directionality.of(context),
      textAlign: TextAlign.center,
    )
      ..layout(maxWidth: MediaQuery.of(context).size.width - 32);
    final double titleWidth = textPainter.width;

    return Scaffold(
      backgroundColor: widget.isDark ? Colors.black : Colors.white,
      body: FadeTransition(
        opacity: _opacity,
        child: Stack(
          children: [
            // Background splash image
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _kbScale,
                builder: (context, child) => Transform.scale(
                  scale: _kbScale.value,
                  child: child,
                ),
                child: Builder(
                  builder: (context) {
                    if (!_imageReady) {
                      return const ColoredBox(color: Colors.black);
                    }
                    final mq = MediaQuery.of(context);
                    final width = (mq.size.width * mq.devicePixelRatio * 1.1)
                        .clamp(1, 8192)
                        .toInt();
                    final height = (mq.size.height * mq.devicePixelRatio * 1.1)
                        .clamp(1, 8192)
                        .toInt();
                    return Image.asset(
                      _splashPath,
                      fit: BoxFit.cover,
                      cacheWidth: width,
                      cacheHeight: height,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(color: Colors.black);
                      },
                    );
                  },
                ),
              ),
            ),

            // Top gradient + larger logo
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container
                  (
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 144,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Bottom gradient with app name text
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        final glow = 2.0 + 10.0 * _pulse.value;
                        final glowOpacity = 0.5 + 0.4 * _pulse.value;
                        return Text(
                          titleText,
                          textAlign: TextAlign.center,
                          style: titleStyle.copyWith(
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(glowOpacity),
                                blurRadius: glow,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        final scale = 0.98 + 0.04 * _pulse.value;
                        final opacity = 0.7 + 0.3 * _pulse.value;
                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/pattern.svg',
                                width: titleWidth,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
