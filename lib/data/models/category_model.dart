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
    switch (id) {
      case 0:
        return Icons.apps;
      case 1:
        return Icons.home_outlined;
      case 2:
        return Icons.directions_car_outlined;
      case 3:
        return Icons.pets_outlined;
      case 4:
        return Icons.shopping_cart_outlined;
      case 5:
        return Icons.work_outline;
      case 7:
        return Icons.directions_bus_outlined;
      case 9:
        return Icons.newspaper_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
