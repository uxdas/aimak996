import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int _selectedCategoryId = 0;
  int get selectedCategoryId => _selectedCategoryId;

  Future<void> loadCategories() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('CategoryProvider: Starting to load categories');
      final categories = await _categoryService.getCategories();

      // Add "All" category at the beginning if it doesn't exist
      if (!categories.any((c) => c.id == 0)) {
        categories.insert(0, Categories.all);
      }

      _categories = categories;
      _error = null;
      developer.log('CategoryProvider: Categories loaded successfully');
      developer
          .log('CategoryProvider: Number of categories: ${_categories.length}');
      for (var category in _categories) {
        developer.log('CategoryProvider: Category: ${category.toString()}');
      }
    } catch (e, stackTrace) {
      developer.log('CategoryProvider: Error loading categories',
          error: e, stackTrace: stackTrace);
      _error = e.toString();
      _categories = [
        Categories.all
      ]; // Fallback to at least showing "All" category
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(int id) {
    developer.log('CategoryProvider: Selecting category with id: $id');
    _selectedCategoryId = id;
    notifyListeners();
  }

  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      developer.log('CategoryProvider: Error getting category by id: $id',
          error: e);
      return null;
    }
  }
}
