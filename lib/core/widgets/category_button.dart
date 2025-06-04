import 'package:flutter/material.dart';

class CategoryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const CategoryButton({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF1E3A8A);
    final Color inactiveColor = Colors.white;
    final Color activeTextColor = Colors.white;
    final Color inactiveTextColor = activeColor.withOpacity(0.7);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
            border: widget.isActive
                ? Border.all(color: Colors.white, width: 1)
                : null,
            boxShadow: !widget.isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // <--
            children: [
              Icon(
                widget.icon,
                size: 22,
                color: widget.isActive ? activeTextColor : inactiveTextColor,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: widget.isActive ? activeTextColor : inactiveTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.0, // <== ключ!
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
