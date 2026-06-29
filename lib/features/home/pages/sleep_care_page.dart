import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import 'package:animate_do/animate_do.dart';

class SleepCarePage extends StatefulWidget {
  const SleepCarePage({super.key});

  @override
  State<SleepCarePage> createState() => _SleepCarePageState();
}

class _SleepCarePageState extends State<SleepCarePage> {
  final List<Map<String, dynamic>> _chapters = [
    {
      'title': '1. ¿Qué es el cuidado del sueño?',
      'icon': Icons.nights_stay_rounded,
      'iconColor': Color(0xFFFDE047),
      'bgColor': Color(0xFF1E1E38),
    },
    {
      'title': '2. ¿Qué beneficios brinda cuidar nuestro sueño?',
      'icon': Icons.favorite_rounded,
      'iconColor': Colors.white,
      'bgColor': Color(0xFFEF4444),
    },
    {
      'title': '3. ¿Qué incluye el cuidado del sueño?',
      'icon': Icons.assignment_rounded,
      'iconColor': Colors.white,
      'bgColor': Color(0xFFF59E0B),
    },
    {
      'title': '4. ¿Qué pasa si no cuido mi sueño?',
      'icon': Icons.warning_rounded,
      'iconColor': Colors.white,
      'bgColor': Color(0xFFF97316),
    },
    {
      'title': '5. Entonces... ¿cuánto tiempo debo dormir?',
      'icon': Icons.watch_later_rounded,
      'iconColor': Colors.white,
      'bgColor': Color(0xFF8B5CF6),
    },
    {
      'title': '6. Ayúdame... ¿qué puedo hacer?',
      'icon': Icons.help_outline_rounded,
      'iconColor': Colors.white,
      'bgColor': Color(0xFF3B82F6),
    },
    {
      'title': '7. Ayúdame... ¿qué puedo hacer? (Respuesta)',
      'icon': Icons.verified_user_rounded,
      'iconColor': Colors.white,
      'bgColor': Color(0xFF10B981),
    },
  ];

  Set<int> _completedChapters = {};
  double _progressPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList('sleep_care_progress');
    if (list != null) {
      setState(() {
        _completedChapters = list.map((e) => int.parse(e)).toSet();
        _progressPercentage = (_completedChapters.length / _chapters.length) * 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF0A0E1A), // Dark navy
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: true,
          child: Column(
            children: [
              const SizedBox(height: 45), // Margen superior respetado para celulares
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 500),
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
                              'Cuidado del Sueño',
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
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress Bar
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 100),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131927), // Fondo sólido
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF1E293B)), // Borde sólido
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 54,
                                        height: 54,
                                        child: CircularProgressIndicator(
                                          value: _progressPercentage / 100,
                                          backgroundColor: Colors.white.withOpacity(0.1),
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                                          strokeWidth: 5,
                                        ),
                                      ),
                                      Text(
                                        '${_progressPercentage.round()}%',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tu progreso',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _progressPercentage >= 100 
                                              ? '¡Lectura completada!' 
                                              : 'Excelente trabajo, ¡sigue así!',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            color: Colors.white.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
  
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              'A. Lectura de cuidado del sueño',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Chapters List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _chapters.length,
                            itemBuilder: (context, index) {
                              final chapter = _chapters[index];
                              final isCompleted = _completedChapters.contains(index);

                              return FadeInLeft(
                                duration: const Duration(milliseconds: 400),
                                delay: Duration(milliseconds: 80 * index + 150),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                  onTap: () async {
                                    // Navigate to Reader
                                    await context.push('/sleep_care/reader', extra: index);
                                    _loadProgress(); // Reload progress when coming back
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF131927), // Fondo sólido
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF1E293B), // Borde sólido
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Left Icon
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: chapter['bgColor'],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            chapter['icon'],
                                            color: chapter['iconColor'],
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        
                                        // Title
                                        Expanded(
                                          child: Text(
                                            chapter['title'],
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ),
                                        
                                        // Right Arrow
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white.withOpacity(0.4),
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                          const SizedBox(height: 24),

                          // Bottom banner
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 700),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131927), // Fondo sólido
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/images/titi zzz.png',
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '¡Sigue aprendiendo!',
                                          style: GoogleFonts.outfit(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Cada pequeño cambio mejora tu descanso.',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
        );
      }
    }
