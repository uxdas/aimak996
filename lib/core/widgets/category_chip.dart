import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projects/data/models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  static const Map<int, IconData> categoryIcons = {
    0: FontAwesomeIcons.layerGroup,
    1: FontAwesomeIcons.building,
    2: FontAwesomeIcons.truckPickup,
    3: FontAwesomeIcons.kiwiBird,
    4: FontAwesomeIcons.arrowsRotate,
    5: FontAwesomeIcons.briefcase,
    7: FontAwesomeIcons.route,
    9: FontAwesomeIcons.newspaper,
  };

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E3A8A);
    final backgroundColor = isSelected ? primaryColor : Colors.white;
    final iconColor = isSelected ? Colors.white : primaryColor;
    final textColor = isSelected ? Colors.white : primaryColor;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                categoryIcons[category.id] ?? FontAwesomeIcons.circle,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 6),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
