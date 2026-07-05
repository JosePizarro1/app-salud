import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../app/theme/app_colors.dart';

enum Lesson2State { question, correct, incorrect }

class HealthyEatingLesson2Widget extends StatefulWidget {
  final VoidCallback? onCorrectAnswer;
  const HealthyEatingLesson2Widget({super.key, this.onCorrectAnswer});

  @override
  State<HealthyEatingLesson2Widget> createState() => _HealthyEatingLesson2WidgetState();
}

class _HealthyEatingLesson2WidgetState extends State<HealthyEatingLesson2Widget> {
  Lesson2State _viewState = Lesson2State.question;
  int? _hoveredOption;
  bool _showCelebration = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playCelebrationSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/success_cheerful.mp3'));
    } catch (e) {
      debugPrint('Error playing celebration sound: $e');
    }
  }

  Future<void> _playIncorrectSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/error_sound.mp3'));
    } catch (e) {
      debugPrint('Error playing incorrect sound: $e');
    }
  }

  void _handleOptionSelected(int optionId) {
    if (optionId == 1) {
      // Correct option selected (Fruits/nuts bowl)
      setState(() {
        _viewState = Lesson2State.correct;
        _showCelebration = true;
      });
      _playCelebrationSound();
      
      widget.onCorrectAnswer?.call();
    } else {
      // Incorrect option selected (Chips Lays)
      _playIncorrectSound();
      setState(() {
        _viewState = Lesson2State.incorrect;
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

        // Subtitle: "LECCIÓN 2"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'LECCIÓN 2',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
              letterSpacing: 1.5,
            ),
          ),
        ),

        // Large Title: "SNACKS SALUDABLES"
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
              'SNACKS SALUDABLES',
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
            'Ahora Titi necesita mantener la memoria.\n¿Qué snack lo ayudará?',
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

        // Mascot (Titi lentes)
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 300),
          child: Image.asset(
            'assets/images/healthy_eating/images/titi lentes.png',
            height: 210,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/healthy_eating/images/titi patita.png',
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
                imagePath: 'assets/images/healthy_eating/images/leccion2 boton1.png',
                optionId: 1,
              ),
              _buildLessonOption(
                imagePath: 'assets/images/healthy_eating/images/leccion2 boton2.png',
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

        // Subtitle: "LECCIÓN 2"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'LECCIÓN 2',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
              letterSpacing: 1.5,
                ),
              ),
            ),

        // Large Title: "SNACKS SALUDABLES"
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
              'SNACKS SALUDABLES',
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

        // Mascot (Titi lentes)
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Image.asset(
            'assets/images/healthy_eating/images/titi lentes.png',
            height: 210,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/healthy_eating/images/titi patita.png',
              height: 170,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Explanation text
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Los frutos secos contienen Omega-3 y grasas saludables que favorecen la memoria. ¡Perfecto para tus clases!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
                height: 1.35,
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
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

        // Subtitle: "LECCIÓN 2"
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'LECCIÓN 2',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
              letterSpacing: 1.5,
            ),
          ),
        ),

        // Large Title: "SNACKS SALUDABLES"
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
              'SNACKS SALUDABLES',
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

        // Mascot (Titi lentes cansado)
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Image.asset(
            'assets/images/healthy_eating/images/titi lentes cansado.png',
            height: 210,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/healthy_eating/images/titi patita.png',
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
              'Las frituras tienen grasas saturadas y sodio que no ayudan a tu concentración. ¡Elige un snack saludable!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
                height: 1.3,
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
                _viewState = Lesson2State.question;
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
      case Lesson2State.question:
        content = _buildQuestionContent();
        break;
      case Lesson2State.correct:
        content = _buildCorrectContent();
        break;
      case Lesson2State.incorrect:
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
