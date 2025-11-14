import 'package:flutter/material.dart';
import 'package:nookat996/core/models/city_board.dart';
import 'package:nookat996/core/services/city_board_service.dart';

class CityBoardProvider extends ChangeNotifier {
  final CityBoardService _service = CityBoardService();
  List<CityBoard> _cities = [];
  bool _isLoading = false;
  String? _error;

  List<CityBoard> get cities => _cities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cities = await _service.fetchCityBoards();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
