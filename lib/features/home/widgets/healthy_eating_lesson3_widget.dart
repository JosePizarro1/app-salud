import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import '../../../app/services/sfx_manager.dart';
import '../../../app/theme/app_colors.dart';

enum Lesson3State { question, correct, incorrect }

class HealthyEatingLesson3Widget extends StatefulWidget {
  final VoidCallback? onCorrectAnswer;
  const HealthyEatingLesson3Widget({super.key, this.onCorrectAnswer});

  @override
  State<HealthyEatingLesson3Widget> createState() => _HealthyEatingLesson3WidgetState();
}

class _HealthyEatingLesson3WidgetState extends State<HealthyEatingLesson3Widget> {
  Lesson3State _viewState = Lesson3State.question;
  int? _hoveredOption;
  bool _showCelebration = false;

  void _handleOptionSelected(int optionId) {
    if (optionId == 1) {
      // Correct option selected (Yogurt & egg)
      setState(() {
        _viewState = Lesson3State.correct;
        _showCelebration = true;
      });
      SfxManager().playSuccess();
      widget.onCorrectAnswer?.call();
    } else {
      // Incorrect option selected (Candies & donuts)
      SfxManager().playError();
      setState(() {
        _viewState = Lesson3State.incorrect;
      });
    }
  }

  Widget _buildLessonOption({
    required String imagePath,
    required int optionId,
  }) {
    final isHovered = _hoveredOption == optionId;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _hoveredOption = optionId);
      },
      onTapCancel: () {
        setState(() => _hoveredOption = null);
      },
      onTapUp: (_) {
        setState(() => _hoveredOption = null);
      },
      onTap: () => _handleOptionSelected(optionId),
      child: AnimatedScale(
        scale: isHovered ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 126,
          height: 126,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceSupport,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'Opción $optionId',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Header: "Alimentación Saludable"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Alimentación Saludable',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Subtitle: "LECCIÓN 3"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'LECCIÓN 3',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
              letterSpacing: 1.5,
            ),
          ),
        ),

        // Large Title: "ANSIEDAD ANTES DEL EXAMEN"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 150),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'ANSIEDAD ANTES DEL EXAMEN',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Central Question
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 250),
          child: Text(
            'Titi estudió todo el día.\nAhora está nervioso.\n¿Qué debería comer?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimaryLight,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Mascot (Titi pensativo GIF)
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 300),
          child: Image.asset(
            'assets/images/healthy_eating/gifs/titi pensativo (1).gif',
            height: 210,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/healthy_eating/images/titi patita.webp',
              height: 170,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Options Row
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLessonOption(
                imagePath: 'assets/images/healthy_eating/images/leccion3 boton1.png',
                optionId: 1,
              ),
              _buildLessonOption(
                imagePath: 'assets/images/healthy_eating/images/leccion3 boton2.png',
                optionId: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCorrectContent() {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Header: "Alimentación Saludable"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Alimentación Saludable',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Subtitle: "LECCIÓN 3"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'LECCIÓN 3',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
              letterSpacing: 1.5,
            ),
          ),
        ),

        // Large Title: "ANSIEDAD ANTES DEL EXAMEN"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 150),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'ANSIEDAD ANTES DEL EXAMEN',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Center Message
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '¡Excelente elección! Estos alimentos ayudan a que tu cerebro funcione mejor y favorecen una sensación de calma.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
                height: 1.35,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Dialogue bubble card and Mascot in stack
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Dialogue Bubble Card
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 150),
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEEE8), // Peach background
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFECE5), width: 1.5),
                ),
                child: Text(
                  '¿Sabías que...? Algunos alimentos, como el plátano, el yogur, los frutos secos y la avena, contienen vitaminas y minerales que contribuyen al bienestar del cerebro y ayudan a mantener un buen estado de ánimo.',
                  style: GoogleFonts.outfit(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            // Mascot (Titi patita waving at bottom right)
            Positioned(
              bottom: -130,
              right: 16,
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 250),
                child: Image.asset(
                  'assets/images/healthy_eating/images/titi patita.webp',
                  height: 185,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 160), // room for mascot
      ],
    );
  }

  Widget _buildIncorrectContent() {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Header: "Alimentación Saludable"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Alimentación Saludable',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Subtitle: "LECCIÓN 3"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'LECCIÓN 3',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
              letterSpacing: 1.5,
            ),
          ),
        ),

        // Large Title: "ANSIEDAD ANTES DEL EXAMEN"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 150),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'ANSIEDAD ANTES DEL EXAMEN',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Mascot (Titi triste)
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Image.asset(
            'assets/images/healthy_eating/images/titi_triste.webp',
            height: 210,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/healthy_eating/images/titi patita.webp',
              height: 170,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Incorrect Explanation Text
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Los alimentos con mucho azúcar, sal o grasas pueden dar energía por poco tiempo, pero después pueden hacer que te sientas más cansado, distraído o con menos concentración.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
                height: 1.35,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Back / Retry button
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _viewState = Lesson3State.question;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Intentar de nuevo',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_viewState) {
      case Lesson3State.question:
        content = _buildQuestionContent();
        break;
      case Lesson3State.correct:
        content = _buildCorrectContent();
        break;
      case Lesson3State.incorrect:
        content = _buildIncorrectContent();
        break;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: content,
            ),
          ),
        ),

        // Celebration Overlay
        if (_showCelebration)
          Positioned.fill(
            child: IgnorePointer(
              child: DotLottieView(
                sourceType: 'asset',
                source: 'assets/lottie/success_celebration.lottie',
                autoplay: true,
                loop: false,
              ),
            ),
          ),
      ],
    );
  }
}
