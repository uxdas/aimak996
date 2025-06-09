import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/data/api_routes.dart';
import 'package:projects/core/config/api_config.dart';
import 'package:flutter/foundation.dart';

class AdService {
  final String baseUrl = ApiConfig.baseUrl;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Future<List<AdModel>> fetchAds({
    int? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = categoryId != null
          ? Uri.parse(ApiRoutes.adsByCategory(categoryId))
          : Uri.parse(ApiRoutes.getAds);
      print('[API] Fetching ads from: $url');
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
      print('[API] Error fetching ads: $e');
      throw Exception('${"error_loading".tr()}: $e');
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
      debugPrint('[API] Fetching ad by id from: $url');
      debugPrint('[API] Headers: $_headers');

      final response = await http.get(url, headers: _headers);
      debugPrint('[API] Response status: ${response.statusCode}');
      debugPrint('[API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('[API] Decoded data: $data');
        return AdModel.fromJson(data);
      } else {
        debugPrint(
            '[API] Error response: ${response.statusCode} - ${response.body}');
        throw Exception(
            '${"error_loading".tr()}: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('[API] Error fetching ad by id: $e');
      debugPrint('[API] Stack trace: $stackTrace');
      throw Exception('${"error_loading".tr()}: $e');
    }
  }

  Future<List<AdModel>> fetchFavoriteAds(Set<String> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      debugPrint('fetchFavoriteAds - пустой список избранных');
      return [];
    }

    debugPrint('fetchFavoriteAds - начинаем загрузку для ID: $favoriteIds');
    final List<AdModel> favoriteAds = [];
    final List<String> failedIds = [];

    for (final id in favoriteIds) {
      try {
        debugPrint('fetchFavoriteAds - загрузка объявления ID: $id');
        final url = Uri.parse(ApiRoutes.getAdById(id));
        debugPrint('fetchFavoriteAds - URL запроса: $url');

        final response = await http.get(url, headers: _headers);
        debugPrint('fetchFavoriteAds - статус ответа: ${response.statusCode}');
        debugPrint('fetchFavoriteAds - тело ответа: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          debugPrint('fetchFavoriteAds - декодированные данные: $data');
          final ad = AdModel.fromJson(data);
          favoriteAds.add(ad);
          debugPrint('fetchFavoriteAds - успешно загружено объявление ID: $id');
        } else {
          throw Exception(
              'Ошибка загрузки: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint(
            'fetchFavoriteAds - ошибка загрузки объявления ID: $id - $e');
        failedIds.add(id);
      }
    }

    if (failedIds.isNotEmpty) {
      debugPrint(
          'fetchFavoriteAds - не удалось загрузить ${failedIds.length} объявлений: $failedIds');
    }

    debugPrint(
        'fetchFavoriteAds - итого загружено ${favoriteAds.length} объявлений');
    return favoriteAds;
  }
}
