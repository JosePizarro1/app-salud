import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/module_header.dart';
import '../widgets/healthy_mind_widget.dart';
import '../widgets/healthy_eating_detail_widget.dart';
import '../widgets/healthy_energy_widget.dart';
import '../widgets/super_brain_power_widget.dart';
import '../widgets/healthy_eating_lesson1_widget.dart';
import '../widgets/healthy_eating_lesson2_widget.dart';
import '../widgets/healthy_eating_lesson3_widget.dart';
import '../widgets/healthy_eating_completion_widget.dart';

class HealthyEatingPage extends StatefulWidget {
  const HealthyEatingPage({super.key});

  @override
  State<HealthyEatingPage> createState() => _HealthyEatingPageState();
}

class _HealthyEatingPageState extends State<HealthyEatingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLesson1Correct = false;
  bool _isLesson2Correct = false;
  bool _isLesson3Correct = false;

  final GlobalKey<HealthyMindWidgetState> _healthyMindKey = GlobalKey<HealthyMindWidgetState>();
  final GlobalKey<HealthyEnergyWidgetState> _healthyEnergyKey = GlobalKey<HealthyEnergyWidgetState>();
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildWelcomeSlide() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gradient Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'ALIMENTACIÓN\nSALUDABLE',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Pink Bubble Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2ED), // Soft pink/coral
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFFD5CC),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Comer bien no se trata de ser perfecto, sino de tomar mejores decisiones cada día.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Descubre cómo una alimentación saludable puede ayudarte a sentirte mejor.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Titi Mascot
          Image.asset(
            'assets/images/healthy_eating/gifs/titi1 feliz.gif',
            height: 220,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/gato1.png',
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtonImage({
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: MediaQuery.of(context).size.width * 0.85,
        height: 72,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF8A71), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              imagePath.split('/').last,
              style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionMenuSlide() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'ALIMENTACIÓN\nSALUDABLE',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            '¿Qué descubriremos hoy?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),

          // 3 Buttons
          _buildMenuButtonImage(
            imagePath: 'assets/images/healthy_eating/images/boton nutricion equilibrad.png',
            onTap: () {
              _pageController.animateToPage(
                2,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),
          _buildMenuButtonImage(
            imagePath: 'assets/images/healthy_eating/images/boton energia natural.png',
            onTap: () {
              _pageController.animateToPage(
                3,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),
          _buildMenuButtonImage(
            imagePath: 'assets/images/healthy_eating/images/boton bienestar duradero.png',
            onTap: () {
              _pageController.animateToPage(
                4,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),
          const SizedBox(height: 12),

          // Titi Mascot (titi patita)
          Image.asset(
            'assets/images/healthy_eating/images/titi patita.webp',
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/gato1.png',
              height: 130,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBgColor() {
    switch (_currentPage) {
      case 0:
        return const Color(0xFFFFF7F5); // Dynamic welcome color
      case 1:
        return const Color(0xFFF6FAF8); // Selection menu color (matching light green)
      case 2:
        return const Color(0xFFF6F5FD); // Card 1 (Soft purple)
      case 3:
        return const Color(0xFFF5FAF6); // Card 2 (Soft green)
      case 4:
        return const Color(0xFFFFFDF5); // Card 3 (Soft yellow)
      case 5:
        return const Color(0xFFFFF5F6); // Mente Sana slide (Soft pink)
      case 6:
        return const Color(0xFFF5FAF6); // Full Energía slide (Soft green)
      case 7:
        return const Color(0xFFF6FAF8); // Súper Potencia Cerebral slide (Soft light green/blue)
      case 8:
        return const Color(0xFFFAFBFF); // Lección 1 slide background
      case 9:
        return const Color(0xFFFAFBFF); // Lección 2 slide background
      case 10:
        return const Color(0xFFFAFBFF); // Lección 3 slide background
      case 11:
        return const Color(0xFFF9FDFB); // Misión Cumplida slide background
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        color: _getBgColor(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Soft background leaf decorations
            Positioned(
              bottom: -20,
              left: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(45 / 360),
                child: Icon(
                  Icons.eco_rounded,
                  size: 150,
                  color: const Color(0xFF4CAF50).withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              right: -30,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(-30 / 360),
                child: Icon(
                  Icons.eco_rounded,
                  size: 130,
                  color: const Color(0xFF4CAF50).withOpacity(0.08),
                ),
              ),
            ),

            // Header
            const ModuleHeader(showHome: true, showBack: true),

            // Main PageView content
            Positioned(
              top: screenHeight * 0.16,
              bottom: screenHeight * 0.13,
              left: 0,
              right: 0,
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomeSlide(),
                  _buildSelectionMenuSlide(),
                  const HealthyEatingDetailWidget(
                    imagePath: 'assets/images/healthy_eating/images/boton nutricion equilibrad.png',
                    description: 'Una alimentación equilibrada aporta los nutrientes necesarios para el adecuado funcionamiento del organismo. Consumir frutas, verduras, cereales, proteínas y agua ayuda a mantener una buena salud y prevenir enfermedades.',
                  ),
                  const HealthyEatingDetailWidget(
                    imagePath: 'assets/images/healthy_eating/images/boton energia natural.png',
                    description: 'Los alimentos proporcionan la energía que necesitas para estudiar, realizar actividad física y afrontar tus actividades diarias. Una alimentación saludable favorece la concentración, el rendimiento académico y reduce la sensación de cansancio.',
                  ),
                  const HealthyEatingDetailWidget(
                    imagePath: 'assets/images/healthy_eating/images/boton bienestar duradero.png',
                    description: 'Mantener hábitos alimenticios saludables contribuye al bienestar físico y emocional. Además, ayuda a prevenir enfermedades crónicas y favorece una mejor calidad de vida en todas las etapas, desde la juventud hasta la adultez.',
                  ),
                  HealthyMindWidget(
                    key: _healthyMindKey,
                    onDetailChanged: () => setState(() {}),
                  ),
                  HealthyEnergyWidget(
                    key: _healthyEnergyKey,
                    onDetailChanged: () => setState(() {}),
                  ),
                  const SuperBrainPowerWidget(),
                  HealthyEatingLesson1Widget(
                    onCorrectAnswer: () {
                      setState(() {
                        _isLesson1Correct = true;
                      });
                    },
                  ),
                  HealthyEatingLesson2Widget(
                    onCorrectAnswer: () {
                      setState(() {
                        _isLesson2Correct = true;
                      });
                    },
                  ),
                  HealthyEatingLesson3Widget(
                    onCorrectAnswer: () {
                      setState(() {
                        _isLesson3Correct = true;
                      });
                    },
                  ),
                  const HealthyEatingCompletionWidget(),
                ],
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Builder(
                builder: (context) {
                  bool showNext = true;
                  if (_currentPage == 5 && (_healthyMindKey.currentState?.isDetailActive ?? false)) {
                    showNext = false;
                  }
                  if (_currentPage == 6 && (_healthyEnergyKey.currentState?.isDetailActive ?? false)) {
                    showNext = false;
                  }
                  if (_currentPage == 8 && !_isLesson1Correct) {
                    showNext = false; // Hide next button to force answering Lesson 1
                  }
                  if (_currentPage == 9 && !_isLesson2Correct) {
                    showNext = false; // Hide next button to force answering Lesson 2
                  }
                  if (_currentPage == 10 && !_isLesson3Correct) {
                    showNext = false; // Hide next button on Lesson 3 until answered correctly
                  }

                  return Row(
                    mainAxisAlignment: _currentPage == 0 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: () {
                            if (_currentPage == 11) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else if (_currentPage == 10) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else if (_currentPage == 9) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else if (_currentPage == 8) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else if (_currentPage == 7) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else if (_currentPage == 6) {
                              if (_healthyEnergyKey.currentState?.isDetailActive ?? false) {
                                _healthyEnergyKey.currentState?.resetToOverview();
                              } else {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            } else if (_currentPage == 5) {
                              if (_healthyMindKey.currentState?.isDetailActive ?? false) {
                                _healthyMindKey.currentState?.resetToOverview();
                              } else {
                                _pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }
                            } else if (_currentPage >= 2 && _currentPage <= 4) {
                              _pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                              );
                            } else {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
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
                        ),

                      if (showNext)
                        GestureDetector(
                          onTap: () {
                            if (_currentPage == 1) {
                              _pageController.animateToPage(
                                5,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else if (_currentPage == 11) {
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
                            width: (_currentPage == 7 || _currentPage == 8 || _currentPage == 9 || _currentPage == 10) ? 200 : 60,
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
                                child: (_currentPage == 7 || _currentPage == 8 || _currentPage == 9 || _currentPage == 10)
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _currentPage == 7
                                                ? 'Empezar lecciones'
                                                : (_currentPage == 8 || _currentPage == 9)
                                                    ? 'Siguiente lección'
                                                    : 'Finalizar',
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
                        const SizedBox(width: 60, height: 60),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
