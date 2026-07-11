import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundMusicManager {
  static final BackgroundMusicManager _instance = BackgroundMusicManager._internal();
  factory BackgroundMusicManager() => _instance;

  BackgroundMusicManager._internal() {
    // Set looping release mode on the player
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  SharedPreferences? _prefs;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);

  bool get isPlaying => isPlayingNotifier.value;

  // Key for local preference persistence
  static const String _prefKey = 'bg_music_enabled';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final bool isEnabled = _prefs?.getBool(_prefKey) ?? true; // Plays by default
    if (isEnabled) {
      await startMusic();
    }
  }

  bool _isMusicSuspended = false;

  Future<void> startMusic() async {
    try {
      isPlayingNotifier.value = true;
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_prefKey, true);
      
      // Only play the actual background track if NOT suspended by a sub-module
      if (!_isMusicSuspended) {
        await _audioPlayer.play(AssetSource('audio/music_fondo_sliced.mp3'));
      }
    } catch (e) {
      debugPrint('Error starting background music: $e');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop();
      isPlayingNotifier.value = false;
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_prefKey, false);
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  // Call this when entering a custom audio page to pause the background music track
  // without changing the user's global sound toggle preference.
  void suspendMusic() {
    _isMusicSuspended = true;
    try {
      _audioPlayer.pause();
    } catch (e) {
      debugPrint('Error suspending background music: $e');
    }
  }

  // Call this when leaving the custom audio page to restore background music playback
  // if global sound is still enabled.
  void unsuspendMusic() {
    _isMusicSuspended = false;
    try {
      if (isPlaying) {
        // If the player was paused/stopped, play it or resume it
        _audioPlayer.resume();
      }
    } catch (e) {
      debugPrint('Error unsuspending background music: $e');
    }
  }

  Future<void> toggleMusic() async {
    if (isPlaying) {
      await stopMusic();
    } else {
      await startMusic();
    }
  }
}
