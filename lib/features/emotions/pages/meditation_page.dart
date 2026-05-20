import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Breathing Session State
  bool _isSessionActive = false;
  bool _isSessionFinished = false;
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

  // Notification Configuration State
  bool _isDayNotificationEnabled = false;
  int _dayHour = 7;
  int _dayMinute = 0;
  String _dayPeriod = 'AM';

  bool _isNightNotificationEnabled = false;
  int _nightHour = 7;
  int _nightMinute = 0;
  String _nightPeriod = 'PM';

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
    _loadNotificationSettings();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();
    _circleAnimController.dispose();
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

  // Starts the interactive guided breathing session
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

    // Prevent timer multiplication by cancelling any existing active timers before launching a new session
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();

    setState(() {
      _selectedMinutes = minutes;
      _secondsRemaining = minutes * 60;
      _isSessionActive = true;
      _isSessionFinished = false;
      _breathingPhase = 'inhale';
      _phaseSeconds = 4;
    });

    _circleAnimController.reset(); // Reset animation scale back to standard before starting
    _circleAnimController.forward();

    // 1. Overall session countdown timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _endSession(completed: true);
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
        // Keep circle expanded
      } else if (_breathingPhase == 'hold') {
        _breathingPhase = 'exhale';
        _circleAnimController.reverse();
      } else if (_breathingPhase == 'exhale') {
        _breathingPhase = 'hold_empty';
        // Keep circle contracted
      } else {
        _breathingPhase = 'inhale';
        _circleAnimController.forward();
      }
    });
  }

  void _endSession({required bool completed}) {
    _sessionTimer?.cancel();
    _breathingTimer?.cancel();
    _circleAnimController.stop();
    _circleAnimController.reset(); // Safely shrink the visual scale back to standard on exit

    setState(() {
      _isSessionActive = false;
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

  Color _getPhaseColor() {
    switch (_breathingPhase) {
      case 'inhale':
        return AppColors.accent; // Mint/Fresh
      case 'hold':
        return AppColors.secondary; // Lavender/Calm
      case 'exhale':
        return AppColors.primary; // Coral/Release
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
        color: const Color(0xFFE2E7FF), // Lavender tint
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
            // Auto-select all text on tap to easily replace the entire value
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
          // AM
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque, // Ensures the entire rectangular half is fully tap-sensitive
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
          // PM
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque, // Ensures the entire rectangular half is fully tap-sensitive
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
    // Load local variables from state
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
                      // Top indicator line
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
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

                      // Subtitle
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

                      // Time Input Row for Day
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

                      // Time Input Row for Night
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

                            // Intelligently default and only validate time configuration for ENABLED reminders
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

                            // Save to local SharedPreferences cache
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('meditation_day_enabled', localDayEnabled);
                            await prefs.setInt('meditation_day_hour', finalDHour);
                            await prefs.setInt('meditation_day_minute', finalDMin);
                            await prefs.setString('meditation_day_period', localDayPeriod);

                            await prefs.setBool('meditation_night_enabled', localNightEnabled);
                            await prefs.setInt('meditation_night_hour', finalNHour);
                            await prefs.setInt('meditation_night_minute', finalNMin);
                            await prefs.setString('meditation_night_period', localNightPeriod);

                            debugPrint('💾 [MeditationPage] Guardando configuración de rutina en SharedPreferences:');
                            debugPrint('   ☀️ Día habilitado: $localDayEnabled ($finalDHour:$finalDMin $localDayPeriod)');
                            debugPrint('   🌙 Noche habilitada: $localNightEnabled ($finalNHour:$finalNMin $localNightPeriod)');

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

                            // Schedule night notification
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

                            // Reload main state settings
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
          // Background soft tinted wall
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
              child: _isSessionActive
                  ? _buildBreathingSessionView()
                  : _isSessionFinished
                      ? _buildFinishedView()
                      : _buildSelectionView(),
            ),
          ),

          // Shared Header with Home Button (only visible if not active in breathing)
          // Placed last in stack to ensure touch events are successfully processed and not blocked by SafeArea
          if (!_isSessionActive) ...[
            const ModuleHeader(showHome: true),

            // Notification Routine Trigger Bell Button in Header
            Positioned(
              right: MediaQuery.of(context).size.width * 0.24, // Placed beautifully next to the Emergency Button
              top: MediaQuery.of(context).size.height * 0.095, // Perfectly aligned horizontally
              child: BounceableScale(
                onTap: _showRoutineModal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.20,
                  height: MediaQuery.of(context).size.width * 0.095,
                  child: Image.asset(
                    isNotificationActive
                        ? 'assets/images/modulo_respiracion/Bactivar_notificacion.png'
                        : 'assets/images/modulo_respiracion/Bdesactivar_notificacion.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- 1. Selection View (Matching attached image) ---
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
              // Main content card with thin green/mint border
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF88D49E), // Light green border
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
                    // Title "¡Tomemos una pequeña pausa!"
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
                              color: const Color(0xFF3B60B3), // Navy blue tint
                              height: 1.15,
                            ),
                          ),
                          Text(
                            'pequeña pausa!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF28AF52), // Gorgeous green tint
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Cada sesión se adapta a tu tiempo disponible.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4C7CC2), // Indigo subtitle color
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1 Minuto Button
                    _buildTimeButton(
                      imagePath: 'assets/images/modulo_respiracion/B1minuto.png',
                      minutes: 1,
                    ),
                    const SizedBox(height: 10),

                    // 3 Minutos Button
                    _buildTimeButton(
                      imagePath: 'assets/images/modulo_respiracion/B3minutos.png',
                      minutes: 3,
                    ),
                    const SizedBox(height: 10),

                    // 5 Minutos Button
                    _buildTimeButton(
                      imagePath: 'assets/images/modulo_respiracion/B5minutos.png',
                      minutes: 5,
                    ),

                    // Commitment elements will ONLY show once a time option is selected
                    if (_selectedTimeOption != null) ...[
                      const SizedBox(height: 24),
                      CustomFadeIn(
                        duration: const Duration(milliseconds: 350),
                        slideUp: true,
                        child: Column(
                          children: [
                            // Today Choice Text
                            Text(
                              'Hoy elijo dedicarme unos minutos',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4C7CC2), // Light Indigo accent
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Commitment Checkbox
                            _buildCommitmentCheckbox(),

                            // Beautiful primary call-to-action button showing when committed
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
          height: MediaQuery.of(context).size.height * 0.088, // 8.8% screen height prevents cutting the outline borders!
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover, // Auto-crops the transparent vertical margins!
            alignment: Alignment.center, // Keeps the actual button graphic centered
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
            ? const Color(0xFFFFF2ED) // Slight reddish flash for attention
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Beautiful custom checkbox
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
                          : const Color(0xFF28AF52), // Matching the green checkbox style
                  width: 2.2,
                ),
              ),
              child: _isCommitted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          
          // Commitment Text
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

  // --- 2. Breathing guided exercise view (Box breathing technique) ---
  Widget _buildBreathingSessionView() {
    final double size = MediaQuery.of(context).size.width * 0.42;

    return Center(
      key: const ValueKey('session_view'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer countdown + phase indicator
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
                // Glowing outer pulse ring
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

                // Core expanding animated lung/circle
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

            // Dynamic phase guiding text
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

            // Tip description
            Text(
              'Mantén los hombros relajados e inhala por la nariz.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // --- 3. Finished / Celebration View ---
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

// Custom simple helper for scale dynamic taps
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

// Highly optimized, print-free custom FadeIn transition with smooth SlideTransition
class CustomFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double delay;
  final bool slideUp; // true for SlideUp, false for SlideDown

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
