import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class Category {
  final int id;
  final String name;

  const Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('id') || !json.containsKey('name')) {
        throw FormatException('Missing required fields in JSON: $json');
      }

      final id = json['id'];
      final name = json['name'];

      if (id == null || name == null) {
        throw FormatException('Null values in required fields: $json');
      }

      final parsedId = id is int ? id : int.tryParse(id.toString());
      if (parsedId == null) {
        throw FormatException('Invalid id format in JSON: $json');
      }

      return Category(
        id: parsedId,
        name: name.toString(),
      );
    } catch (e) {
      developer.log('Error parsing Category from JSON', error: e);
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  IconData get iconData {
    // Маппинг категорий в иконки
    switch (id) {
      case 0: // Все
        return Icons.apps;
      case 1: // К. Мулк
        return Icons.home_outlined;
      case 2: // Авто
        return Icons.directions_car_outlined;
      case 3: // Мал-чарба
        return Icons.pets_outlined;
      case 4: // Алуу/сатуу
        return Icons.shopping_cart_outlined;
      case 5: // Жумуш
        return Icons.work_outline;
      case 7: // Каттам
        return Icons.directions_bus_outlined;
      case 9: // Жаңылыктар
        return Icons.newspaper_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class Categories {
  static const all = Category(
    id: 0,
    name: 'Жалпы',
  );

  static const transport = Category(
    id: 2,
    name: 'Авто',
  );

  static const animals = Category(
    id: 3,
    name: 'Мал-чарба',
  );

  static const trade = Category(
    id: 1,
    name: 'К. Мүлк',
  );

  static const realty = Category(
    id: 5,
    name: 'Жумуш',
  );

  static const List<Category> list = [
    all,
    transport,
    animals,
    trade,
    realty,
  ];

  static Category getById(int id) {
    return list.firstWhere(
      (category) => category.id == id,
      orElse: () => all,
    );
  }
}
