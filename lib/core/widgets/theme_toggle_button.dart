import 'package:flutter/material.dart';

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
  late AnimationController _controller;
  late Animation<double> _thumbPosition;
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
      value: _isDark ? 1.0 : 0.0,
    );
    _thumbPosition = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(ThemeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != _isDark) {
      _isDark = widget.isDark;
      if (_isDark) {
        _controller.animateTo(1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic);
      } else {
        _controller.animateTo(0.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.toggleTheme,
        child: Container(
          height: 36,
          width: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Солнце (3 лучика)
              Positioned(
                left: 12,
                child: Row(
                  children: [
                    _SunDot(offset: 0),
                    const SizedBox(width: 2),
                    _SunDot(offset: 1),
                    const SizedBox(width: 2),
                    _SunDot(offset: 2),
                  ],
                ),
              ),
              // Луна
              Positioned(
                right: 10,
                child: Icon(
                  Icons.nightlight_round,
                  size: 20,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              // Бегунок
              AnimatedBuilder(
                animation: _thumbPosition,
                builder: (context, child) {
                  return Positioned(
                    left: 4 + 28 * _thumbPosition.value,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.2),
                          width: 1,
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
    );
  }
}

class _SunDot extends StatelessWidget {
  final int offset;
  const _SunDot({required this.offset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Color(0xFFFFA726),
        shape: BoxShape.circle,
      ),
    );
  }
}
