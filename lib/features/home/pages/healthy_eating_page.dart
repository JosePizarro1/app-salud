import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/services/sfx_manager.dart';
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
  bool _isSuperBrainPowerFinished = false;
  bool _showMenuTutorial = true;

  final GlobalKey<HealthyMindWidgetState> _healthyMindKey = GlobalKey<HealthyMindWidgetState>();
  final GlobalKey<HealthyEnergyWidgetState> _healthyEnergyKey = GlobalKey<HealthyEnergyWidgetState>();
  double _badgeScale = 1.0;
  double _badgeRotation = 0.0;
  bool _shouldBounceNext = false;
  Timer? _bounceTimer;

  @override
  void initState() {
    super.initState();
    _startBounceTimer();
  }

  void _startBounceTimer() {
    _bounceTimer?.cancel();
    _bounceTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _currentPage == 0) {
        setState(() {
          _shouldBounceNext = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _bounceTimer?.cancel();
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

          // Pink Bubble Card with Pop & Tilt Tap Animation
          AnimatedRotation(
            turns: _badgeRotation,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: AnimatedScale(
              scale: _badgeScale,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _badgeScale = 1.06;
                    _badgeRotation = 0.02; // Rotate slightly to the right
                  });
                  SfxManager().playClick();
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (mounted) {
                      setState(() {
                        _badgeScale = 1.0;
                        _badgeRotation = 0.0;
                      });
                    }
                  });
                },
                child: Container(
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
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Titi Mascot
          Image.asset(
            'assets/images/healthy_eating/gifs/titi1 feliz.webp',
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
      onTap: () {
        SfxManager().playClick();
        onTap();
      },
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
            imagePath: 'assets/images/healthy_eating/images/boton nutricion equilibrad.webp',
            onTap: () {
              _pageController.animateToPage(
                3, // Page index updated (was 2)
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),
          _buildMenuButtonImage(
            imagePath: 'assets/images/healthy_eating/images/boton energia natural.webp',
            onTap: () {
              _pageController.animateToPage(
                4, // Page index updated (was 3)
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),
          _buildMenuButtonImage(
            imagePath: 'assets/images/healthy_eating/images/boton bienestar duradero.webp',
            onTap: () {
              _pageController.animateToPage(
                5, // Page index updated (was 4)
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

  Widget _buildMainMenuSlide() {
    return Stack(
      children: [
        // Main page content scrollable
        Positioned.fill(
          child: SingleChildScrollView(
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
              const SizedBox(height: 16),

              // 4 Buttons in WebP styled as badges
              AbsorbPointer(
                absorbing: _showMenuTutorial,
                child: Column(
                  children: [
                    _buildMainMenuButton(
                      imagePath: 'assets/images/healthy_eating/Boton inicial LECCIONES.webp',
                      title: 'Lección',
                      backgroundColor: const Color(0xFFEAF2FF),
                      borderColor: const Color(0xFFD2E3FC),
                      iconColor: const Color(0xFF1A73E8),
                      onTap: () {
                        _pageController.animateToPage(
                          2, // Proceed to selection menu
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    _buildMainMenuButton(
                      imagePath: 'assets/images/healthy_eating/boton_porciones.webp',
                      title: 'Guía de porciones',
                      backgroundColor: const Color(0xFFEDF7ED),
                      borderColor: const Color(0xFFCEEAD6),
                      iconColor: const Color(0xFF137333),
                      onTap: () {
                        context.push('/portions_guide');
                      },
                    ),
                    _buildMainMenuButton(
                      imagePath: 'assets/images/healthy_eating/Boton inicial IMC.webp',
                      title: 'Calcular mi IMC',
                      backgroundColor: const Color(0xFFE8F8F5),
                      borderColor: const Color(0xFFC2ECDF),
                      iconColor: const Color(0xFF0F9D58),
                      onTap: () {
                        context.push('/bmi_calculator');
                      },
                    ),
                    _buildMainMenuButton(
                      imagePath: 'assets/images/healthy_eating/Boton inicial ALIMENTOS.webp',
                      title: 'Conociendo Alimentos',
                      backgroundColor: const Color(0xFFFFF2ED),
                      borderColor: const Color(0xFFFAD2B7),
                      iconColor: const Color(0xFFE06000),
                      onTap: () {
                        context.push('/knowing_foods');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Phrase (always visible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Comer bien no se trata de ser perfecto, sino de tomar mejores decisiones cada día.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        ),

        // Tutorial Overlay Layer
        if (_showMenuTutorial)
          Positioned.fill(
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF5), // Soft pastel yellow/warm white
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFFF0C2),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mascot speaking
                      Image.asset(
                        'assets/images/healthy_eating/images/titi patita.webp',
                        height: 130,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¡Hora de aprender!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Descubre cómo una alimentación saludable puede ayudarte a sentirte mejor.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Green check button
                      GestureDetector(
                        onTap: () {
                          SfxManager().playClick();
                          setState(() {
                            _showMenuTutorial = false;
                          });
                        },
                        child: Image.asset(
                          'assets/images/healthy_eating/images/boton check.webp',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainMenuButton({
    required String imagePath,
    required String title,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SfxManager().playClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
        width: MediaQuery.of(context).size.width * 0.88,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Image.asset(
              imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('🧠', style: GoogleFonts.outfit(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            // Text Details
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            // Chevron arrow
            Icon(
              Icons.chevron_right_rounded,
              color: iconColor,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBgColor() {
    return const Color(0xFFFFE4D7); // Uniform background color for all menus & sections in Healthy Eating
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
            // Soft background food & health decorations
            Positioned(
              bottom: -20,
              left: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(15 / 360),
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 150,
                  color: Colors.black.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -30,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(-20 / 360),
                child: Icon(
                  Icons.apple_rounded,
                  size: 140,
                  color: Colors.black.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(45 / 360),
                child: Icon(
                  Icons.emoji_food_beverage_rounded,
                  size: 110,
                  color: Colors.black.withOpacity(0.05),
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
                    // Reset bounce status and trigger/cancel timer appropriately
                    if (page == 0) {
                      _shouldBounceNext = false;
                      _startBounceTimer();
                    } else {
                      _bounceTimer?.cancel();
                      _shouldBounceNext = false;
                    }
                  });
                  if (page == 1 && _showMenuTutorial) {
                    SfxManager().playNotiSound();
                  }
                },
                children: [
                  _buildWelcomeSlide(),
                  _buildMainMenuSlide(),
                  _buildSelectionMenuSlide(),
                  const HealthyEatingDetailWidget(
                    imagePath: 'assets/images/healthy_eating/images/boton nutricion equilibrad.webp',
                    description: 'Una alimentación equilibrada aporta los nutrientes necesarios para el adecuado funcionamiento del organismo. Consumir frutas, verduras, cereales, proteínas y agua ayuda a mantener una buena salud y prevenir enfermedades.',
                  ),
                  const HealthyEatingDetailWidget(
                    imagePath: 'assets/images/healthy_eating/images/boton energia natural.webp',
                    description: 'Los alimentos proporcionan la energía que necesitas para estudiar, realizar actividad física y afrontar tus actividades diarias. Una alimentación saludable favorece la concentración, el rendimiento académico y reduce la sensación de cansancio.',
                  ),
                  const HealthyEatingDetailWidget(
                    imagePath: 'assets/images/healthy_eating/images/boton bienestar duradero.webp',
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
                  SuperBrainPowerWidget(
                    onAnimationComplete: () {
                      setState(() {
                        _isSuperBrainPowerFinished = true;
                      });
                    },
                  ),
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
                  if (_currentPage == 8 && !_isSuperBrainPowerFinished) {
                    return const SizedBox.shrink();
                  }
                  bool showNext = true;
                  if (_currentPage == 1) {
                    showNext = false; // Hide next on the new Main Menu Page, they must click Lección
                  }
                  if (_currentPage >= 3 && _currentPage <= 5) {
                    showNext = false;
                  }
                  if (_currentPage == 6 && (_healthyMindKey.currentState?.isDetailActive ?? false)) {
                    showNext = false;
                  }
                  if (_currentPage == 7 && (_healthyEnergyKey.currentState?.isDetailActive ?? false)) {
                    showNext = false;
                  }
                  if (_currentPage == 9 && !_isLesson1Correct) {
                    showNext = false; // Hide next button to force answering Lesson 1
                  }
                  if (_currentPage == 10 && !_isLesson2Correct) {
                    showNext = false; // Hide next button to force answering Lesson 2
                  }
                  if (_currentPage == 11 && !_isLesson3Correct) {
                    showNext = false; // Hide next button on Lesson 3 until answered correctly
                  }

                  Widget? nextButton;
                  if (showNext) {
                    Widget btn = GestureDetector(
                      onTap: () {
                        _bounceTimer?.cancel();
                        setState(() {
                          _shouldBounceNext = false;
                        });

                        if (_currentPage == 2) {
                          _pageController.animateToPage(
                            6,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else if (_currentPage == 12) {
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
                        width: (_currentPage == 8 || _currentPage == 9 || _currentPage == 10 || _currentPage == 11) ? 200 : 60,
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
                            child: (_currentPage == 8 || _currentPage == 9 || _currentPage == 10 || _currentPage == 11)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _currentPage == 8
                                            ? 'Empezar lecciones'
                                            : (_currentPage == 9 || _currentPage == 10)
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
                    );

                    if (_currentPage == 0 && _shouldBounceNext) {
                      nextButton = Bounce(
                        infinite: true,
                        duration: const Duration(milliseconds: 1500),
                        child: btn,
                      );
                    } else {
                      nextButton = btn;
                    }
                  }

                  return Row(
                    mainAxisAlignment: _currentPage == 0 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: () {
                            if (_currentPage == 12) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else if (_currentPage == 11) {
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
                              if (_healthyEnergyKey.currentState?.isDetailActive ?? false) {
                                _healthyEnergyKey.currentState?.resetToOverview();
                              } else {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            } else if (_currentPage == 6) {
                              if (_healthyMindKey.currentState?.isDetailActive ?? false) {
                                _healthyMindKey.currentState?.resetToOverview();
                              } else {
                                _pageController.animateToPage(
                                  2,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }
                            } else if (_currentPage >= 3 && _currentPage <= 5) {
                              _pageController.animateToPage(
                                  2,
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

                      if (nextButton != null)
                        nextButton
                      else if (_currentPage > 0)
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
