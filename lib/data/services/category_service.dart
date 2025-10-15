// lib/data/services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:nookat996/data/models/category_model.dart';

class CategoryService {
  final String baseUrl = 'http://176.126.164.86:8000';

  Future<List<CategoryModel>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/categories/get');
    print('[CAT] Request: GET $url');
    try {
      final response = await http.get(url);
      print('[CAT] Response status: ${response.statusCode}');
      print('[CAT] Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('[CAT] Parsed categories count: ${data.length}');
        return data.map((e) => CategoryModel.fromJson(e)).toList();
      } else {
        print('[CAT] Error response: ${response.statusCode} - ${response.body}');
        throw Exception('error_loading_categories'.tr());
      }
    } catch (e, st) {
      print('[CAT] Network/Error while fetching categories: $e');
      print('[CAT] Stack trace: $st');
      rethrow;
    }
  }
}
