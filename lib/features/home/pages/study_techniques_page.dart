import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/module_header.dart';
import '../widgets/blurting_lesson_widget.dart';
import '../widgets/feynman_lesson_widget.dart';
import '../widgets/spaced_repetition_lesson_widget.dart';
import '../widgets/pomodoro_lesson_widget.dart';

class StudyTechniquesPage extends StatefulWidget {
  const StudyTechniquesPage({super.key});

  @override
  State<StudyTechniquesPage> createState() => _StudyTechniquesPageState();
}

class _StudyTechniquesPageState extends State<StudyTechniquesPage> {
  final List<bool> _buttonScales = [false, false, false, false];
  int _activeLesson = 0; // 0: Menu, 1: Blurting, 2: Feynman, 3: Spaced Repetition, 4: Pomodoro

  Future<void> _triggerScale(int index) async {
    setState(() => _buttonScales[index] = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() => _buttonScales[index] = false);
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
        color: const Color(0xFFFAFBFF),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Soft background leaf decorations (same as Module 6 pages)
            Positioned(
              bottom: -20,
              left: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(45 / 360),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 150,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: -30,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(-20 / 360),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 140,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.06),
                ),
              ),
            ),

            // Shared Header with Home Button
            const ModuleHeader(showHome: true),

            // Toggle view between main list menu and specific active lesson widget
            _activeLesson == 0
                ? _buildMainMenuView(screenHeight)
                : _buildActiveLessonWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveLessonWidget() {
    switch (_activeLesson) {
      case 1:
        return BlurtingLessonWidget(
          onBackToMenu: () => setState(() => _activeLesson = 0),
        );
      case 2:
        return FeynmanLessonWidget(
          onBackToMenu: () => setState(() => _activeLesson = 0),
        );
      case 3:
        return SpacedRepetitionLessonWidget(
          onBackToMenu: () => setState(() => _activeLesson = 0),
        );
      case 4:
        return PomodoroLessonWidget(
          onBackToMenu: () => setState(() => _activeLesson = 0),
        );
      // Other lessons (Feynman, etc.) can be placed here in the future
      default:
        return const SizedBox();
    }
  }

  Widget _buildMainMenuView(double screenHeight) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main scrollable content
        Positioned(
          top: screenHeight * 0.15,
          bottom: screenHeight * 0.12,
          left: 0,
          right: 0,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Title "TÉCNICAS DE ESTUDIO"
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'TÉCNICAS DE ESTUDIO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Vertical Stack of Buttons
                _buildTechniqueButton(
                  index: 0,
                  imagePath: 'assets/images/modulo estudio png/boton metodo blurting.png',
                  onTap: () {
                    _triggerScale(0);
                    setState(() => _activeLesson = 1);
                  },
                ),
                _buildTechniqueButton(
                  index: 1,
                  imagePath: 'assets/images/modulo estudio png/boton tecnica feynman.png',
                  onTap: () {
                    _triggerScale(1);
                    setState(() => _activeLesson = 2);
                  },
                ),
                _buildTechniqueButton(
                  index: 2,
                  imagePath: 'assets/images/modulo estudio png/boton repeticion espaciada.png',
                  onTap: () {
                    _triggerScale(2);
                    setState(() => _activeLesson = 3);
                  },
                ),
                _buildTechniqueButton(
                  index: 3,
                  imagePath: 'assets/images/modulo estudio png/boton tecnica pomodoro.png',
                  onTap: () {
                    _triggerScale(3);
                    setState(() => _activeLesson = 4);
                  },
                ),

                const SizedBox(height: 24),

                // Dialog card / speech bubble
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0ED), // light pinkish peach color
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFFFF2ED),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'No todas las personas aprenden de la misma manera. Existen distintas técnicas de estudio que pueden ayudarte a comprender mejor la información y recordarla por más tiempo.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Mascot: Titi escribiendo
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: Image.asset(
                    'assets/images/modulo estudio png/titi escribiendo.png',
                    height: 170,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/healthy_eating/images/titi patita.png',
                      height: 170,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Navigation Controls for Menu (Back Button only)
        Positioned(
          bottom: 24,
          left: 24,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/module6');
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
        ),
      ],
    );
  }

  Widget _buildTechniqueButton({
    required int index,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    double widthMultiplier = 0.88;
    if (index == 2) {
      widthMultiplier = 0.98; // 10% extra
    } else if (index == 3) {
      widthMultiplier = 0.93; // 5% extra
    }

    final double buttonWidth = MediaQuery.of(context).size.width * widthMultiplier;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: FadeInLeft(
        duration: Duration(milliseconds: 400 + (index * 100)),
        child: Center(
          child: AnimatedScale(
            scale: _buttonScales[index] ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: Container(
                width: buttonWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 74,
                    width: buttonWidth,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      child: Image.asset(
                        imagePath,
                        width: buttonWidth,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 74,
                          width: buttonWidth,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Text(
                            'Técnica ${index + 1}',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
