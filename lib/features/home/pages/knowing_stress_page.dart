import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/module_header.dart';

class KnowingStressPage extends StatefulWidget {
  const KnowingStressPage({super.key});

  @override
  State<KnowingStressPage> createState() => _KnowingStressPageState();
}

class _KnowingStressPageState extends State<KnowingStressPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // States for Page 2 (Manifestations)
  int _activeManifestation = -1;

  // States for Page 4 (Strategies Checklist)
  final List<bool> _checkedStrategies = [false, false, false];

  // States for Page 5 (Breathing Timer)
  bool _isBreathing = false;
  String _breathingText = "Presiona para iniciar";
  int _breathingCountdown = 4;
  int _selectedTechnique = 0; // 0: Respiración, 1: Relajación, 2: Mindfulness

  // States for Page 6 (Sequential checks)
  bool _showCheck1 = false;
  bool _showCheck2 = false;
  bool _showCheck3 = false;

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _startBreathingExercise() async {
    if (_isBreathing) return;
    setState(() {
      _isBreathing = true;
      _breathingText = "¡Inhala!";
      _breathingCountdown = 4;
    });
    _playSound('audio/success_cheerful.mp3'); // soft start cue

    // Inhale 4s
    for (int i = 4; i > 0; i--) {
      if (!mounted) return;
      setState(() => _breathingCountdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    // Exhale 4s
    if (!mounted) return;
    setState(() {
      _breathingText = "¡Exhala lentamente!";
      _breathingCountdown = 4;
    });

    for (int i = 4; i > 0; i--) {
      if (!mounted) return;
      setState(() => _breathingCountdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;
    setState(() {
      _isBreathing = false;
      _breathingText = "¡Excelente! ¿Hacemos otro?";
    });
  }

  void _startSequentialChecks() {
    setState(() {
      _showCheck1 = false;
      _showCheck2 = false;
      _showCheck3 = false;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showCheck1 = true);
        _playSound('images/healthy_eating/sonido_noti_entrada.mp3');
      }
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _showCheck2 = true);
        _playSound('images/healthy_eating/sonido_noti_entrada.mp3');
      }
    });

    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) {
        setState(() => _showCheck3 = true);
        _playSound('images/healthy_eating/sonido_noti_entrada.mp3');
      }
    });
  }

  Widget _buildTopProgressBar() {
    if (_currentPage < 1 || _currentPage > 4) return const SizedBox(width: 128);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index <= (_currentPage - 1);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 28,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF8A71) : const Color(0xFFFFECE5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // Slide 1: Welcome / What is stress
  Widget _buildSlide1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Conociendo el Estrés',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '¿QUÉ ES EL ESTRÉS?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Image.asset(
              'assets/images/healthy_eating/gifs/titi pensativo (1).gif',
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.psychology,
                size: 150,
                color: Color(0xFF5C6BC0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 150),
            child: Container(
              padding: const EdgeInsets.all(22),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Es la respuesta natural de tu organismo ante demandas físicas o psicológicas que superan tus recursos cotidianos.\n\nEsta reacción activa mecanismos de adaptación que te permiten responder rápidamente a los desafíos.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  color: Colors.black87,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2: Manifestations
  Widget _buildSlide2() {
    final nivelImages = [
      'assets/images/Modulo6/nivel_fisico.png',
      'assets/images/Modulo6/nivel_psicologico.png',
      'assets/images/Modulo6/nivel_conductual.png',
    ];
    final nivelDetails = [
      '• Fatiga constante\n• Tensión muscular en cuello y hombros\n• Problemas digestivos\n• Alteraciones del sueño (insomnio)',
      '• Ansiedad y preocupación excesiva\n• Irritabilidad o cambios de humor\n• Dificultad para concentrarse en clases',
      '• Cambios drásticos en hábitos alimenticios\n• Aislamiento social o pocas ganas de hablar\n• Disminución del rendimiento académico',
    ];
    final nivelDetailColors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFEDE7F6),
      const Color(0xFFFFF8E1),
    ];
    final nivelTextColors = [
      const Color(0xFF1565C0),
      const Color(0xFF4527A0),
      const Color(0xFFE65100),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'MANIFESTACIONES',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'El estrés se presenta en tres niveles principales. Presiona cada uno para conocer sus síntomas:',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(3, (index) {
            final isActive = _activeManifestation == index;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: Column(
                children: [
                  // Image button — FittedBox + clamp to crop whitespace
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _activeManifestation = isActive ? -1 : index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: nivelTextColors[index].withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.07),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SizedBox(
                          height: 95,
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            // Center-crop: images have ~25% transparent padding on each side vertically
                            alignment: Alignment.center,
                            child: Image.asset(
                              nivelImages[index],
                              fit: BoxFit.fitWidth,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Expandable details panel
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: isActive
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: nivelDetailColors[index],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: nivelTextColors[index].withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        nivelDetails[index],
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 14),
          Image.asset(
            'assets/images/healthy_eating/images/titi lentes.png',
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  // Slide 3: Consequences vs Benefits
  Widget _buildSlide3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'CONSECUENCIAS Y BENEFICIOS',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828), size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estrés Prolongado (Distrés)',
                          style: GoogleFonts.outfit(
                            fontSize: 17.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC62828),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mantener el estrés por periodos muy prolongados puede desgastar tus defensas y afectar negativamente tu salud física y mental.',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.wb_sunny_rounded, color: Color(0xFF2E7D32), size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estrés Manejado (Eustrés)',
                          style: GoogleFonts.outfit(
                            fontSize: 17.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Un manejo adecuado convierte el estrés en motivación positiva que mejora tu enfoque, tu capacidad de resolver exámenes y tu superación de desafíos.',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/healthy_eating/images/titi patita.png',
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  // Slide 4: Strategies (Checklist)
  Widget _buildSlide4() {
    final strategies = [
      {
        'title': '1. Identificación',
        'desc': 'Reconocer los síntomas y las situaciones estresantes antes de que escalen.'
      },
      {
        'title': '2. Reorganización',
        'desc': 'Ajustar pensamientos exagerados o negativos y planificar con más realismo.'
      },
      {
        'title': '3. Técnicas Prácticas',
        'desc': 'Implementar respiración guiada, pausas y dividir tus tareas universitarias en partes.'
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'ESTRATEGIAS DE GESTIÓN',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Completa los tres pasos fundamentales para mantener a Titi en calma:',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ...List.generate(3, (index) {
              final isChecked = _checkedStrategies[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _checkedStrategies[index] = !isChecked;
                    });
                    if (!isChecked) {
                      _playSound('images/healthy_eating/sonido_noti_entrada.mp3');
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isChecked ? const Color(0xFFF1F8E9) : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isChecked ? const Color(0xFF8BC34A) : Colors.black12,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isChecked ? const Color(0xFF4CAF50) : Colors.black38,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strategies[index]['title']!,
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isChecked ? const Color(0xFF2E7D32) : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                strategies[index]['desc']!,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.5,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Slide 5: Practical Techniques
  Widget _buildSlide5() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'TÉCNICAS RECOMENDADAS',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTechTab(0, 'Respirar', Icons.air_rounded),
                _buildTechTab(1, 'Relajar', Icons.fitness_center_rounded),
                _buildTechTab(2, 'Organizar', Icons.calendar_today_rounded),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedTechnique == 0) ...[
              // Breathing practice card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFB2EBF2), width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'Técnica: Respiración 4-4',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF006064)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inhala por 4 segundos, luego exhala lentamente por otros 4 segundos para regular tus latidos y calmar la ansiedad.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _startBreathingExercise,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isBreathing ? 130 : 180,
                        height: _isBreathing ? 130 : 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00ACC1),
                          // Always rectangle — animate borderRadius to 65 to look like a circle
                          borderRadius: BorderRadius.circular(_isBreathing ? 65 : 27),
                        ),
                        alignment: Alignment.center,
                        child: _isBreathing
                            ? Text(
                                '$_breathingCountdown',
                                style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                              )
                            : Text(
                                'Empezar ahora',
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                    if (_isBreathing) ...[
                      const SizedBox(height: 12),
                      Text(
                        _breathingText,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF006064)),
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (_selectedTechnique == 1) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD1C4E9), width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'Técnica: Relajación Muscular',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF311B92)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contrae tus hombros hacia arriba con fuerza durante 5 segundos y luego suéltalos de golpe dejando salir el aire. Repite 3 veces.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    const Icon(Icons.spa_rounded, size: 50, color: Color(0xFF673AB7)),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'Técnica: Planificación Dividida',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No intentes abarcar todo un proyecto a la vez. Divide tus tareas en bloques de 25 minutos con descansos de 5 minutos.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    const Icon(Icons.playlist_add_check_rounded, size: 50, color: Color(0xFF4CAF50)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Happy Titi Mascot display below selected technique
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                'assets/images/healthy_eating/gifs/titi1 feliz.gif',
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/healthy_eating/images/titi patita.png',
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTechTab(int index, String label, IconData icon) {
    final isActive = _selectedTechnique == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedTechnique = index;
        });
        _playSound('images/healthy_eating/sonido_noti_entrada.mp3');
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFF8A71) : Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? const Color(0xFFFF8A71) : Colors.black12,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFFFF8A71) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Slide 6: Completion
  Widget _buildSlide6() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Text(
                'MÓDULO DE ADAPTACIÓN AL 100%',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E7D32),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  '¡MISIÓN DE ESTRÉS CUMPLIDA!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 150),
              child: Text(
                '¡Titi domina el estrés universitario!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: Image.asset(
                'assets/images/healthy_eating/gifs/titi1 feliz.gif',
                height: 210,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/healthy_eating/images/titi patita.png',
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_showCheck1)
              FadeInLeft(
                duration: const Duration(milliseconds: 400),
                child: _buildCheckItem('Respuestas de adaptación activadas.'),
              ),
            if (_showCheck2)
              FadeInLeft(
                duration: const Duration(milliseconds: 400),
                child: _buildCheckItem('Síntomas identificados con éxito.'),
              ),
            if (_showCheck3)
              FadeInLeft(
                duration: const Duration(milliseconds: 400),
                child: _buildCheckItem('Técnicas de calma aprendidas.'),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/healthy_eating/images/boton check.png',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 34,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 17.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final canGoNext = (_currentPage != 3 || _checkedStrategies.every((c) => c));

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        color: const Color(0xFFFAFBFF),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Soft background leaf decorations (same as HealthyEatingPage)
            Positioned(
              bottom: -20,
              left: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(45 / 360),
                child: Icon(
                  Icons.self_improvement_rounded,
                  size: 150,
                  color: const Color(0xFF5C6BC0).withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              right: -30,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(-30 / 360),
                child: Icon(
                  Icons.air_rounded,
                  size: 130,
                  color: const Color(0xFF5C6BC0).withValues(alpha: 0.07),
                ),
              ),
            ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // Top Progress Bar
          Positioned(
            top: screenHeight * 0.11,
            left: 0,
            right: 0,
            child: Center(
              child: _buildTopProgressBar(),
            ),
          ),

          // PageView content
          Positioned(
            top: screenHeight * 0.15,
            bottom: screenHeight * 0.13,
            left: 0,
            right: 0,
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
                if (page == 5) {
                  _startSequentialChecks();
                }
              },
              children: [
                _buildSlide1(),
                _buildSlide2(),
                _buildSlide3(),
                _buildSlide4(),
                _buildSlide5(),
                _buildSlide6(),
              ],
            ),
          ),

          // Bottom Navigation Controls
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                if (_currentPage > 0)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF2ED),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFFFF8A71),
                        size: 26,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 56),

                // Next / Finish Button
                if (canGoNext)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (_currentPage == 5) {
                        // Go back to Module 6
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go('/module6');
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: (_currentPage == 0 || _currentPage == 5) ? 200 : 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A71),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: ClipRect(
                        child: OverflowBox(
                          minWidth: 0,
                          maxWidth: 200,
                          minHeight: 0,
                          maxHeight: 60,
                          child: (_currentPage == 0 || _currentPage == 5)
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentPage == 0 ? 'Empezar lecciones' : 'Finalizar',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                )
                              : const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                        ),
                      ),
                    ),
                  )
                else
                  // Disabled Next visual state to prompt completing the checklist
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white30,
                      size: 26,
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
}
