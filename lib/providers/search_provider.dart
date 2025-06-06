import 'package:flutter/foundation.dart';

class SearchProvider extends ChangeNotifier {
  bool _isSearching = false;
  String _query = '';

  bool get isSearching => _isSearching;
  String get query => _query;

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) _query = '';
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void clearQuery() {
    _query = '';
    notifyListeners();
  }
}
