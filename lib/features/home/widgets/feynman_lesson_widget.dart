import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/services/sfx_manager.dart';

class FeynmanLessonWidget extends StatefulWidget {
  final VoidCallback onBackToMenu;

  const FeynmanLessonWidget({
    super.key,
    required this.onBackToMenu,
  });

  @override
  State<FeynmanLessonWidget> createState() => _FeynmanLessonWidgetState();
}

class _FeynmanLessonWidgetState extends State<FeynmanLessonWidget> {
  int _currentStep = 0; // 0: Intro, 1: Step 1, 2: Step 2, 3: Step 3, 4: Step 4, 5: Why works, 6: Completed
  // Completed screen staggered animation state
  bool _showCompletedItem1 = false;
  bool _showCompletedItem2 = false;
  bool _showCompletedItem3 = false;
  bool _showCompletedItem4 = false;

  void _changeStep(int newStep) {
    setState(() {
      _currentStep = newStep;
      // Reset completed animation states if we navigate away
      if (newStep != 6) {
        _showCompletedItem1 = false;
        _showCompletedItem2 = false;
        _showCompletedItem3 = false;
        _showCompletedItem4 = false;
      }
    });

    // Play sound on Step 1, 2, 3, 4
    if (newStep == 1 || newStep == 2 || newStep == 3 || newStep == 4) {
      SfxManager().playSuccess();
    }

    // Start staggered sequence on Completed view
    if (newStep == 6) {
      _startCompletedSequence();
    }
  }

