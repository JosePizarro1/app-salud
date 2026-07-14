import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/widgets/bounceable_scale.dart';
import '../../home/widgets/module_header.dart';
import '../../../app/theme/app_colors.dart';
import '../../../services/notification_service.dart';
import '../../../app/services/stats_sync_service.dart';
import '../../../app/services/background_music_manager.dart';

import '../widgets/meditation/meditation_selection_view.dart';
import '../widgets/meditation/meditation_breathing_view.dart';
import '../widgets/meditation/meditation_audio_selection_view.dart';
import '../widgets/meditation/meditation_player_view.dart';
import '../widgets/meditation/meditation_recommendations_view.dart';
import '../widgets/meditation/meditation_finished_view.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  // Flow State
  bool _isSessionActive = false;
  bool _isSessionFinished = false;
  bool _isConfiguring = false;
  bool _isSelectingAudio = false;
  bool _isPlaying = false;
  int _selectedMinutes = 1;
  int _secondsRemaining = 0;
  Timer? _sessionTimer;

  // Feedback Flow State
  bool _showFeedback = false;
  bool _isSavingFeedback = false;

  // Video Recommendations State
  bool _showRecommendations = false;
  List<Map<String, dynamic>> _recommendedVideos = [];
  bool _isLoadingVideos = false;

  // Breathing loop state: 'inhale', 'hold', 'exhale', 'hold_empty'
  String _breathingPhase = 'inhale';
  int _phaseSeconds = 0;
  Timer? _breathingTimer;

  // Animation controller for the breathing circle
  late AnimationController _circleAnimController;
  late Animation<double> _circleScaleAnimation;

  // ── Audio Player State ──
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _selectedAudioIndex; // 1-4
  int _totalAudioDuration = 0; // in seconds
  int _currentAudioPosition = 0; // in seconds
  bool _isAudioPaused = false;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _completionSub;

  // Notification Configuration State
  bool _isDayNotificationEnabled = false;
  int _dayHour = 7;
  int _dayMinute = 0;
  String _dayPeriod = 'AM';

  bool _isNightNotificationEnabled = false;
  int _nightHour = 7;
  int _nightMinute = 0;
  String _nightPeriod = 'PM';

  // Audio paths per category
  static const Map<int, List<String>> _audioPaths = {
    1: [
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 01 MINUTO/AUDIO-1.mp3',
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 01 MINUTO/AUDIO-2.mp3',
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 01 MINUTO/AUDIO-3.mp3',
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 01 MINUTO/audio-4.mp3',
    ],
    3: [
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 03 MINUTOS/AUDIO-1.mp3',
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 03 MINUTOS/AUDIO-2.mp3',
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 03 MINUTOS/AUDIO-3.mp3',
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 03 MINUTOS/AUDIO-4.mp3',
    ],
    5: [
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 05 MINUTOS/AUDIO 1.mp3',
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 05 MINUTOS/AUDIO 2.mp3',
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 05 MINUTOS/AUDIO 3.mp3',
      'audio/AUDIOS DE MEDITACIÓN GUIADA/AUDIOS 05 MINUTOS/AUDIO 4.mp3',
    ],
  };

  @override
  void initState() {
    super.initState();
    // Do NOT suspend background music here anymore, so it keeps playing in selection menu.
    WidgetsBinding.instance.addObserver(this);
    _circleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _circleScaleAnimation = Tween<double>(begin: 1.0, end: 1.7).animate(
      CurvedAnimation(parent: _circleAnimController, curve: Curves.easeInOut),
    );

    _loadNotificationSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache button images for instant rendering
    precacheImage(const AssetImage('assets/images/modulo_respiracion/B1minuto.webp'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/B3minutos.webp'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/B5minutos.webp'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/Bcampana.webp'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/sol.webp'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/luna.webp'), context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();
    _circleAnimController.dispose();
    _audioPlayer.dispose();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completionSub?.cancel();
    // Restore background music when leaving the page
    BackgroundMusicManager().unsuspendMusic();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isPlaying && !_isAudioPaused) {
        try {
          _audioPlayer.pause();
          setState(() {
            _isAudioPaused = true;
          });
        } catch (_) {}
      }
    }
  }

  // Load saved routine notifications from shared_preferences cache
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDayNotificationEnabled = prefs.getBool('meditation_day_enabled') ?? false;
      _dayHour = prefs.getInt('meditation_day_hour') ?? 7;
      _dayMinute = prefs.getInt('meditation_day_minute') ?? 0;
      _dayPeriod = prefs.getString('meditation_day_period') ?? 'AM';

      _isNightNotificationEnabled = prefs.getBool('meditation_night_enabled') ?? false;
      _nightHour = prefs.getInt('meditation_night_hour') ?? 7;
      _nightMinute = prefs.getInt('meditation_night_minute') ?? 0;
      _nightPeriod = prefs.getString('meditation_night_period') ?? 'PM';
    });
  }

  // Starts the 10s configuring breathing phase
  void _startBreathingSession(int minutes) {
    // Suspend background music when starting active session
    BackgroundMusicManager().suspendMusic();

    // Prevent timer multiplication
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();

    // Log meditation session duration to database and local cache
    StatsSyncService().logMeditationSession(minutes);

    setState(() {
      _selectedMinutes = minutes;
      _secondsRemaining = 8; // 8 segundos de configuración
      _isSessionActive = true;
      _isSessionFinished = false;
      _isConfiguring = true;
      _isSelectingAudio = false;
      _isPlaying = false;
      _breathingPhase = 'inhale';
      _phaseSeconds = 4;
    });

    _circleAnimController.reset();
    _circleAnimController.forward();

    // 1. Overall session countdown timer (Configurando)
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        // End of 8s configuring phase → Show audio selection
        _sessionTimer?.cancel();
        _breathingTimer?.cancel();
        _circleAnimController.stop();
        _circleAnimController.reset();
        setState(() {
          _isConfiguring = false;
          _isSelectingAudio = true;
        });
      }
    });

    // 2. Breathing phase loop (Box breathing: 4s inhale, 4s hold, 4s exhale, 4s hold)
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _phaseSeconds--;
        if (_phaseSeconds <= 0) {
          _advanceBreathingPhase();
        }
      });
    });
  }

  void _advanceBreathingPhase() {
    setState(() {
      _phaseSeconds = 4;
      if (_breathingPhase == 'inhale') {
        _breathingPhase = 'hold';
      } else if (_breathingPhase == 'hold') {
        _breathingPhase = 'exhale';
        _circleAnimController.reverse();
      } else if (_breathingPhase == 'exhale') {
        _breathingPhase = 'hold_empty';
      } else {
        _breathingPhase = 'inhale';
        _circleAnimController.forward();
      }
    });
  }

  // ── Start audio playback ──
  Future<void> _startAudioPlayback(int audioIndex) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedAudioIndex = audioIndex;
      _isSelectingAudio = false;
      _isPlaying = true;
      _isAudioPaused = false;
      _currentAudioPosition = 0;
      _totalAudioDuration = _selectedMinutes * 60; // fallback
    });

    final paths = _audioPaths[_selectedMinutes]!;
    final path = paths[audioIndex - 1];

    // Listen to audio events
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completionSub?.cancel();

    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() => _totalAudioDuration = d.inSeconds);
      }
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => _currentAudioPosition = p.inSeconds);
      }
    });

    _completionSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        _audioPlayer.stop();
        setState(() {
          _showFeedback = true;
        });
      }
    });

    try {
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reproducir audio', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    if (_isAudioPaused) {
      _audioPlayer.resume();
    } else {
      _audioPlayer.pause();
    }
    setState(() => _isAudioPaused = !_isAudioPaused);
  }

  void _seekRelative(int seconds) {
    final newPos = (_currentAudioPosition + seconds).clamp(0, _totalAudioDuration);
    _audioPlayer.seek(Duration(seconds: newPos));
  }

  void _endSession({required bool completed}) {
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();
    _circleAnimController.stop();
    _circleAnimController.reset();
    _audioPlayer.stop();

    setState(() {
      _isSessionActive = false;
      _isConfiguring = false;
      _isSelectingAudio = false;
      _isPlaying = false;
      _showFeedback = false;
      _isSessionFinished = completed;
    });

    // Restore background music when session ends/cancels
    BackgroundMusicManager().unsuspendMusic();
  }

  Future<void> _submitFeedback(String experience, String feeling) async {
    setState(() {
      _isSavingFeedback = true;
    });

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user != null) {
        await client.from('meditation_feedback').insert({
          'user_id': user.id,
          'duration_minutes': _selectedMinutes,
          'experience': experience,
          'feeling': feeling,
        });
      }
    } catch (e) {
      debugPrint('Error saving meditation feedback to Supabase: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingFeedback = false;
          _showFeedback = false;
          _isPlaying = false;
          _isSessionActive = false;
          _isSessionFinished = true;
        });
        // Restore background music since session has finished and they will see recommendations
        BackgroundMusicManager().unsuspendMusic();
        _loadRecommendedVideos();
      }
    }
  }

  Future<void> _loadRecommendedVideos() async {
    setState(() {
      _isLoadingVideos = true;
      _showRecommendations = true;
      _isPlaying = false;
    });
    
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('recommended_videos')
          .select()
          .order('order_index', ascending: true);
      
      if (mounted) {
        setState(() {
          _recommendedVideos = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('Error loading recommended videos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVideos = false;
        });
      }
    }
  }

  // Helper widget to build time inputs inside modal
  Widget _buildTimeInputBox({
    required TextEditingController controller,
    required StateSetter setModalState,
    bool isHour = false,
  }) {
    return Container(
      width: 65,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3B60B3).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 2,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3B60B3),
          ),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () {
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
          onChanged: (val) {
            if (isHour && val.length == 2) {
              FocusScope.of(context).nextFocus();
            }
          },
        ),
      ),
    );
  }

  // Helper widget to build AM/PM switcher
  Widget _buildPeriodToggle(String selectedPeriod, Function(String) onPeriodChanged) {
    final bool isAM = selectedPeriod == 'AM';
    return Container(
      width: 55,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPeriodChanged('AM'),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isAM ? const Color(0xFFE56BB5) : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'AM',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAM ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPeriodChanged('PM'),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: !isAM ? const Color(0xFFE56BB5) : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'PM',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: !isAM ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Routine Modal Bottom Sheet Builder
  void _showRoutineModal() async {
    bool localDayEnabled = _isDayNotificationEnabled;
    int localDayHour = _dayHour;
    int localDayMinute = _dayMinute;
    String localDayPeriod = _dayPeriod;

    bool localNightEnabled = _isNightNotificationEnabled;
    int localNightHour = _nightHour;
    int localNightMinute = _nightMinute;
    String localNightPeriod = _nightPeriod;

    final dayHourController = TextEditingController(text: localDayHour.toString().padLeft(2, '0'));
    final dayMinController = TextEditingController(text: localDayMinute.toString().padLeft(2, '0'));
    
    final nightHourController = TextEditingController(text: localNightHour.toString().padLeft(2, '0'));
    final nightMinController = TextEditingController(text: localNightMinute.toString().padLeft(2, '0'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  border: Border(
                    top: BorderSide(color: Color(0xFF88D49E), width: 4),
                    left: BorderSide(color: Color(0xFF88D49E), width: 4),
                    right: BorderSide(color: Color(0xFF88D49E), width: 4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¡Crea tu ',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3B60B3),
                            ),
                          ),
                          Text(
                            'rutina!',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF28AF52),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Selecciona los horarios en los que deseas recibir recordatorios para tus pausas de meditación',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4C7CC2),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // sol Sol solarsol
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/modulo_respiracion/sol.webp',
                            width: 44,
                            height: 44,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Durante el día:',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF28AF52),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                localDayEnabled = !localDayEnabled;
                              });
                            },
                            child: Image.asset(
                              localDayEnabled
                                  ? 'assets/images/modulo_respiracion/Bactivar_notificacion.webp'
                                  : 'assets/images/modulo_respiracion/Bdesactivar_notificacion.webp',
                              width: 80,
                              height: 36,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimeInputBox(
                            controller: dayHourController,
                            setModalState: setModalState,
                            isHour: true,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          _buildTimeInputBox(
                            controller: dayMinController,
                            setModalState: setModalState,
                            isHour: false,
                          ),
                          const SizedBox(width: 16),
                          _buildPeriodToggle(localDayPeriod, (p) {
                            setModalState(() {
                              localDayPeriod = p;
                            });
                          }),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Luna lunas moon
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/modulo_respiracion/luna.webp',
                            width: 44,
                            height: 44,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Antes de dormir:',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF28AF52),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                localNightEnabled = !localNightEnabled;
                              });
                            },
                            child: Image.asset(
                              localNightEnabled
                                  ? 'assets/images/modulo_respiracion/Bactivar_notificacion.webp'
                                  : 'assets/images/modulo_respiracion/Bdesactivar_notificacion.webp',
                              width: 80,
                              height: 36,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimeInputBox(
                            controller: nightHourController,
                            setModalState: setModalState,
                            isHour: true,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          _buildTimeInputBox(
                            controller: nightMinController,
                            setModalState: setModalState,
                            isHour: false,
                          ),
                          const SizedBox(width: 16),
                          _buildPeriodToggle(localNightPeriod, (p) {
                            setModalState(() {
                              localNightPeriod = p;
                            });
                          }),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Guardar Rutina Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final int? dHour = int.tryParse(dayHourController.text);
                            final int? dMin = int.tryParse(dayMinController.text);
                            final int? nHour = int.tryParse(nightHourController.text);
                            final int? nMin = int.tryParse(nightMinController.text);

                            int finalDHour = dHour ?? 7;
                            int finalDMin = dMin ?? 0;
                            int finalNHour = nHour ?? 8;
                            int finalNMin = nMin ?? 0;

                            if (localDayEnabled) {
                              if (dHour == null || dHour < 1 || dHour > 12 ||
                                  dMin == null || dMin < 0 || dMin > 59) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Horario diurno no válido. La hora debe estar entre 1-12 y los minutos entre 0-59. 🕰️',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                );
                                return;
                              }
                              finalDHour = dHour;
                              finalDMin = dMin;
                            }

                            if (localNightEnabled) {
                              if (nHour == null || nHour < 1 || nHour > 12 ||
                                  nMin == null || nMin < 0 || nMin > 59) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Horario nocturno no válido. La hora debe estar entre 1-12 y los minutos entre 0-59. 🕰️',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                );
                                return;
                              }
                              finalNHour = nHour;
                              finalNMin = nMin;
                            }

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('meditation_day_enabled', localDayEnabled);
                            await prefs.setInt('meditation_day_hour', finalDHour);
                            await prefs.setInt('meditation_day_minute', finalDMin);
                            await prefs.setString('meditation_day_period', localDayPeriod);

                            await prefs.setBool('meditation_night_enabled', localNightEnabled);
                            await prefs.setInt('meditation_night_hour', finalNHour);
                            await prefs.setInt('meditation_night_minute', finalNMin);
                            await prefs.setString('meditation_night_period', localNightPeriod);

                            // Schedule day notification
                            if (localDayEnabled) {
                              int hour24 = finalDHour;
                              if (localDayPeriod == 'PM' && finalDHour != 12) hour24 += 12;
                              if (localDayPeriod == 'AM' && finalDHour == 12) hour24 = 0;
                              
                              await NotificationService().scheduleDailyNotification(
                                id: 1,
                                title: '🧘 Momento de Pausa Diurna',
                                body: '¡Es hora de tomar tu pausa de respiración de hoy! Conéctate contigo mismo. 🌸',
                                hour: hour24,
                                minute: finalDMin,
                              );
                            } else {
                              await NotificationService().cancelNotification(1);
                            }

                            if (localNightEnabled) {
                              int hour24 = finalNHour;
                              if (localNightPeriod == 'PM' && finalNHour != 12) hour24 += 12;
                              if (localNightPeriod == 'AM' && finalNHour == 12) hour24 = 0;

                              await NotificationService().scheduleDailyNotification(
                                id: 2,
                                title: '🌙 Momento de Relajación Nocturna',
                                body: '¡Es hora de liberar las tensiones del día con tu meditación nocturna! Descansa. ✨',
                                hour: hour24,
                                minute: finalNMin,
                              );
                            } else {
                              await NotificationService().cancelNotification(2);
                            }

                            await _loadNotificationSettings();

                            if (mounted) {
                              navigator.pop();
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '¡Tu rutina de recordatorios ha sido guardada! 🔔✨',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFF28AF52),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF28AF52),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 1.5,
                          ),
                          child: Text(
                            'Guardar Rutina',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _getCurrentView() {
    if (_showRecommendations) {
      return MeditationRecommendationsView(
        recommendedVideos: _recommendedVideos,
        isLoadingVideos: _isLoadingVideos,
        onExit: () {
          setState(() {
            _showRecommendations = false;
            _isSessionFinished = false;
          });
          BackgroundMusicManager().unsuspendMusic();
        },
        onVideoStarted: (url) {
          BackgroundMusicManager().suspendMusic();
        },
        onVideoEnded: () {
          BackgroundMusicManager().unsuspendMusic();
        },
      );
    }
    if (_isSessionActive) {
      if (_isConfiguring) {
        return MeditationBreathingView(
          secondsRemaining: _secondsRemaining,
          phaseSeconds: _phaseSeconds,
          breathingPhase: _breathingPhase,
          isConfiguring: _isConfiguring,
          circleScaleAnimation: _circleScaleAnimation,
          onClose: () => _endSession(completed: false),
        );
      }
      if (_isSelectingAudio) {
        return MeditationAudioSelectionView(
          selectedMinutes: _selectedMinutes,
          onAudioSelected: _startAudioPlayback,
          onClose: () => _endSession(completed: false),
        );
      }
      if (_isPlaying) {
        return MeditationPlayerView(
          selectedAudioIndex: _selectedAudioIndex,
          selectedMinutes: _selectedMinutes,
          currentAudioPosition: _currentAudioPosition,
          totalAudioDuration: _totalAudioDuration,
          isAudioPaused: _isAudioPaused,
          showFeedback: _showFeedback,
          isSavingFeedback: _isSavingFeedback,
          onTogglePause: _togglePause,
          onSeekRelative: _seekRelative,
          onClose: () => _endSession(completed: false),
          onSubmitFeedback: _submitFeedback,
        );
      }
      return MeditationBreathingView(
        secondsRemaining: _secondsRemaining,
        phaseSeconds: _phaseSeconds,
        breathingPhase: _breathingPhase,
        isConfiguring: _isConfiguring,
        circleScaleAnimation: _circleScaleAnimation,
        onClose: () => _endSession(completed: false),
      );
    }
    if (_isSessionFinished) {
      return MeditationFinishedView(
        selectedMinutes: _selectedMinutes,
        onExit: () {
          setState(() {
            _isSessionFinished = false;
          });
          BackgroundMusicManager().unsuspendMusic();
        },
      );
    }
    return MeditationSelectionView(
      onStartSession: _startBreathingSession,
    );
  }

  // Should header be visible
  bool get _showHeader => !_isSessionActive && !_isSessionFinished && !_showRecommendations;

  @override
  Widget build(BuildContext context) {
    final bool isNotificationActive = _isDayNotificationEnabled || _isNightNotificationEnabled;
    final bool isSelectionView = !_showRecommendations && !_isSessionActive && !_isSessionFinished;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dynamic Background
          if (isSelectionView || _isSelectingAudio) ...[
            Image.asset(
              'assets/images/fondo_modulo3.webp',
              fit: BoxFit.cover,
            ),
            if (_isSelectingAudio)
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
          ] else
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF9F6F0), Color(0xFFFFFDF9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

          // Core views
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _getCurrentView(),
            ),
          ),

          // Header always visible
          if (_showHeader) ...[
            const ModuleHeader(showHome: true),

            // Notification Routine Trigger Bell Button
            if (!_isPlaying)
              Positioned(
                left: MediaQuery.of(context).size.width * 0.22,
                top: MediaQuery.of(context).size.height * 0.082,
                child: BounceableScale(
                  onTap: _showRoutineModal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.19,
                    height: MediaQuery.of(context).size.width * 0.19,
                    child: Opacity(
                      opacity: isNotificationActive ? 1.0 : 0.55,
                      child: Image.asset(
                        'assets/images/modulo_respiracion/Bcampana.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
