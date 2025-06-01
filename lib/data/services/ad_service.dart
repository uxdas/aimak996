import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/data/api_routes.dart';

class AdService {
  Future<List<AdModel>> fetchAds() async {
    final url = Uri.parse('${ApiRoutes.baseUrl}/ads/public-city/1/category/0');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      print('fetchAds: ${data.length} объявлений');
      return data.map((json) => AdModel.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка при загрузке объявлений: ${response.statusCode}');
    }
  }

  Future<List<AdModel>> fetchAdsByCategory(int categoryId) async {
    final url = Uri.parse('${ApiRoutes.baseUrl}/ads/public-city/1/category/$categoryId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      print('fetchAdsByCategory($categoryId): ${data.length} объявлений');
      return data.map((json) => AdModel.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка при загрузке объявлений по категории: ${response.statusCode}');
    }
  }

  Future<AdModel> fetchAdById(int id) async {
    final url = Uri.parse('${ApiRoutes.baseUrl}/ads/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AdModel.fromJson(data);
    } else {
      throw Exception('Ошибка при загрузке объявления: ${response.statusCode}');
    }
  }
}
