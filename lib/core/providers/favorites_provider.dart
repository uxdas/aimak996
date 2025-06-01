import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favorites = {};
  final String _prefsKey = 'favorites';
  bool _isLoading = false;

  FavoritesProvider() {
    _loadFavorites();
  }

  Set<String> get favorites => _favorites;
  bool get isLoading => _isLoading;

  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> _loadFavorites() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(_prefsKey) ?? [];
      _favorites.clear();
      _favorites.addAll(favList);
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    try {
      debugPrint('Начало сохранения избранного');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, _favorites.toList());
      debugPrint('Избранное успешно сохранено');
    } catch (e, stackTrace) {
      debugPrint('Ошибка при сохранении избранного: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Начало toggleFavorite для ID: $id');
      debugPrint('Текущий список избранного: $_favorites');

      if (_favorites.contains(id)) {
        debugPrint('Удаление из избранного');
        _favorites.remove(id);
      } else {
        debugPrint('Добавление в избранное');
        _favorites.add(id);
      }
      debugPrint('Сохранение изменений...');
      await _saveFavorites();
      debugPrint('Изменения сохранены успешно');
    } catch (e, stackTrace) {
      debugPrint('Ошибка в toggleFavorite: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('toggleFavorite завершен');
    }
  }

  Future<void> clearAll() async {
    try {
      _isLoading = true;
      notifyListeners();

      _favorites.clear();
      await _saveFavorites();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
