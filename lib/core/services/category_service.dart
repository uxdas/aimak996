import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../config/api_config.dart';

class CategoryService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Category>> getCategories() async {
    try {
      final url = '$baseUrl/categories/get';
      developer.log('Fetching categories from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
          'User-Agent': 'Noocat/1.0',
          'Connection': 'keep-alive',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timeout after 15 seconds');
        },
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        try {
          // Decode the response body as UTF-8
          final decodedBody = utf8.decode(response.bodyBytes);
          developer.log('Decoded response body: $decodedBody');

          final List<dynamic> jsonData = json.decode(decodedBody);
          developer.log('Parsed JSON data: $jsonData');

          final categories = jsonData
              .map((json) {
                try {
                  return Category.fromJson(json);
                } catch (e) {
                  developer.log('Error parsing category: $json', error: e);
                  return null;
                }
              })
              .whereType<Category>()
              .toList();

          if (categories.isEmpty) {
            throw Exception('No categories returned from server');
          }

          return categories;
        } catch (e) {
          developer.log('JSON parsing error', error: e);
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}');
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      developer.log('Network error', error: e);
      throw Exception('Network error - check your connection');
    } on TimeoutException catch (e) {
      developer.log('Timeout error', error: e);
      throw Exception('Request timeout - try again');
    } catch (e) {
      developer.log('Unexpected error', error: e);
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<Category> getCategoryById(int id) async {
    try {
      final categories = await getCategories();
      return categories.firstWhere(
        (category) => category.id == id,
        orElse: () => throw Exception('Category not found'),
      );
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }
}