  void _startCompletedSequence() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _currentStep == 6) {
        setState(() => _showCompletedItem1 = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted && _currentStep == 6) {
        setState(() => _showCompletedItem2 = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted && _currentStep == 6) {
        setState(() => _showCompletedItem3 = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 3300), () {
      if (mounted && _currentStep == 6) {
        setState(() => _showCompletedItem4 = true);
      }
    });
  }

  Widget _buildTopProgressBar() {
    if (_currentStep < 0 || _currentStep > 5) return const SizedBox(height: 6);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isActive = index <= _currentStep;
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Body Content (under parent page's ModuleHeader)
        Positioned(
          top: screenHeight * 0.13,
          bottom: screenHeight * 0.12,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBodyContent(screenHeight),
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: _buildBottomControls(),
        ),
      ],
    );
  }

  Widget _buildBodyContent(double screenHeight) {
    switch (_currentStep) {
      case 0:
        return _buildFeynmanIntroView(screenHeight);
      case 1:
        return _buildStepView(
          stepNumber: 1,
          imagePath: 'assets/images/modulo estudio png/nro 1.png',
          header: 'Elegir un tema',
          subtitle: 'Selecciona el contenido que deseas aprender.',
          titiPath: 'assets/images/modulo estudio png/titi leyendo echado hacia arriba.png',
        );
      case 2:
        return _buildStepView(
          stepNumber: 2,
          imagePath: 'assets/images/modulo estudio png/nro 2.png',
          header: 'Escribir y explicar el tema',
          subtitle: 'Estudia el material y luego escribe todo lo que recuerdes. Después, explícalo en voz alta como si se lo enseñaras a otra persona, usando un lenguaje sencillo.',
          titiPath: 'assets/images/modulo estudio png/titi con lentes feliz.png',
        );
      case 3:
        return _buildStepView(
          stepNumber: 3,
          imagePath: 'assets/images/modulo estudio png/nro 3.png',
          header: 'Identificar y completar vacíos',
          subtitle: 'Revisa el contenido original y detecta qué partes olvidaste o no entendiste bien. Refuerza esos puntos.',
          titiPath: 'assets/images/modulo estudio png/titi leyendo echado.png',
        );
      case 4:
        return _buildStepView(
          stepNumber: 4,
          imagePath: 'assets/images/modulo estudio png/nro 4.png',
          header: 'Escribir y enseñar nuevamente',
          subtitle: 'Vuelve a escribir el tema de forma más clara y completa, luego de eso vas a explicarlo nuevamente a una persona imaginaria.',
          titiPath: 'assets/images/modulo estudio png/titi estudiando con hoja.png',
        );
      case 5:
        return _buildWhyWorksView(screenHeight);
      case 6:
        return _buildLessonCompletedView(screenHeight);
      default:
        return const SizedBox();
    }
  }

  Widget _buildFeynmanIntroView(double screenHeight) {
    return SingleChildScrollView(
      key: const ValueKey('FeynmanIntroView'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
      child: Column(
        children: [
          // Title "TÉCNICA FEYNMAN"
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'TÉCNICA FEYNMAN',
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
          const SizedBox(height: 25),

          // ── Progress Bar (debajo del título)
          Center(child: _buildTopProgressBar()),
          const SizedBox(height: 16),

          // Subtitle "¿Qué es?"
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 100),
            child: Text(
              '¿Qué es?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Paragraph description
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Consiste en estudiar un tema, explicarlo como si enseñaras a alguien más, identificar lo que no entiendes bien y reforzarlo hasta dominarlo completamente.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 35),

          // Speech bubble card
          FadeInUp(
            duration: const Duration(milliseconds: 650),
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0ED),
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
                'Si puedes explicarlo fácilmente, significa que realmente lo comprendiste.',
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
          const SizedBox(height: 24),

          // Mascot: Titi patita
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: const Duration(milliseconds: 400),
            child: Image.asset(
              'assets/images/healthy_eating/images/titi patita.webp',
              height: 165,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepView({
    required int stepNumber,
    required String imagePath,
    required String header,
    required String subtitle,
    required String titiPath,
  }) {
    return SingleChildScrollView(
      key: ValueKey('FeynmanStep$stepNumber'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
      child: Column(
        children: [
          // Header Sub
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Text(
              'TÉCNICAS DE ESTUDIO',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Title "TÉCNICA FEYNMAN"
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'TÉCNICA FEYNMAN',
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
          const SizedBox(height: 25),

          // ── Progress Bar (debajo del título)
          Center(child: _buildTopProgressBar()),
          const SizedBox(height: 16),

          // Step Number Image
          BounceInDown(
            duration: const Duration(milliseconds: 600),
            child: Image.asset(
              imagePath,
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF4CAF50),
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Step Header text
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                header,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Step Subtitle text
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Mascot Titi
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: const Duration(milliseconds: 300),
            child: Image.asset(
              titiPath,
              height: 175,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/healthy_eating/images/titi patita.webp',
                height: 175,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyWorksView(double screenHeight) {
    return SingleChildScrollView(
      key: const ValueKey('FeynmanWhyWorksView'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
      child: Column(
        children: [
          // Header Sub
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Text(
              'TÉCNICAS DE ESTUDIO',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Title "TÉCNICA FEYNMAN"
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'TÉCNICA FEYNMAN',
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
          const SizedBox(height: 25),

          // ── Progress Bar (debajo del título)
          Center(child: _buildTopProgressBar()),
          const SizedBox(height: 16),

          // Subtitle "¿Por qué funciona?"
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 100),
            child: Text(
              '¿Por qué funciona?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Paragraph description
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Te obliga a procesar la información de forma activa. Al intentar explicar un tema de manera simple, te das cuenta de qué partes no dominas bien.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 35),

          // Speech bubble card
          FadeInUp(
            duration: const Duration(milliseconds: 650),
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0ED),
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
                'Explicar con tus propias palabras y sin tecnicismos es la mejor forma de retener lo aprendido a largo plazo.',
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
          const SizedBox(height: 24),

          // Mascot: Titi patita
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: const Duration(milliseconds: 400),
            child: Image.asset(
              'assets/images/healthy_eating/images/titi patita.webp',
              height: 165,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCompletedView(double screenHeight) {
    return SingleChildScrollView(
      key: const ValueKey('FeynmanCompletedView'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
      child: Column(
        children: [
          // Title "TÉCNICAS DE ESTUDIO"
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Text(
              'TÉCNICAS DE ESTUDIO',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Title "TÉCNICA FEYNMAN"
          FadeInDown(
            duration: const Duration(milliseconds: 550),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'TÉCNICA FEYNMAN',
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

          // ── Progress Bar (debajo del título)
          Center(child: _buildTopProgressBar()),
          const SizedBox(height: 16),

          // LECCION COMPLETADA Header
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'LECCIÓN COMPLETADA',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Checklist Summary (Staggered visibility)
          Column(
            children: [
              if (_showCompletedItem1)
                _buildSummaryItem(
                  imagePath: 'assets/images/modulo estudio png/nro 1.png',
                  stepText: 'Selecciona un tema que desees aprender.',
                  index: 0,
                )
              else
                const SizedBox(height: 54),

              if (_showCompletedItem2)
                _buildSummaryItem(
                  imagePath: 'assets/images/modulo estudio png/nro 2.png',
                  stepText: 'Escribe y explica el tema como si se lo enseñaras a alguien más.',
                  index: 1,
                )
              else
                const SizedBox(height: 54),

              if (_showCompletedItem3)
                _buildSummaryItem(
                  imagePath: 'assets/images/modulo estudio png/nro 3.png',
                  stepText: 'Detecta qué partes olvidaste o no entendiste bien.',
                  index: 2,
                )
              else
                const SizedBox(height: 54),

              if (_showCompletedItem4)
                _buildSummaryItem(
                  imagePath: 'assets/images/modulo estudio png/nro 4.png',
                  stepText: 'Revisa la información y vuelve a explicarla de forma sencilla.',
                  index: 3,
                )
              else
                const SizedBox(height: 54),
            ],
          ),

          const SizedBox(height: 28),

          // Mascot Titi estudiando con hoja
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: Image.asset(
              'assets/images/modulo estudio png/titi estudiando con hoja.png',
              height: 165,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/healthy_eating/images/titi patita.webp',
                height: 165,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String imagePath,
    required String stepText,
    required int index,
  }) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 38,
              width: 38,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                radius: 19,
                backgroundColor: Color(0xFF4CAF50),
                child: Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                stepText,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    if (_currentStep == 6) {
      return Center(
        child: FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onBackToMenu(); // return to main menu of study techniques
            },
            child: Container(
              width: 220,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A71),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Volver a técnicas',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.reply_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (_currentStep > 0) {
              _changeStep(_currentStep - 1);
            } else {
              widget.onBackToMenu();
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

        // Next Button (Siguiente)
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (_currentStep < 6) {
              _changeStep(_currentStep + 1);
            }
          },
          child: Container(
            width: 146,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A71),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Siguiente',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
