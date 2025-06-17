// lib/data/services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:nookat996/data/models/category_model.dart';

class CategoryService {
  final String baseUrl = 'http://5.59.233.32:8080';

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories/get'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception('error_loading_categories'.tr());
    }
  }
}
