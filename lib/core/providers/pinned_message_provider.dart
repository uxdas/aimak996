import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pinned_message.dart';
import '../services/pinned_message_service.dart';

class PinnedMessageProvider extends ChangeNotifier {
  final PinnedMessageService _service = PinnedMessageService();
  PinnedMessage? _message;
  bool _isHidden = false;
  static const String _hiddenKey = 'hidden_pinned_message_id';

  PinnedMessage? get message => _isHidden ? null : _message;

  Future<void> load(int cityId) async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenId = prefs.getInt(_hiddenKey);
    final msg = await _service.fetchPinnedMessage(cityId);
    if (msg != null && msg.id == hiddenId) {
      _isHidden = true;
    } else {
      _isHidden = false;
      _message = msg;
    }
    notifyListeners();
  }

  Future<void> hide() async {
    if (_message == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hiddenKey, _message!.id);
    _isHidden = true;
    notifyListeners();
  }
}
