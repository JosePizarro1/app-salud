import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SfxManager {
  static final SfxManager _instance = SfxManager._internal();
  factory SfxManager() => _instance;

  SfxManager._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer()
    ..setAudioContext(AudioContext(
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));

  /// Play the global click sound effect if global audio settings allow it
  Future<void> playClick() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('bg_music_enabled') ?? true;
      if (!isEnabled) return;

      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/click_sound.wav'));
    } catch (_) {
      // Quietly ignore audio playback errors
    }
  }

  /// Play the motivational notification sound effect inside the app
  Future<void> playNotiSound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('bg_music_enabled') ?? true;
      if (!isEnabled) return;

      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/noti_sound.mp3'));
    } catch (_) {
      // Quietly ignore audio playback errors
    }
  }

  /// Play the cheerful success sound effect
  Future<void> playSuccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('bg_music_enabled') ?? true;
      if (!isEnabled) return;

      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/success_cheerful.mp3'));
    } catch (_) {
      // Quietly ignore audio playback errors
    }
  }

  /// Play the error sound effect
  Future<void> playError() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('bg_music_enabled') ?? true;
      if (!isEnabled) return;

      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/error_sound.mp3'));
    } catch (_) {
      // Quietly ignore audio playback errors
    }
  }

  /// Play the internal notification entry sound effect
  Future<void> playNotiInterna() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('bg_music_enabled') ?? true;
      if (!isEnabled) return;

      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('images/healthy_eating/sonido_noti_entrada.mp3'));
    } catch (_) {
      // Quietly ignore audio playback errors
    }
  }

  /// Clean up resources
  void dispose() {
    _sfxPlayer.dispose();
  }
}
