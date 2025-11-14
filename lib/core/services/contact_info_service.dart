import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nookat996/core/models/contact_info.dart';

class ContactInfoService {
  static const String _baseUrl = 'http://176.126.164.86:8000';

  Future<ContactInfo?> fetchContactInfo(int cityId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories/contact-info/?city_id=$cityId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ContactInfo.fromJson(data);
      } else {
        throw Exception(
            'Ошибка загрузки контактной информации: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }
}
