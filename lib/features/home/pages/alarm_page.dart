// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../services/notification_service.dart';
import '../../organizer/services/organizer_task_storage.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  // ── Sleep Alarm State ──
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 0);
  bool _isSleepAlarmActive = false;

  // ── Rest Reminders List State ──
  List<Map<String, dynamic>> _restReminders = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load schedule and reminders from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Sleep Alarm
    final bedHour = prefs.getInt('sleep_bed_hour') ?? 22;
    final bedMinute = prefs.getInt('sleep_bed_minute') ?? 0;
    final wakeHour = prefs.getInt('sleep_wake_hour') ?? 6;
    final wakeMinute = prefs.getInt('sleep_wake_minute') ?? 0;
    
    setState(() {
      _bedTime = TimeOfDay(hour: bedHour, minute: bedMinute);
      _wakeTime = TimeOfDay(hour: wakeHour, minute: wakeMinute);
      _isSleepAlarmActive = prefs.getBool('sleep_alarm_active') ?? false;

      // Load Rest Reminders
      final String? remindersJson = prefs.getString('rest_reminders');
      if (remindersJson != null) {
        final List<dynamic> decoded = jsonDecode(remindersJson);
        _restReminders = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    });
  }

  // Save Sleep Alarm settings
  Future<void> _saveSleepAlarmSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sleep_bed_hour', _bedTime.hour);
    await prefs.setInt('sleep_bed_minute', _bedTime.minute);
    await prefs.setInt('sleep_wake_hour', _wakeTime.hour);
    await prefs.setInt('sleep_wake_minute', _wakeTime.minute);
    await prefs.setBool('sleep_alarm_active', _isSleepAlarmActive);

    // Sync sleep wake alarm with native notification system
    const int alarmId = 7777; // Constant ID for Wake-up Alarm
    if (_isSleepAlarmActive) {
      await NotificationService().scheduleDailyNotification(
        id: alarmId,
        title: '¡Buenos días! Es hora de despertar',
        body: 'Espero que hayas tenido un descanso reparador.',
        hour: _wakeTime.hour,
        minute: _wakeTime.minute,
      );
    } else {
      await NotificationService().cancelNotification(alarmId);
    }
  }

  // Save Rest Reminders list & Sync notifications
  Future<void> _saveRestReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rest_reminders', jsonEncode(_restReminders));

    // Cancel all previous rest reminder notifications to avoid duplicates
    for (int i = 0; i < 20; i++) {
      await NotificationService().cancelNotification(1000 + i);
    }

    // Schedule active reminders
    for (int i = 0; i < _restReminders.length; i++) {
      final reminder = _restReminders[i];
      if (reminder['isActive'] == true) {
        final parts = (reminder['time'] as String).split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        await NotificationService().scheduleRestReminder(
          id: 1000 + i,
          title: 'Tómate un descanso',
          body: 'Es hora de tomar un descanso. Desconéctate por unos minutos.',
          hour: hour,
          minute: minute,
        );

        // Auto-register task in Organizer database for today
        _registerRestTaskInDb(reminder['time']);
      }
    }
  }

  // Register rest reminder as an incomplete task in the Organizer Tasks table
  Future<void> _registerRestTaskInDb(String timeStr) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    try {
      // Check if task already exists for today to avoid duplicates
      final existing = await OrganizerTaskStorage.getTasksForDate(todayStr);
      final hasTask = existing.any((task) => task['title'] == 'Descanso de 30 minutos' && task['task_time'] == timeStr);
      
      if (!hasTask) {
        await OrganizerTaskStorage.addTask(
          dateStr: todayStr,
          title: 'Descanso de 30 minutos',
          timeStr: timeStr,
          dimension: 3, // Dimension 3: Important / Not Urgent (Wellness tasks)
          notes: 'Recordatorio programado desde el apartado Alarma y Descanso.',
        );
      }
    } catch (e) {
      debugPrint('Error registering task in database: $e');
    }
  }

  // Add a new rest reminder
  void _addNewRestReminder(TimeOfDay time) {
    final String timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    // Avoid duplicate times
    if (_restReminders.any((r) => r['time'] == timeStr)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe un descanso programado a esa hora.')),
      );
      return;
    }

    _showRecommendationsBottomSheet(timeStr);
  }

  // Toggle active state of a rest reminder
  void _toggleRestReminder(int index, bool value) {
    HapticFeedback.lightImpact();
    setState(() {
      _restReminders[index]['isActive'] = value;
    });
    _saveRestReminders();
  }

  // Delete a rest reminder
  void _deleteRestReminder(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _restReminders.removeAt(index);
    });
    _saveRestReminders();
  }

  // Select bedtime/wake time
  Future<void> _selectSleepTime(bool isBedtime) async {
    HapticFeedback.lightImpact();
    final initialTime = isBedtime ? _bedTime : _wakeTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isBedtime ? 'HORA DE ACOSTARSE' : 'HORA DE DESPERTAR',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
      _saveSleepAlarmSettings();
    }
  }

  // Open Time Picker for new rest reminder
  Future<void> _pickRestTime() async {
    HapticFeedback.mediumImpact();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
      helpText: 'HORA DE DESCANSO',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _addNewRestReminder(picked);
    }
  }

  // Bottom Sheet presenting Wellness Recommendations & Save confirmation
  void _showRecommendationsBottomSheet(String timeStr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1326),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recomendaciones de Descanso',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Text(
                'Tómate un descanso diario a las $timeStr. Aprovechá esos 30 minutos para realizar actividades que te ayuden a desconectarte:',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Recommendation Card 1: Read
              _buildRecommendationTile(
                icon: Icons.menu_book_rounded,
                title: 'Lectura motivacional',
                desc: 'Leé textos motivacionales o de crecimiento personal que te ayuden a generar bienestar emocional.',
                iconColor: AppColors.secondary,
              ),
              const SizedBox(height: 16),

              // Recommendation Card 2: Yoga/Breathing
              _buildRecommendationTile(
                icon: Icons.spa_rounded,
                title: 'Yoga y Respiración profunda',
                desc: 'Practicá yoga o ejercicios de respiración profunda para reducir el nivel de estrés y relajar tu cuerpo.',
                iconColor: AppColors.accent,
              ),
              const SizedBox(height: 16),

              // Recommendation Card 3: Screen disconnection
              _buildRecommendationTile(
                icon: Icons.phonelink_erase_rounded,
                title: 'Desconexión digital',
                desc: 'Apagá la pantalla de tu celular o computadora. Estirá las piernas y dejá descansar tu mente.',
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 32),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _restReminders.add({
                        'time': timeStr,
                        'isActive': true,
                      });
                    });
                    _saveRestReminders();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Guardar notificación de descanso',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendationTile({
    required IconData icon,
    required String title,
    required String desc,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.55),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo_alarm.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3), // Darken background slightly
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // Blur background
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20), // Top margin for mobile notch

              // Custom Header: Back button only on left
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // Title and Sleeping Cat Header Row
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rutina de',
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Sueño',
                                  style: GoogleFonts.outfit(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Configurá tus alarmas\ny descansos saludables',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.5),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Cozy Sleeping Cat Header Image
                          Container(
                            width: 130,
                            height: 130,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/titi zzz.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 36),

                      // 1. HORARIO DE SUEÑO
                      Text(
                        'Horario de Sueño',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sleep Time Picker Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Bedtime Time Picker Button
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectSleepTime(true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.15),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.bedtime_rounded, color: AppColors.secondary, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Acostarse',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  color: Colors.white.withOpacity(0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _bedTime.format(context),
                                            style: GoogleFonts.outfit(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Wake-up Time Picker Button
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectSleepTime(false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.15),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.wb_sunny_rounded, color: AppColors.primary, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Despertar',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  color: Colors.white.withOpacity(0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _wakeTime.format(context),
                                            style: GoogleFonts.outfit(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Sleep alarm toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Alarma para despertar',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Sona diaria a tu hora de despertar',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _isSleepAlarmActive,
                                  activeColor: AppColors.accent,
                                  activeTrackColor: AppColors.accent.withOpacity(0.3),
                                  inactiveThumbColor: Colors.white.withOpacity(0.6),
                                  inactiveTrackColor: Colors.white.withOpacity(0.08),
                                  onChanged: (bool value) {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _isSleepAlarmActive = value;
                                    });
                                    _saveSleepAlarmSettings();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 2. TOMATE UN DESCANSO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tómate un descanso',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          // Plus Button to program a break
                          GestureDetector(
                            onTap: _pickRestTime,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent.withOpacity(0.12),
                              ),
                              child: const Icon(Icons.add_rounded, color: AppColors.accent, size: 22),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List of Rest Reminders
                      if (_restReminders.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.notifications_none_rounded, color: Colors.white.withOpacity(0.2), size: 36),
                              const SizedBox(height: 12),
                              Text(
                                'No tenés descansos programados',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _restReminders.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final reminder = _restReminders[index];
                            final timeStr = reminder['time'] as String;
                            final isActive = reminder['isActive'] as bool? ?? false;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.secondary.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Time
                                  Text(
                                    timeStr,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Recordatorio diario',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isActive ? Colors.white70 : Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                        Text(
                                          'Descanso de 30 mins',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Active toggle switch
                                  Switch(
                                    value: isActive,
                                    activeColor: AppColors.secondary,
                                    activeTrackColor: AppColors.secondary.withOpacity(0.3),
                                    inactiveThumbColor: Colors.white.withOpacity(0.6),
                                    inactiveTrackColor: Colors.white.withOpacity(0.08),
                                    onChanged: (bool val) => _toggleRestReminder(index, val),
                                  ),

                                  const SizedBox(width: 8),

                                  // Delete button
                                  GestureDetector(
                                    onTap: () => _deleteRestReminder(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.04),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red.withOpacity(0.7),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 50), // Spaced bottom margin for mobile
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}
