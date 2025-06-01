import 'package:flutter/material.dart';
import 'dart:math' as math;

class ThemeToggleButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<Color?> _colorAnimation;
  late final Animation<double> _moveAnimation;
  late final Animation<double> _morphAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    )..addStatusListener(_handleAnimationStatus);

    _setupAnimations();
    
    if (widget.isDark) {
      _controller.value = 1;
    }
  }

  void _setupAnimations() {
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _moveAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 15)
            .chain(CurveTween(curve: Curves.easeInOutBack)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 15, end: 0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    _rotationAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 360)
            .chain(CurveTween(curve: Curves.easeInOutBack)),
        weight: 1,
      ),
    ]).animate(_controller);

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.5)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.3)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    _morphAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1,
      ),
    ]).animate(_controller);

    _colorAnimation = ColorTween(
      begin: Colors.amber,
      end: Colors.indigo,
    ).animate(curvedAnimation);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      _isAnimating = false;
    }
  }

  void _handleTap() {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
      if (_controller.status == AnimationStatus.completed) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
    
    widget.toggleTheme();
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ThemeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark && !_isAnimating) {
      _isAnimating = true;
      if (widget.isDark) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: Theme.of(context).primaryColor,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sun
                  if (!widget.isDark || _controller.value < 1)
                    Opacity(
                      opacity: 1 - _controller.value,
                      child: Transform.translate(
                        offset: Offset(_moveAnimation.value, 0),
                        child: Transform.rotate(
                          angle: _rotationAnimation.value * math.pi / 180,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: ShaderMask(
                              shaderCallback: (bounds) => RadialGradient(
                                colors: [
                                  Colors.amber.shade300,
                                  Colors.orange.shade600,
                                ],
                                center: Alignment.center,
                                radius: 0.5,
                              ).createShader(bounds),
                              child: const Icon(
                                Icons.wb_sunny_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Eclipse effect
                  if (_controller.value > 0 && _controller.value < 1)
                    Positioned(
                      child: Transform.scale(
                        scale: 0.8 + (_morphAnimation.value * 0.2),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(_morphAnimation.value * 0.8),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Moon
                  if (widget.isDark || _controller.value > 0)
                    Opacity(
                      opacity: _controller.value,
                      child: Transform.translate(
                        offset: Offset(-_moveAnimation.value, 0),
                        child: Transform.rotate(
                          angle: (_rotationAnimation.value - 360) * math.pi / 180,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      Colors.grey.shade300,
                                      Colors.grey.shade500,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: const Icon(
                                    Icons.nightlight_round,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                // Moon craters
                                ...List.generate(3, (index) {
                                  final angle = index * (math.pi / 1.5);
                                  const radius = 6.0;
                                  return Positioned(
                                    left: radius * math.cos(angle) + 12,
                                    top: radius * math.sin(angle) + 12,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade600.withOpacity(0.3),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 