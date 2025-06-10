import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projects/data/models/ad_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:projects/data/api_routes.dart';

class AdService {
  static const String baseUrl = 'http://5.59.233.32:8080';
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<AdModel>> fetchAds({
    int? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final cityId = 1;
      final catId = categoryId ?? 0;
      final url = Uri.parse(
          'http://5.59.233.32:8080/ads/public-city/$cityId/category/$catId');
      print('[API] Fetching ads from: $url');

      final response = await http.get(url, headers: _headers);
      print('[API] Response status: [32m${response.statusCode}[0m');
      print('[API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => AdModel.fromJson(e)).toList();
      } else {
        throw Exception(
            'Ошибка загрузки: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[API] Error fetching ads: $e');
      throw Exception('Ошибка загрузки: $e');
    }
  }

  Future<List<AdModel>> fetchAdsByCategory(
    int categoryId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse(ApiRoutes.adsByCategory(categoryId));
      print('[API] Fetching ads by category from: $url');
      print('[API] Headers: $_headers');

      final response = await http.get(url, headers: _headers);
      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('[API] Decoded data length: ${data.length}');
        if (data.isNotEmpty) {
          print('[API] First item: ${data.first}');
        }
        return data.map((e) => AdModel.fromJson(e)).toList();
      } else {
        throw Exception(
            '${"error_loading".tr()}: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[API] Error fetching ads by category: $e');
      throw Exception('${"error_loading".tr()}: $e');
    }
  }

  Future<AdModel> fetchAdById(String id) async {
    try {
      final url = Uri.parse(ApiRoutes.getAdById(id));
      print('[API] Fetching ad by id from: $url');
      print('[API] Headers: $_headers');

      final response = await http.get(url, headers: _headers);
      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[API] Decoded data: $data');
        return AdModel.fromJson(data);
      } else {
        print(
            '[API] Error response: ${response.statusCode} - ${response.body}');
        throw Exception(
            '${"error_loading".tr()}: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      print('[API] Error fetching ad by id: $e');
      print('[API] Stack trace: $stackTrace');
      throw Exception('${"error_loading".tr()}: $e');
    }
  }

  Future<List<AdModel>> fetchFavoriteAds(Set<String> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      print('fetchFavoriteAds - пустой список избранных');
      return [];
    }

    print('fetchFavoriteAds - начинаем загрузку для ID: $favoriteIds');
    final List<AdModel> favoriteAds = [];
    final List<String> failedIds = [];

    for (final id in favoriteIds) {
      try {
        print('fetchFavoriteAds - загрузка объявления ID: $id');
        final url = Uri.parse(ApiRoutes.getAdById(id));
        print('fetchFavoriteAds - URL запроса: $url');

        final response = await http.get(url, headers: _headers);
        print('fetchFavoriteAds - статус ответа: ${response.statusCode}');
        print('fetchFavoriteAds - тело ответа: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('fetchFavoriteAds - декодированные данные: $data');
          final ad = AdModel.fromJson(data);
          favoriteAds.add(ad);
          print('fetchFavoriteAds - успешно загружено объявление ID: $id');
        } else {
          throw Exception(
              'Ошибка загрузки: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('fetchFavoriteAds - ошибка загрузки объявления ID: $id - $e');
        failedIds.add(id);
      }
    }

    if (failedIds.isNotEmpty) {
      print(
          'fetchFavoriteAds - не удалось загрузить ${failedIds.length} объявлений: $failedIds');
    }

    print(
        'fetchFavoriteAds - итого загружено ${favoriteAds.length} объявлений');
    return favoriteAds;
  }
}
