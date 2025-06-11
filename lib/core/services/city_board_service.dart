import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/city_board.dart';

class CityBoardService {
  static const String _url = 'http://5.59.233.32:8080/categories/city-boards/';

  Future<List<CityBoard>> fetchCityBoards() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => CityBoard.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка загрузки городов');
    }
  }
}
