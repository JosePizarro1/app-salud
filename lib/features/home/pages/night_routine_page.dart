import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_colors.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../services/notification_service.dart';

class NightRoutinePage extends StatefulWidget {
  const NightRoutinePage({super.key});

  @override
  State<NightRoutinePage> createState() => _NightRoutinePageState();
}

class _NightRoutinePageState extends State<NightRoutinePage> {
  // Days of week
  final List<String> _days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  
  // Hours from 7 PM to 7 AM (12 blocks)
  final List<String> _hours = ['19', '20', '21', '22', '23', '00', '01', '02', '03', '04', '05', '06'];

  // Map to store selected hours per day. 
  // Key: day index (0-6). Value: Set of selected hour indices (0-11)
  final Map<int, Set<int>> _selectedHours = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) {
      _selectedHours[i] = {};
    }
    _loadSchedule();
    
    // Show instruction modal on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionDialog();
    });
  }

  void _showInstructionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: AppColors.secondary,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                'Planifica tu Horario',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marca las horas que ocuparás para dormir cada día (de 7 PM a 7 AM).',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• El armar tu rutina diaria te tomará de 5 a 10 minutos.\n• Cumplir tus 8 horas de sueño mejorará tu rendimiento académico y salud.',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '¡Entendido!',
                style: GoogleFonts.outfit(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('night_routine_schedule');
    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      setState(() {
        for (int i = 0; i < 7; i++) {
          final hoursList = decoded[i.toString()] as List<dynamic>?;
          if (hoursList != null) {
            _selectedHours[i] = hoursList.map((e) => e as int).toSet();
          }
        }
      });
    } else {
      // Default: sleep from 10 PM (index 3) to 6 AM (index 11) -> 8 hours
      setState(() {
        for (int i = 0; i < 7; i++) {
          _selectedHours[i] = {3, 4, 5, 6, 7, 8, 9, 10};
        }
      });
    }
  }

  Future<void> _saveSchedule() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    
    // Convert to saveable format
    final Map<String, List<int>> dataToSave = {};
    for (int i = 0; i < 7; i++) {
      dataToSave[i.toString()] = _selectedHours[i]!.toList();
    }
    
    await prefs.setString('night_routine_schedule', jsonEncode(dataToSave));
    
    // Schedule notifications for each day
    final now = DateTime.now();
    // Monday is 1 in DateTime.weekday, so index 0 = Monday
    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      if (_selectedHours[dayIndex]!.isNotEmpty) {
        // Find the earliest sleep hour selected
        final hours = _selectedHours[dayIndex]!.toList()..sort();
        int firstHourIndex = hours.first;
        
        // Convert index (0-11) to actual hour (19-6)
        // 0 -> 19, 1 -> 20, 2 -> 21, 3 -> 22, 4 -> 23, 5 -> 0, 6 -> 1...
        int hour = 19 + firstHourIndex;
        if (hour >= 24) hour -= 24;
        
        await NotificationService().scheduleNightRoutineNotification(
          id: 5000 + dayIndex,
          title: 'Es hora de dormir',
          body: 'Inicia tu rutina nocturna para cumplir tus metas de descanso.',
          hour: hour,
          minute: 0,
        );
      } else {
        // If they clear the day, cancel that notification
        await NotificationService().cancelNotification(5000 + dayIndex);
      }
    }
    
    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final pageContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.success.withOpacity(0.3), width: 1.5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Big beautiful success check icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Rutina Guardada!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tu horario nocturno y recordatorios han sido configurados correctamente.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Dismiss dialog
                    Navigator.pop(pageContext); // Dismiss page
                  },
                  child: Text(
                    'Listo',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleHour(int dayIndex, int hourIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedHours[dayIndex]!.contains(hourIndex)) {
        _selectedHours[dayIndex]!.remove(hourIndex);
      } else {
        _selectedHours[dayIndex]!.add(hourIndex);
      }
    });
  }

  // Calculate average sleep hours
  double _getAverageHours() {
    int total = 0;
    for (int i = 0; i < 7; i++) {
      total += _selectedHours[i]!.length;
    }
    return total / 7.0;
  }

  Map<String, dynamic> _getBenefitsInfo(double avgHours) {
    int hours = avgHours.round();
    
    if (hours >= 8) {
      return {
        'type': 'Beneficios',
        'color': AppColors.success,
        'title': 'Dormir 8+ horas',
        'points': [
          'Reduce el estrés y ansiedad',
          'Mejora la memoria y el aprendizaje',
          'Aumenta la concentración y rendimiento',
          'Mejora el estado de ánimo',
          'Fortalece el sistema inmunológico',
        ]
      };
    } else if (hours == 7) {
      return {
        'type': 'Beneficios',
        'color': AppColors.accent,
        'title': 'Dormir 7 horas',
        'points': [
          'Permite una concentración adecuada',
          'Ayuda a regular el estado emocional',
          'Reduce fatiga moderada',
        ]
      };
    } else if (hours == 6) {
      return {
        'type': 'Beneficios',
        'color': AppColors.warning,
        'title': 'Dormir 6 horas',
        'points': [
          'Facilita el cumplimiento de actividades diarias',
          'Mantiene un nivel básico de descanso',
          'Facilita mantenerse despierto durante el día',
        ]
      };
    } else if (hours >= 3 && hours <= 5) {
      return {
        'type': 'Consecuencias',
        'color': AppColors.primary,
        'title': 'Dormir 3 - 5 horas',
        'points': [
          'Cansancio constante',
          'Dificultad para concentrarse y recordar',
          'Bajo rendimiento académico',
          'Estrés y agotamiento mental',
          'Irritabilidad y mal humor',
        ]
      };
    } else {
      return {
        'type': 'Consecuencias',
        'color': AppColors.error,
        'title': 'Dormir 1 - 2 horas',
        'points': [
          'Bajo rendimiento académico',
          'Cansancio extremo',
          'Falta total de concentración',
          'Debilidad física',
          'Incapacidad para rendir en clases',
        ]
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgHours = _getAverageHours();
    final info = _getBenefitsInfo(avgHours);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo_alarm.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: SafeArea(
              top: true,
              child: Column(
                children: [
                  const SizedBox(height: 45), // Margen superior ajustado para celulares
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Rutina Nocturna',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Header de Horas
                          Row(
                            children: [
                              const SizedBox(width: 40), // Espacio para los dias
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('7P', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54)),
                                    Text('12A', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54)),
                                    Text('7A', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54)),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Grilla
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 7,
                            itemBuilder: (context, dayIndex) {
                              final dayHoursCount = _selectedHours[dayIndex]!.length;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  children: [
                                    // Dia y Cantidad de horas
                                    SizedBox(
                                      width: 48,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _days[dayIndex].substring(0, 3),
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '${dayHoursCount} hrs',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              color: dayHoursCount >= 8
                                                  ? AppColors.success
                                                  : (dayHoursCount >= 6
                                                      ? AppColors.warning
                                                      : AppColors.error),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // Bloques de hora (Estilo Track Continuo)
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          height: 34,
                                          color: Colors.white.withOpacity(0.06), // Track
                                          child: Row(
                                            children: List.generate(12, (hourIndex) {
                                              final isSelected = _selectedHours[dayIndex]!.contains(hourIndex);
                                              final isPrevSelected = hourIndex > 0 && _selectedHours[dayIndex]!.contains(hourIndex - 1);
                                              final isNextSelected = hourIndex < 11 && _selectedHours[dayIndex]!.contains(hourIndex + 1);

                                              BorderRadius borderRadius = BorderRadius.zero;
                                              if (isSelected) {
                                                if (!isPrevSelected && !isNextSelected) {
                                                  borderRadius = BorderRadius.circular(6);
                                                } else if (!isPrevSelected && isNextSelected) {
                                                  borderRadius = const BorderRadius.only(
                                                    topLeft: Radius.circular(6),
                                                    bottomLeft: Radius.circular(6),
                                                  );
                                                } else if (isPrevSelected && !isNextSelected) {
                                                  borderRadius = const BorderRadius.only(
                                                    topRight: Radius.circular(6),
                                                    bottomRight: Radius.circular(6),
                                                  );
                                                }
                                              }

                                              return Expanded(
                                                child: GestureDetector(
                                                  onTap: () => _toggleHour(dayIndex, hourIndex),
                                                  child: Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 0.5),
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? AppColors.secondary : Colors.transparent,
                                                      borderRadius: borderRadius,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 32),

                          // Tarjeta de beneficios/consecuencias
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: (info['color'] as Color).withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      info['type'] == 'Beneficios' ? Icons.check_circle_rounded : Icons.warning_rounded,
                                      color: info['color'],
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${info['type']}: ${info['title']}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: info['color'],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Progress Indicator for Sleep Goal (8 hours)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (avgHours / 8.0).clamp(0.0, 1.0),
                                          backgroundColor: Colors.white.withOpacity(0.1),
                                          valueColor: AlwaysStoppedAnimation<Color>(info['color']),
                                          minHeight: 8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${avgHours.toStringAsFixed(1)}h / 8h',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...((info['points'] as List<String>).map((point) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.star_rate_rounded, color: info['color'].withOpacity(0.7), size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            point,
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Guardar Boton
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _saveSchedule,
                              child: Text(
                                'Guardar horario nocturno',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
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
