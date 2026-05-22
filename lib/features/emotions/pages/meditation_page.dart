import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../home/widgets/module_header.dart';
import '../../../app/theme/app_colors.dart';
import '../../../services/notification_service.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> with TickerProviderStateMixin {
  bool _isCommitted = false;
  bool _wiggleCheckbox = false;
  int? _selectedTimeOption;

  // Flow State
  bool _isSessionActive = false;
  bool _isSessionFinished = false;
  bool _isConfiguring = false;
  bool _isSelectingAudio = false; // NEW: audio selection view
  bool _isPlaying = false;        // NEW: player view active
  int _selectedMinutes = 1;
  int _secondsRemaining = 0;
  Timer? _sessionTimer;

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

  // ── Particle Animation ──
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final _random = Random();

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

  static const List<String> _audioTitles = [
    'Meditación de Calma Interior 🌸',
    'Conexión con tu Respiración 🌿',
    'Relajación Consciente 🌙',
    'Momento de Bienestar ✨',
  ];

  @override
  void initState() {
    super.initState();
    _circleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _circleScaleAnimation = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _circleAnimController, curve: Curves.easeInOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Generate particles
    for (int i = 0; i < 30; i++) {
      _particles.add(_Particle(random: _random));
    }

    _loadNotificationSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache button images for instant rendering
    precacheImage(const AssetImage('assets/images/modulo_respiracion/B1minuto.png'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/B3minutos.png'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/B5minutos.png'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/Bcampana.PNG'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/sol.png'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/luna.png'), context);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();
    _circleAnimController.dispose();
    _particleController.dispose();
    _audioPlayer.dispose();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completionSub?.cancel();
    super.dispose();
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

  void _triggerWiggle() {
    setState(() => _wiggleCheckbox = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _wiggleCheckbox = false);
      }
    });
  }

  // Starts the 10s configuring breathing phase
  void _startBreathingSession(int minutes) {
    if (!_isCommitted) {
      _triggerWiggle();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Por favor, confirma tu compromiso de bienestar primero! 🌸',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    // Prevent timer multiplication
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();

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
        // End of 10s configuring phase → Show audio selection
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
        _endSession(completed: true);
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
      if (completed) {
        _isSessionFinished = true;
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTimeShort(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getPhaseColor() {
    switch (_breathingPhase) {
      case 'inhale':
        return AppColors.accent;
      case 'hold':
        return AppColors.secondary;
      case 'exhale':
        return AppColors.primary;
      default:
        return const Color(0xFF9083ED);
    }
  }

  String _getPhaseText() {
    switch (_breathingPhase) {
      case 'inhale':
        return 'Inhala profundamente... 🌬️';
      case 'hold':
        return 'Sostén el aire... 🧘‍♂️';
      case 'exhale':
        return 'Exhala lentamente... 🍃';
      case 'hold_empty':
        return 'Pausa y relájate... ✨';
      default:
        return '';
    }
  }

  // Which view to show
  Widget _getCurrentView() {
    if (_isSessionActive) {
      if (_isConfiguring) return _buildBreathingSessionView();
      if (_isSelectingAudio) return _buildAudioSelectionView();
      if (_isPlaying) return _buildPlayerView();
      return _buildBreathingSessionView();
    }
    if (_isSessionFinished) return _buildFinishedView();
    return _buildSelectionView();
  }

  // Should header be visible
  bool get _showHeader => !_isSessionActive || _isConfiguring || _isSelectingAudio || _isPlaying;

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
          color: const Color(0xFF3B60B3).withOpacity(0.3),
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

                      // --- 1. Durante el día Row ---
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/modulo_respiracion/sol.png',
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
                                  ? 'assets/images/modulo_respiracion/Bactivar_notificacion.png'
                                  : 'assets/images/modulo_respiracion/Bdesactivar_notificacion.png',
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

                      // --- 2. Antes de dormir Row ---
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/modulo_respiracion/luna.png',
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
                                  ? 'assets/images/modulo_respiracion/Bactivar_notificacion.png'
                                  : 'assets/images/modulo_respiracion/Bdesactivar_notificacion.png',
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

  @override
  Widget build(BuildContext context) {
    final bool isNotificationActive = _isDayNotificationEnabled || _isNightNotificationEnabled;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF9F6F0), Color(0xFFFFFDF9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
                        'assets/images/modulo_respiracion/Bcampana.PNG',
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

  // ═══════════════════════════════════════════════════════════════════
  // --- 1. Selection View ---
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSelectionView() {
    return Center(
      key: const ValueKey('selection_view'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF88D49E),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomFadeIn(
                      duration: const Duration(milliseconds: 600),
                      slideUp: false,
                      child: Column(
                        children: [
                          Text(
                            '¡Tomemos una',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3B60B3),
                              height: 1.15,
                            ),
                          ),
                          Text(
                            'pequeña pausa!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF28AF52),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Cada sesión se adapta a tu tiempo disponible.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4C7CC2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTimeButton(
                      imagePath: 'assets/images/modulo_respiracion/B1minuto.png',
                      minutes: 1,
                    ),
                    const SizedBox(height: 10),
                    _buildTimeButton(
                      imagePath: 'assets/images/modulo_respiracion/B3minutos.png',
                      minutes: 3,
                    ),
                    const SizedBox(height: 10),
                    _buildTimeButton(
                      imagePath: 'assets/images/modulo_respiracion/B5minutos.png',
                      minutes: 5,
                    ),

                    if (_selectedTimeOption != null) ...[
                      const SizedBox(height: 24),
                      CustomFadeIn(
                        duration: const Duration(milliseconds: 350),
                        slideUp: true,
                        child: Column(
                          children: [
                            Text(
                              'Hoy elijo dedicarme unos minutos',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4C7CC2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCommitmentCheckbox(),
                            if (_isCommitted) ...[
                              const SizedBox(height: 20),
                              CustomFadeIn(
                                duration: const Duration(milliseconds: 250),
                                slideUp: true,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () => _startBreathingSession(_selectedTimeOption!),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF28AF52),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 1.5,
                                    ),
                                    child: Text(
                                      'Comenzar Meditación',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTimeButtonTap(int minutes) {
    setState(() {
      _selectedTimeOption = minutes;
    });
    if (_isCommitted) {
      _startBreathingSession(minutes);
    }
  }

  Widget _buildTimeButton({required String imagePath, required int minutes}) {
    final bool isSelected = _selectedTimeOption == minutes;
    final bool isAnySelected = _selectedTimeOption != null;
    final double opacity = !isAnySelected || isSelected ? 1.0 : 0.55;

    return BounceableScale(
      onTap: () => _onTimeButtonTap(minutes),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: opacity,
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.088,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCommitmentCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: _wiggleCheckbox
          ? (Matrix4.identity()
            ..translate(5.0 * (DateTime.now().millisecond % 2 == 0 ? 1 : -1)))
          : Matrix4.identity(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _wiggleCheckbox
            ? const Color(0xFFFFF2ED)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isCommitted = !_isCommitted;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 2, right: 12),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _isCommitted ? const Color(0xFF28AF52) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isCommitted
                      ? const Color(0xFF28AF52)
                      : _wiggleCheckbox
                          ? AppColors.primary
                          : const Color(0xFF28AF52),
                  width: 2.2,
                ),
              ),
              child: _isCommitted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isCommitted = !_isCommitted;
                });
              },
              child: Text(
                'Me comprometo a participar activamente en mis sesiones de meditación guiada para apoyar mi bienestar emocional y universitario.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // --- 2. Breathing / Configuring View ---
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBreathingSessionView() {
    final double size = MediaQuery.of(context).size.width * 0.42;

    return Center(
      key: const ValueKey('session_view'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer countdown + close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
                    ],
                  ),
                  child: Text(
                    _formatTime(_secondsRemaining),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _endSession(completed: false),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Guided Breathing visual circle
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _circleScaleAnimation,
                  builder: (context, child) {
                    return Container(
                      width: size * _circleScaleAnimation.value,
                      height: size * _circleScaleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getPhaseColor().withOpacity(0.12),
                        boxShadow: [
                          BoxShadow(
                            color: _getPhaseColor().withOpacity(0.25),
                            blurRadius: 35,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _circleScaleAnimation,
                  builder: (context, child) {
                    return Container(
                      width: size * (_circleScaleAnimation.value * 0.8),
                      height: size * (_circleScaleAnimation.value * 0.8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _getPhaseColor(),
                            _getPhaseColor().withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_phaseSeconds',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),

            CustomFadeIn(
              key: ValueKey(_breathingPhase),
              duration: const Duration(milliseconds: 300),
              slideUp: true,
              child: Text(
                _getPhaseText(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C5CA8),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              _isConfiguring 
                  ? 'Espera un momento mientras se configura...\nMantén los hombros relajados.'
                  : 'Mantén los hombros relajados e inhala por la nariz.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // --- 2b. Audio Selection View (NEW) ---
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAudioSelectionView() {
    return Center(
      key: const ValueKey('audio_selection_view'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              CustomFadeIn(
                duration: const Duration(milliseconds: 500),
                slideUp: false,
                child: Column(
                  children: [
                    const Text('🎧', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Elige tu meditación',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3B60B3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sesión de $_selectedMinutes ${_selectedMinutes == 1 ? 'minuto' : 'minutos'}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF28AF52),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Audio option cards
              ...List.generate(4, (i) {
                final idx = i + 1;
                final colors = [
                  [const Color(0xFF88D49E), const Color(0xFF28AF52)],
                  [const Color(0xFF9BB8ED), const Color(0xFF3B60B3)],
                  [const Color(0xFFE8A0C8), const Color(0xFFE56BB5)],
                  [const Color(0xFFFFCC80), const Color(0xFFFF9800)],
                ];
                final icons = ['🌸', '🌿', '🌙', '✨'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: CustomFadeIn(
                    duration: const Duration(milliseconds: 400),
                    delay: i * 0.12,
                    slideUp: true,
                    child: BounceableScale(
                      onTap: () => _startAudioPlayback(idx),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors[i][0].withOpacity(0.15),
                              colors[i][1].withOpacity(0.08),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors[i][0].withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors[i][0].withOpacity(0.12),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colors[i][1].withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(icons[i], style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Audio $idx',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: colors[i][1],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _audioTitles[i],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2D3142),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.play_circle_fill_rounded,
                              color: colors[i][1],
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              // Back button
              TextButton.icon(
                onPressed: () => _endSession(completed: false),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'Volver al menú',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // --- 2c. Audio Player View (Circular Timer + Particles) ---
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildPlayerView() {
    final screenW = MediaQuery.of(context).size.width;
    final circleSize = screenW * 0.6;
    final progress = _totalAudioDuration > 0
        ? _currentAudioPosition / _totalAudioDuration
        : 0.0;

    return Stack(
      key: const ValueKey('player_view'),
      fit: StackFit.expand,
      children: [
        // ── Dark relaxing background ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // ── Particle background ──
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  animValue: _particleController.value,
                  isPaused: _isAudioPaused,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),

        // ── Player UI ──
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 180),

                // Title
                CustomFadeIn(
                  duration: const Duration(milliseconds: 500),
                  slideUp: false,
                  child: Column(
                    children: [
                      Text(
                        _audioTitles[(_selectedAudioIndex ?? 1) - 1],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white, // Changed to white for dark bg
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sesión de $_selectedMinutes ${_selectedMinutes == 1 ? 'minuto' : 'minutos'}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF88D49E), // Lighter green for dark bg
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Circular progress timer ──
                RepaintBoundary(
                  child: SizedBox(
                    width: circleSize,
                    height: circleSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background arc
                        SizedBox(
                          width: circleSize,
                          height: circleSize,
                          child: CustomPaint(
                            painter: _CircularProgressPainter(
                              progress: progress,
                              trackColor: Colors.white.withOpacity(0.1),
                              progressColor: const Color(0xFF88D49E),
                              strokeWidth: 8,
                            ),
                          ),
                        ),

                        // Progress indicator dot
                        SizedBox(
                          width: circleSize,
                          height: circleSize,
                          child: CustomPaint(
                            painter: _ProgressDotPainter(
                              progress: progress,
                              dotColor: Colors.white,
                              dotSize: 14,
                            ),
                          ),
                        ),

                        // Play/Pause button in center
                        GestureDetector(
                          onTap: _togglePause,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.85),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isAudioPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              size: 36,
                              color: const Color(0xFF2D3142),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Time display + controls ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rewind
                    GestureDetector(
                      onTap: () => _seekRelative(-10),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: const Icon(Icons.replay_10_rounded, size: 22, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Time pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        '${_formatTimeShort(_currentAudioPosition)} - ${_formatTimeShort(_totalAudioDuration)}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Forward
                    GestureDetector(
                      onTap: () => _seekRelative(10),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: const Icon(Icons.forward_10_rounded, size: 22, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Stop button
                TextButton.icon(
                  onPressed: () => _endSession(completed: false),
                  icon: const Icon(Icons.stop_circle_outlined, size: 20),
                  label: Text(
                    'Terminar sesión',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent.shade200,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // --- 3. Finished / Celebration View ---
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildFinishedView() {
    return Center(
      key: const ValueKey('finished_view'),
      child: CustomFadeIn(
        duration: const Duration(milliseconds: 600),
        slideUp: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF88D49E), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🌸',
                  style: TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 20),
                Text(
                  '¡Excelente trabajo!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3B60B3),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Has completado tu sesión de meditación consciente de $_selectedMinutes ${_selectedMinutes == 1 ? 'minuto' : 'minutos'}.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    color: Colors.grey.shade700,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSessionFinished = false;
                        _selectedTimeOption = null;
                        _isCommitted = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28AF52),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Regresar al Menú',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Custom Painters
// ═══════════════════════════════════════════════════════════════════

/// Circular progress arc painter (like the image reference)
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  // Cached Paint objects to avoid GC pressure
  late final Paint _trackPaint;
  late final Paint _progressPaint;

  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  }) {
    _trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    _progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Arc goes from top (270°) sweeping clockwise
    const startAngle = -pi / 2;
    const arcSweep = 2 * pi * 0.78; // ~280° arc (open at bottom)

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      arcSweep,
      false,
      _trackPaint,
    );

    // Progress
    final progressSweep = arcSweep * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      _progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}

/// Dot at the end of the progress arc
class _ProgressDotPainter extends CustomPainter {
  final double progress;
  final Color dotColor;
  final double dotSize;

  // Cached Paint objects
  late final Paint _glowPaint;
  late final Paint _dotPaint;

  _ProgressDotPainter({
    required this.progress,
    required this.dotColor,
    required this.dotSize,
  }) {
    _glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    _dotPaint = Paint()..color = dotColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    const startAngle = -pi / 2;
    const arcSweep = 2 * pi * 0.78;

    final angle = startAngle + arcSweep * progress.clamp(0.0, 1.0);
    final dotCenter = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    // Glow
    canvas.drawCircle(dotCenter, dotSize * 0.8, _glowPaint);

    // Dot
    canvas.drawCircle(dotCenter, dotSize / 2, _dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressDotPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════
// Particle System
// ═══════════════════════════════════════════════════════════════════

class _Particle {
  late double x;
  late double y;
  late double size;
  late double speedY;
  late double opacity;
  late double wobbleSpeed;
  late double wobbleAmplitude;

  _Particle({required Random random}) {
    reset(random, initialPlacement: true);
  }

  void reset(Random random, {bool initialPlacement = false}) {
    x = random.nextDouble();
    y = initialPlacement ? random.nextDouble() : 1.0 + random.nextDouble() * 0.2;
    size = 2.0 + random.nextDouble() * 5.0;
    speedY = 0.0005 + random.nextDouble() * 0.0015;
    opacity = 0.15 + random.nextDouble() * 0.35;
    wobbleSpeed = 0.5 + random.nextDouble() * 2.0;
    wobbleAmplitude = 0.01 + random.nextDouble() * 0.03;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animValue;
  final bool isPaused;
  static final Random _random = Random();

  // Reusable Paint object to avoid allocating per-particle
  final Paint _particlePaint = Paint();

  _ParticlePainter({
    required this.particles,
    required this.animValue,
    required this.isPaused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (!isPaused) {
        p.y -= p.speedY;
        p.x += sin(animValue * pi * 2 * p.wobbleSpeed) * p.wobbleAmplitude * 0.1;
      }

      if (p.y < -0.05) {
        p.reset(_random);
      }

      _particlePaint
        ..color = Colors.white.withOpacity(p.opacity * (isPaused ? 0.4 : 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.5);

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        _particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════════
// Reusable Widgets
// ═══════════════════════════════════════════════════════════════════

class BounceableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BounceableScale({super.key, required this.child, required this.onTap});

  @override
  State<BounceableScale> createState() => _BounceableScaleState();
}

class _BounceableScaleState extends State<BounceableScale> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

class CustomFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double delay;
  final bool slideUp;

  const CustomFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = 0.0,
    this.slideUp = true,
  });

  @override
  State<CustomFadeIn> createState() => _CustomFadeInState();
}

class _CustomFadeInState extends State<CustomFadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: widget.slideUp ? const Offset(0.0, 0.15) : const Offset(0.0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.delay > 0.0) {
      Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
