import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../app/theme/app_colors.dart';

class SuperBrainPowerWidget extends StatefulWidget {
  const SuperBrainPowerWidget({super.key});

  @override
  State<SuperBrainPowerWidget> createState() => _SuperBrainPowerWidgetState();
}

class _SuperBrainPowerWidgetState extends State<SuperBrainPowerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _visibleCount = 0;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startAnimationSequence() async {
    // Initial delay before first item appears
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    for (int i = 1; i <= 4; i++) {
      setState(() {
        _visibleCount = i;
      });
      _playSound();
      await Future.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
    }
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('images/healthy_eating/sonido_noti_entrada.mp3'));
    } catch (e) {
      debugPrint('Error playing benefit appearance sound: $e');
    }
  }

  Widget _buildBrainBenefitItem({
    required String iconPath,
    required String title,
    required String description,
    required int index,
    required bool isVisible,
  }) {
    // Helper to generate the content layout
    Widget buildContent({required bool transparent}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Opacity(
              opacity: transparent ? 0.0 : 1.0,
              child: Image.asset(
                iconPath,
                width: 72,
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSupport,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '🧠',
                    style: GoogleFonts.outfit(fontSize: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Text Details
            Expanded(
              child: Opacity(
                opacity: transparent ? 0.0 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryLight,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!isVisible) {
      // Invisible placeholder to reserve the layout size perfectly
      return buildContent(transparent: true);
    }

    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: buildContent(transparent: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Title: "BENEFICIOS"
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'BENEFICIOS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            
            // Subtitle: "SÚPER POTENCIA CEREBRAL"
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
                  'SÚPER POTENCIA\nCEREBRAL',
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

            // Benefits List
            _buildBrainBenefitItem(
              iconPath: 'assets/images/healthy_eating/images/super potencia cerebral 1.png',
              title: 'Combate la fatiga',
              description: 'Mantén tu energía durante el día.',
              index: 0,
              isVisible: _visibleCount >= 1,
            ),
            _buildBrainBenefitItem(
              iconPath: 'assets/images/healthy_eating/images/super potencia cerebral 2.png',
              title: 'Mejora la memoria',
              description: 'Favorece el aprendizaje y la concentración.',
              index: 1,
              isVisible: _visibleCount >= 2,
            ),
            _buildBrainBenefitItem(
              iconPath: 'assets/images/healthy_eating/images/super potencia cerebral 3.png',
              title: 'Impulsa las funciones cerebrales',
              description: 'Contribuye a un mejor rendimiento mental.',
              index: 2,
              isVisible: _visibleCount >= 3,
            ),
            _buildBrainBenefitItem(
              iconPath: 'assets/images/healthy_eating/images/super potencia cerebral 4.png',
              title: 'Súper rendimiento',
              description: 'Una alimentación inteligente ayuda a que tu mente funcione mejor cada día.',
              index: 3,
              isVisible: _visibleCount >= 4,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
