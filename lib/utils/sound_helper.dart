import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundHelper {
  static Future<void> playIfEnabled(String asset, {double volume = 1.0}) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('sound_enabled') ?? true;
    if (!enabled) return;
    final player = AudioPlayer();
    await player.play(AssetSource(asset), volume: volume);
  }
}
