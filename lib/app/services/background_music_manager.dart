import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundMusicManager with WidgetsBindingObserver {
  static final BackgroundMusicManager _instance = BackgroundMusicManager._internal();
  factory BackgroundMusicManager() => _instance;

  BackgroundMusicManager._internal() {
    // Set looping release mode on the player
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  SharedPreferences? _prefs;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> volumeNotifier = ValueNotifier<double>(0.5);

  bool get isPlaying => isPlayingNotifier.value;
  bool get isEnabled => _prefs?.getBool(_prefKey) ?? true;

  // Key for local preference persistence
  static const String _prefKey = 'bg_music_enabled';

  Future<void> init() async {
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.addObserver(this);
    _prefs = await SharedPreferences.getInstance();
    
    // Load and apply volume setting
    final double savedVolume = _prefs?.getDouble('bg_music_volume') ?? 0.5;
    volumeNotifier.value = savedVolume;
    await _audioPlayer.setVolume(savedVolume);

    final bool isEnabled = _prefs?.getBool(_prefKey) ?? true; // Plays by default
    if (isEnabled) {
      await startMusic();
    }
  }

  Future<void> setVolume(double newVolume) async {
    try {
      volumeNotifier.value = newVolume;
      await _audioPlayer.setVolume(newVolume);
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setDouble('bg_music_volume', newVolume);
    } catch (e) {
      debugPrint('Error setting background music volume: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      try {
        _audioPlayer.pause();
      } catch (_) {}
    } else if (state == AppLifecycleState.resumed) {
      try {
        if (isPlaying && !_isMusicSuspended) {
          _audioPlayer.resume();
        }
      } catch (_) {}
    }
  }

  String _currentTrackAsset = 'audio/music_fondo_sliced.mp3';
  bool _isMusicSuspended = false;

  void _safeSetIsPlaying(bool value) {
    if (isPlayingNotifier.value == value) return;
    final phase = WidgetsBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isPlayingNotifier.value = value;
      });
    } else {
      isPlayingNotifier.value = value;
    }
  }

  Future<void> startMusic() async {
    try {
      _safeSetIsPlaying(true);
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_prefKey, true);
      
      // Only play the actual background track if NOT suspended by a sub-module
      if (!_isMusicSuspended) {
        await _audioPlayer.play(AssetSource(_currentTrackAsset));
      }
    } catch (e) {
      debugPrint('Error starting background music: $e');
    }
  }

  /// Cambia y reproduce una pista de música de fondo personalizada (ej. 'audio/audio_yoga.mp3')
  Future<void> playCustomTrack(String trackAssetPath) async {
    try {
      final bool wasSameTrack = _currentTrackAsset == trackAssetPath;
      _currentTrackAsset = trackAssetPath;
      _isMusicSuspended = false;
      _prefs ??= await SharedPreferences.getInstance();
      final bool isEnabled = _prefs?.getBool(_prefKey) ?? true;
      if (isEnabled) {
        _safeSetIsPlaying(true);
        if (!wasSameTrack || _audioPlayer.state != PlayerState.playing) {
          await _audioPlayer.play(AssetSource(_currentTrackAsset));
        }
      } else {
        _safeSetIsPlaying(false);
      }
    } catch (e) {
      debugPrint('Error playing custom background track $trackAssetPath: $e');
    }
  }

  /// Restaura la pista de música de fondo principal ('audio/music_fondo_sliced.mp3')
  Future<void> restoreDefaultTrack() async {
    try {
      const String defaultTrack = 'audio/music_fondo_sliced.mp3';
      final bool wasSameTrack = _currentTrackAsset == defaultTrack;
      _currentTrackAsset = defaultTrack;
      _isMusicSuspended = false;
      restoreVolumeFromMeditation();
      _prefs ??= await SharedPreferences.getInstance();
      final bool isEnabled = _prefs?.getBool(_prefKey) ?? true;
      if (isEnabled) {
        _safeSetIsPlaying(true);
        if (!wasSameTrack || _audioPlayer.state != PlayerState.playing) {
          await _audioPlayer.play(AssetSource(_currentTrackAsset));
        }
      } else {
        _safeSetIsPlaying(false);
      }
    } catch (e) {
      debugPrint('Error restoring default background track: $e');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop();
      _safeSetIsPlaying(false);
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_prefKey, false);
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  double? _preLoweredVolume;

  /// Disminuye temporalmente el volumen de la música de fondo (ej. respiración/selección de meditación)
  void lowerVolumeForMeditation({double level = 0.15}) {
    try {
      _preLoweredVolume ??= volumeNotifier.value;
      _audioPlayer.setVolume(level);
    } catch (e) {
      debugPrint('Error lowering background music volume: $e');
    }
  }

  /// Restaura el volumen original de la música de fondo
  void restoreVolumeFromMeditation() {
    try {
      if (_preLoweredVolume != null) {
        _audioPlayer.setVolume(_preLoweredVolume!);
        _preLoweredVolume = null;
      } else {
        _audioPlayer.setVolume(volumeNotifier.value);
      }
    } catch (e) {
      debugPrint('Error restoring background music volume: $e');
    }
  }

  // Call this when entering a custom audio page to pause the background music track
  // without changing the user's global sound toggle preference.
  Future<void> suspendMusic() async {
    _isMusicSuspended = true;
    try {
      await _audioPlayer.stop();
      _safeSetIsPlaying(false);
    } catch (e) {
      debugPrint('Error suspending background music: $e');
    }
  }

  // Call this when leaving the custom audio page to restore background music playback
  // if global sound is still enabled.
  Future<void> unsuspendMusic() async {
    _isMusicSuspended = false;
    restoreVolumeFromMeditation();
    try {
      final bool isEnabled = _prefs?.getBool(_prefKey) ?? true;
      if (isEnabled) {
        await startMusic();
      } else {
        _safeSetIsPlaying(false);
      }
    } catch (e) {
      debugPrint('Error unsuspending background music: $e');
    }
  }

  Future<void> toggleMusic() async {
    if (isPlayingNotifier.value) {
      await stopMusic();
    } else {
      _isMusicSuspended = false;
      await startMusic();
    }
  }
}
