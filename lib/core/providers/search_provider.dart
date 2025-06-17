import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:nookat996/data/models/ad_model.dart'; // путь к твоей модели

class SearchProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<AdModel> results = [];

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    isLoading = true;
    error = null;
    results = [];
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://5.59.233.32:8080/ads/search/1?q=$query'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        results = data.map((item) => AdModel.fromJson(item)).toList();
      } else {
        error = 'server_error'.tr();
      }
    } catch (e) {
      error = 'network_error'.tr();
    }

    isLoading = false;
    notifyListeners();
  }

  void clear() {
    results = [];
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
