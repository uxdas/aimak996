import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pinned_message.dart';

class PinnedMessageService {
  static const String _baseUrl = 'http://176.126.164.86:8000';

  Future<PinnedMessage?> fetchPinnedMessage(int cityId) async {
    final response = await http.get(Uri.parse(
        'http://176.126.164.86:8000/categories/pinned-message/?city_id=1'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PinnedMessage.fromJson(data);
    } else {
      throw Exception('Ошибка загрузки закреплённого сообщения');
    }
  }
}
