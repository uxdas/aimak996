import 'package:flutter/material.dart';
import '../models/contact_info.dart';
import '../services/contact_info_service.dart';

class ContactInfoProvider extends ChangeNotifier {
  final ContactInfoService _service = ContactInfoService();

  ContactInfo? _contactInfo;
  bool _isLoading = false;
  String? _error;

  ContactInfo? get contactInfo => _contactInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get moderatorPhone =>
      _contactInfo?.city.moderatorPhone ?? '0999109190';
  String get adminPhone => _contactInfo?.adminPhone ?? '0550707808';

  Future<void> loadContactInfo(int cityId) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final contactInfo = await _service.fetchContactInfo(cityId);
      _contactInfo = contactInfo;
      _error = null;
    } catch (e) {
      _error = e.toString();
      // Используем дефолтные значения при ошибке
      _contactInfo = ContactInfo(
        adminPhone: '0550707808',
        city: CityInfo(
          id: 1,
          name: 'Ноокат',
          moderatorPhone: '0999109190',
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
