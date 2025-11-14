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
  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF1E3A8A);
    const Color inactiveColor = Colors.white;
    const Color activeTextColor = Colors.white;
    final Color inactiveTextColor = activeColor.withOpacity(0.7);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: 6, vertical: widget.isActive ? 10 : 12),
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                height: 1.0,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
