import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/theme/app_colors.dart';
import '../../home/widgets/module_header.dart';

class OrganizerOnboardingPage extends StatefulWidget {
  const OrganizerOnboardingPage({super.key});

  @override
  State<OrganizerOnboardingPage> createState() => _OrganizerOnboardingPageState();
}

class _OrganizerOnboardingPageState extends State<OrganizerOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.bgDark : const Color(0xFFFAF9F6); // Soft premium white

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 130), // Spacing to avoid overlap with ModuleHeader

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildScheduleOnboarding(isDark),
                  _buildEisenhowerOnboarding(isDark),
                ],
              ),
            ),

            // Page Indicator & Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      2,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        // Finish and return
                        context.pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == 1 ? '¡Comenzar!' : 'Siguiente',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Shared Header (Home + Emergency)
      const ModuleHeader(showHome: true),
    ],
  ),
);
  }

  Widget _buildScheduleOnboarding(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          // Bubbled title
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6F1), // Soft green
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿CÓMO USAR',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E523A),
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'TU HORARIO PERSONAL?',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E523A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/gato1.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => const Text('🐱', style: TextStyle(fontSize: 48)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Intro card
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Text(
                'Un horario personal es una herramienta que te ayuda a organizar tu tiempo para cumplir tus actividades sin estrés.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : const Color(0xFF4A4D55),
                  height: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Steps
          _buildStepRow(
            number: '1',
            title: 'DEFINE TUS ACTIVIDADES',
            desc: 'Anota todo lo que haces en el día: clases, estudio, descanso, comidas, ejercicio, etc.',
            color: const Color(0xFFE8F6F1), // Green
            textColor: const Color(0xFF1E523A),
            icon: '📝',
            delay: 150,
          ),
          _buildStepRow(
            number: '2',
            title: 'ASIGNA TIEMPOS REALES',
            desc: 'Coloca cada actividad en un horario específico. Sé realista (no todo es estudio, también necesitas descansar).',
            color: const Color(0xFFFFF7E6), // Yellow
            textColor: const Color(0xFF8A6200),
            icon: '⏰',
            delay: 200,
          ),
          _buildStepRow(
            number: '3',
            title: 'PRIORIZA LO IMPORTANTE',
            desc: 'Haz primero las tareas más urgentes o difíciles cuando tengas más energía.',
            color: const Color(0xFFFFECEF), // Pink/Red
            textColor: const Color(0xFF9E2A3B),
            icon: '⭐',
            delay: 250,
          ),
          _buildStepRow(
            number: '4',
            title: 'RESPETA TU HORARIO',
            desc: 'Intenta cumplirlo, pero sé flexible si surge algo inesperado.',
            color: const Color(0xFFE6F0FF), // Blue
            textColor: const Color(0xFF1F4A85),
            icon: '📅',
            delay: 300,
          ),
          _buildStepRow(
            number: '5',
            title: 'EVALÚA Y AJUSTA',
            desc: 'Al final del día o semana, revisa si te funcionó y haz cambios si es necesario.',
            color: const Color(0xFFF3EDFF), // Purple
            textColor: const Color(0xFF532E91),
            icon: '📈',
            delay: 350,
          ),

          const SizedBox(height: 16),

          // Consejo Box
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6F1), // Greenish
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA7E6D7), width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONSEJO:',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF1E523A),
                          ),
                        ),
                        Text(
                          'Un buen horario no es el más lleno, sino el que puedes cumplir.',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: const Color(0xFF1E523A),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/gato2.png',
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required String title,
    required String desc,
    required Color color,
    required Color textColor,
    required String icon,
    required int delay,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$number. $title',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEisenhowerOnboarding(bool isDark) {
    final quadrants = [
      {
        'title': 'Urgente e Importante',
        'subtitle': '¡Hazlo ya!',
        'desc': 'Tareas críticas que no pueden esperar.',
        'color': const Color(0xFFFFECEF),
        'borderColor': const Color(0xFFFFD1D6),
        'textColor': const Color(0xFF9E2A3B),
        'icon': Icons.notification_important_rounded,
      },
      {
        'title': 'Importante, no Urgente',
        'subtitle': 'Planifícalo',
        'desc': 'Prográmalo en tu calendario.',
        'color': const Color(0xFFE8F6F1),
        'borderColor': const Color(0xFFC7F0E4),
        'textColor': const Color(0xFF1E523A),
        'icon': Icons.calendar_month_rounded,
      },
      {
        'title': 'Urgente, no Importante',
        'subtitle': 'Delégalo',
        'desc': 'Pide ayuda o resuélvelo rápido.',
        'color': const Color(0xFFE6F0FF),
        'borderColor': const Color(0xFFCCE0FF),
        'textColor': const Color(0xFF1F4A85),
        'icon': Icons.people_alt_rounded,
      },
      {
        'title': 'No Urgente ni Importante',
        'subtitle': 'Posponlo / Descarto',
        'desc': 'Déjalo para el final.',
        'color': const Color(0xFFF3EDFF),
        'borderColor': const Color(0xFFE2D6FF),
        'textColor': const Color(0xFF532E91),
        'icon': Icons.delete_outline_rounded,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          // Mascot explainer
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEFB), // Soft purple
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/gato2.png',
                    height: 60,
                    errorBuilder: (context, error, stackTrace) => const Text('🐱', style: TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Titi te explica 💜',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4F3A8A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'La matriz divide tus tareas en 4 partes para organizarte sin estrés.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF4F3A8A),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quadrants List: one below the other, compact.
          ...List.generate(4, (index) {
            final q = quadrants[index];
            final Color color = q['color'] as Color;
            final Color borderColor = q['borderColor'] as Color;
            final Color textColor = q['textColor'] as Color;
            final IconData icon = q['icon'] as IconData;

            return FadeInUp(
              delay: Duration(milliseconds: 100 + (index * 50)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    // Quadrant Number Badge / Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: textColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Quadrant Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${index + 1}. ',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  q['title'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Subtitle Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: textColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  (q['subtitle'] as String).toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            q['desc'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.8),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 14),

          // Thumbs up banner
          FadeInUp(
            delay: const Duration(milliseconds: 350),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👍', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '¡Así podrás organizar mejor tu tiempo cada día!',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4F3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
