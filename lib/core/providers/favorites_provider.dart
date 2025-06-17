import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nookat996/data/models/ad_model.dart';

class FavoritesProvider with ChangeNotifier {
  final Map<String, AdModel> _favorites = {};
  final String _prefsKey = 'favorites_v2';
  bool _isLoading = false;

  FavoritesProvider() {
    debugPrint('FavoritesProvider - инициализация');
    _loadFavorites();
  }

  List<AdModel> get favoritesList {
    debugPrint(
        'FavoritesProvider - получение списка избранного: ${_favorites.keys}');
    return _favorites.values.toList();
  }

  bool get isLoading => _isLoading;

  bool isFavorite(String id) {
    final isFav = _favorites.containsKey(id);
    debugPrint(
        'FavoritesProvider - проверка избранного для ID: $id - результат: $isFav');
    return isFav;
  }

  Future<void> _loadFavorites() async {
    try {
      debugPrint('FavoritesProvider - начало загрузки избранного');
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(_prefsKey) ?? [];
      debugPrint(
          'FavoritesProvider - загружено из SharedPreferences: $favList');

      _favorites.clear();
      for (final jsonStr in favList) {
        final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
        final ad = AdModel.fromJson(jsonMap);
        _favorites[ad.id] = ad;
      }
      debugPrint(
          'FavoritesProvider - текущий список избранного: ${_favorites.keys}');
    } catch (e) {
      debugPrint('FavoritesProvider - ошибка загрузки избранного: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('FavoritesProvider - загрузка избранного завершена');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      debugPrint('FavoritesProvider - начало сохранения избранного');
      debugPrint('FavoritesProvider - сохраняемый список: ${_favorites.keys}');

      final prefs = await SharedPreferences.getInstance();
      final favList =
          _favorites.values.map((ad) => json.encode(ad.toJson())).toList();
      debugPrint('FavoritesProvider - конвертация в список JSON: $favList');

      await prefs.setStringList(_prefsKey, favList);
      debugPrint('FavoritesProvider - избранное успешно сохранено');
    } catch (e, stackTrace) {
      debugPrint('FavoritesProvider - ошибка при сохранении избранного: $e');
      debugPrint('FavoritesProvider - stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> toggleFavorite(AdModel ad) async {
    try {
      debugPrint('FavoritesProvider - toggleFavorite для ID: ${ad.id}');
      _isLoading = true;
      notifyListeners();

      if (_favorites.containsKey(ad.id)) {
        debugPrint('FavoritesProvider - удаление из избранного ID: ${ad.id}');
        _favorites.remove(ad.id);
      } else {
        debugPrint('FavoritesProvider - добавление в избранное ID: ${ad.id}');
        _favorites[ad.id] = ad;
      }

      await _saveFavorites();
      debugPrint('FavoritesProvider - изменения сохранены');
    } catch (e, stackTrace) {
      debugPrint('FavoritesProvider - ошибка в toggleFavorite: $e');
      debugPrint('FavoritesProvider - stack trace: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('FavoritesProvider - toggleFavorite завершен');
    }
  }

  Future<void> clearAll() async {
    try {
      debugPrint('FavoritesProvider - начало очистки избранного');
      _isLoading = true;
      notifyListeners();

      _favorites.clear();
      await _saveFavorites();
      debugPrint('FavoritesProvider - избранное очищено');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('FavoritesProvider - очистка завершена');
    }
  }
}
