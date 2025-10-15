import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nookat996/data/models/category_model.dart';

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

  // Name-based icon mapping (both Kyrgyz and Russian variants)
  static const Map<String, IconData> _categoryIconsByName = {
    // Общее / Жалпы
    'общее': FontAwesomeIcons.grip,
    'жалпы': FontAwesomeIcons.grip,

    // Попутка / Каттам
    'попутка': FontAwesomeIcons.route,
    'каттам': FontAwesomeIcons.route,

    // Недвижимость / К. Мүлк
    'недвижимость': FontAwesomeIcons.building,
    'к. мүлк': FontAwesomeIcons.building,

    // Авто
    'авто': FontAwesomeIcons.car,

    // Скот / Мал Чарба
    'скот': FontAwesomeIcons.kiwiBird,
    'мал чарба': FontAwesomeIcons.kiwiBird,

    // Купить/Продать / Алуу/Сатуу
    'купить/продать': FontAwesomeIcons.arrowsRotate,
    'алуу/сатуу': FontAwesomeIcons.arrowsRotate,

    // Работа / Жумуш
    'работа': FontAwesomeIcons.briefcase,
    'жумуш': FontAwesomeIcons.briefcase,

    // Новости района / Район жаңылыктары
    'новости района': FontAwesomeIcons.newspaper,
    'район жаңылыктары': FontAwesomeIcons.newspaper,
  };

  IconData _resolveIcon() {
    String normalize(String s) => s.trim().toLowerCase();
    final candidates = <String>[
      category.name,
      category.ruName,
    ].where((e) => e.trim().isNotEmpty).map(normalize);

    for (final key in candidates) {
      final icon = _categoryIconsByName[key];
      if (icon != null) return icon;
    }
    // Fallback generic icon
    return FontAwesomeIcons.layerGroup;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E3A8A);
    final locale = Localizations.localeOf(context);
    final localizedName = category.getLocalizedName(locale);

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
                _resolveIcon(),
                size: 16,
                color: isSelected ? primaryColor : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                localizedName,
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
