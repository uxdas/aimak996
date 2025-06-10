import 'dart:math';
import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class TelegramRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const TelegramRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<TelegramRefreshIndicator> createState() =>
      _TelegramRefreshIndicatorState();
}

class _TelegramRefreshIndicatorState extends State<TelegramRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  static const _indicatorSize = 50.0;
  static const _indicatorStrokeWidth = 2.5;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: widget.onRefresh,
      trigger: IndicatorTrigger.leadingEdge,
      triggerMode: IndicatorTriggerMode.onEdge,
      durations: const RefreshIndicatorDurations(
        settleDuration: Duration(milliseconds: 200),
        cancelDuration: Duration(milliseconds: 200),
      ),
      builder: (context, child, controller) {
        return Stack(
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final loading = controller.state == IndicatorState.loading;
                if (loading && !_rotationController.isAnimating) {
                  _rotationController.repeat();
                } else if (!loading && _rotationController.isAnimating) {
                  _rotationController.stop();
                }

                return SizedBox(
                  height: _indicatorSize * controller.value.clamp(0.0, 1.0),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!controller.state.isIdle)
                          Container(
                            height: _indicatorSize,
                            width: _indicatorSize,
                            alignment: Alignment.center,
                            child: RotationTransition(
                              turns: _rotationController,
                              child: CustomPaint(
                                size: const Size.square(_indicatorSize),
                                painter: _TelegramLoadingPainter(
                                  color: Theme.of(context).primaryColor,
                                  value: loading
                                      ? null
                                      : controller.value.clamp(0.0, 1.0),
                                  strokeWidth: _indicatorStrokeWidth,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            child,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _TelegramLoadingPainter extends CustomPainter {
  final Color color;
  final double? value;
  final double strokeWidth;

  _TelegramLoadingPainter({
    required this.color,
    this.value,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (value != null) {
      // Draw static arc when dragging
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // Start from top
        2 * pi * value!, // Draw based on progress
        false,
        paint,
      );
    } else {
      // Draw complete circle when loading
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TelegramLoadingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.value != value ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
