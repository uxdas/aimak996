import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/category.dart';
import 'package:nookat996/data/models/category_model.dart';
import 'package:nookat996/data/services/category_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  int _selectedCategoryId = 0;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedCategoryId => _selectedCategoryId;

  Future<void> loadCategories() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final categories = await _categoryService.fetchCategories();

      if (!categories.any((c) => c.id == 0)) {
        categories.insert(
            0, CategoryModel(id: 0, name: 'Жалпы', ruName: 'Общее'));
      }
      _categories = categories;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _categories = [CategoryModel(id: 0, name: 'Жалпы', ruName: 'Общее')];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(int id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  void notifyLanguageChanged() {
    notifyListeners();
  }
}
