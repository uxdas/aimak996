import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/data/api_routes.dart';
import 'package:projects/core/config/api_config.dart';

class AdService {
  final String baseUrl = ApiConfig.baseUrl;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Future<List<AdModel>> fetchAds({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse(ApiRoutes.getAds);
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

  Future<AdModel> fetchAdById(int id) async {
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
        throw Exception(
            '${"error_loading".tr()}: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[API] Error fetching ad by id: $e');
      throw Exception('${"error_loading".tr()}: $e');
    }
  }

  Future<List<AdModel>> fetchFavoriteAds(Set<String> favoriteIds) async {
    if (favoriteIds.isEmpty) {
      return [];
    }

    print('[API] Fetching favorite ads for IDs: $favoriteIds');
    final List<AdModel> favoriteAds = [];
    final List<String> failedIds = [];

    for (final id in favoriteIds) {
      try {
        print('[API] Fetching favorite ad with ID: $id');
        final ad = await fetchAdById(int.parse(id));
        favoriteAds.add(ad);
        print('[API] Successfully fetched favorite ad: $id');
      } catch (e) {
        print('[API] Failed to fetch favorite ad $id: $e');
        failedIds.add(id);
      }
    }

    if (failedIds.isNotEmpty) {
      print(
          '[API] Failed to fetch ${failedIds.length} favorite ads: $failedIds');
    }

    print('[API] Successfully fetched ${favoriteAds.length} favorite ads');
    return favoriteAds;
  }
}
