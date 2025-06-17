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
    const primaryColor = Color(0xFF1E3A8A);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                categoryIcons[category.id] ?? FontAwesomeIcons.circle,
                size: 16,
                color: isSelected ? primaryColor : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                category.getLocalizedName(Localizations.localeOf(context)),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? primaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
