import 'package:flutter/material.dart';

class CategoryModel {
  final int id;
  final String name;
  final String ruName;

  CategoryModel({required this.id, required this.name, required this.ruName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      ruName: json['ru_name'] ?? '',
    );
  }

  String getLocalizedName(Locale locale) {
    return locale.languageCode == 'ru' ? ruName : name;
  }

  IconData get iconData {
    String norm(String s) => s.trim().toLowerCase();
    final List<String> keys = [ruName, name]
        .where((e) => e.trim().isNotEmpty)
        .map(norm)
        .toList();

    for (final k in keys) {
      // Общее / Жалпы
      if (k == 'общее' || k == 'жалпы') return Icons.apps;

      // Попутка / Каттам
      if (k == 'попутка' || k == 'каттам') return Icons.route;

      // Недвижимость / К. Мүлк
      if (k == 'недвижимость' || k == 'к. мүлк') return Icons.home_outlined;

      // Авто
      if (k == 'авто') return Icons.directions_car_outlined;

      // Скот / Мал Чарба
      if (k == 'скот' || k == 'мал чарба') return Icons.pets_outlined;

      // Купить/Продать / Алуу/Сатуу
      if (k == 'купить/продать' || k == 'алуу/сатуу') {
        return Icons.swap_horiz;
      }

      // Работа / Жумуш
      if (k == 'работа' || k == 'жумуш') return Icons.work_outline;

      // Новости района / Район жаңылыктары
      if (k == 'новости района' || k == 'район жаңылыктары') {
        return Icons.newspaper_outlined;
      }
    }

    return Icons.category_outlined;
  }
}
