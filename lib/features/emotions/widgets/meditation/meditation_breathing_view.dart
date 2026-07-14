import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_fade_in.dart';

class MeditationBreathingView extends StatelessWidget {
  final int secondsRemaining;
  final int phaseSeconds;
  final String breathingPhase;
  final bool isConfiguring;
  final Animation<double> circleScaleAnimation;
  final VoidCallback onClose;

  const MeditationBreathingView({
    super.key,
    required this.secondsRemaining,
    required this.phaseSeconds,
    required this.breathingPhase,
    required this.isConfiguring,
    required this.circleScaleAnimation,
    required this.onClose,
  });

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getPhaseColor() {
    switch (breathingPhase) {
      case 'inhale':
        return AppColors.accent;
      case 'hold':
        return AppColors.secondary;
      case 'exhale':
        return AppColors.primary;
      default:
        return const Color(0xFF9083ED);
    }
  }

  String _getPhaseText() {
    switch (breathingPhase) {
      case 'inhale':
        return 'Inhala profundamente... 🌬️';
      case 'hold':
        return 'Sostén el aire... 🧘‍♂️';
      case 'exhale':
        return 'Exhala lentamente... 🍃';
      case 'hold_empty':
        return 'Pausa y relájate... ✨';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final double size = (media.size.width < media.size.height ? media.size.width : media.size.height) * 0.35;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Fixed Header (Timer countdown + close button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
                      ],
                    ),
                    child: Text(
                      _formatTime(secondsRemaining),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable / Centered Breathing Content (Circle & Texts)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Guided Breathing visual circle
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: circleScaleAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: size * circleScaleAnimation.value,
                                  height: size * circleScaleAnimation.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getPhaseColor().withValues(alpha: 0.12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getPhaseColor().withValues(alpha: 0.25),
                                        blurRadius: 35,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: circleScaleAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: size * (circleScaleAnimation.value * 0.8),
                                  height: size * (circleScaleAnimation.value * 0.8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        _getPhaseColor(),
                                        _getPhaseColor().withValues(alpha: 0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$phaseSeconds',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        CustomFadeIn(
                          key: ValueKey(breathingPhase),
                          duration: const Duration(milliseconds: 300),
                          slideUp: true,
                          child: Text(
                            _getPhaseText(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C5CA8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          isConfiguring 
                              ? 'Espera un momento mientras se configura...\nMantén los hombros relajados.'
                              : 'Mantén los hombros relajados e inhala por la nariz.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
