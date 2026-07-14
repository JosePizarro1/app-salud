import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/widgets/custom_fade_in.dart';
import '../../widgets/meditation_painters.dart';

class MeditationPlayerView extends StatefulWidget {
  final int? selectedAudioIndex;
  final int selectedMinutes;
  final int currentAudioPosition;
  final int totalAudioDuration;
  final bool isAudioPaused;
  final bool showFeedback;
  final bool isSavingFeedback;
  final VoidCallback onTogglePause;
  final Function(int seconds) onSeekRelative;
  final VoidCallback onClose;
  final Function(String experience, String feeling) onSubmitFeedback;

  const MeditationPlayerView({
    super.key,
    required this.selectedAudioIndex,
    required this.selectedMinutes,
    required this.currentAudioPosition,
    required this.totalAudioDuration,
    required this.isAudioPaused,
    required this.showFeedback,
    required this.isSavingFeedback,
    required this.onTogglePause,
    required this.onSeekRelative,
    required this.onClose,
    required this.onSubmitFeedback,
  });

  @override
  State<MeditationPlayerView> createState() => _MeditationPlayerViewState();
}

class _MeditationPlayerViewState extends State<MeditationPlayerView> with SingleTickerProviderStateMixin {
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  final Random _random = Random();

  // Local feedback flow state
  int _feedbackStep = 1;
  String? _selectedExperience;
  String? _selectedFeeling;

  static const List<String> _audioTitles = [
    'Meditación de Calma Interior 🌸',
    'Conexión con tu Respiración 🌿',
    'Relajación Consciente 🌙',
    'Momento de Bienestar ✨',
  ];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Generate particles
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(random: _random));
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  String _formatTimeShort(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildFeedbackOverlay() {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          CustomFadeIn(
            duration: const Duration(milliseconds: 500),
            slideUp: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1F2C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _feedbackStep == 1
                    ? _buildFeedbackStep1()
                    : _buildFeedbackStep2(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackStep1() {
    return Column(
      key: const ValueKey('step1'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¿Cómo fue tu experiencia con esta meditación?',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Queremos conocer tu opinión',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        _buildExperienceOption('Positiva'),
        const SizedBox(height: 12),
        _buildExperienceOption('Neutral'),
        const SizedBox(height: 12),
        _buildExperienceOption('Negativa'),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1/2',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedExperience == null
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _feedbackStep = 2;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B8A74),
                  disabledBackgroundColor: const Color(0xFF1B8A74).withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  elevation: 0,
                ),
                child: Text(
                  'Continuar',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceOption(String option) {
    final bool isSelected = _selectedExperience == option;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedExperience = option;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2D3C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B8A74) : Colors.transparent,
            width: 2.2,
          ),
        ),
        child: Row(
          children: [
            Text(
              option,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1B8A74),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackStep2() {
    return Column(
      key: const ValueKey('step2'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¿Cómo te sientes ahora?',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Selecciona la sensación que mejor te describa',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        _buildFeelingOption('Relajado 🧘‍♂️'),
        const SizedBox(height: 8),
        _buildFeelingOption('Con energía ⚡'),
        const SizedBox(height: 8),
        _buildFeelingOption('Más tranquilo 🍃'),
        const SizedBox(height: 8),
        _buildFeelingOption('Distraído 🌀'),
        const SizedBox(height: 8),
        _buildFeelingOption('Con sueño 💤'),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _feedbackStep = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '2/2',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedFeeling == null || widget.isSavingFeedback
                    ? null
                    : () => widget.onSubmitFeedback(_selectedExperience!, _selectedFeeling!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B8A74),
                  disabledBackgroundColor: const Color(0xFF1B8A74).withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  elevation: 0,
                ),
                child: widget.isSavingFeedback
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Finalizar',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeelingOption(String option) {
    final bool isSelected = _selectedFeeling == option;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedFeeling = option;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2D3C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B8A74) : Colors.transparent,
            width: 2.2,
          ),
        ),
        child: Row(
          children: [
            Text(
              option,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1B8A74),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final circleSize = screenW * 0.6;
    final progress = widget.totalAudioDuration > 0
        ? widget.currentAudioPosition / widget.totalAudioDuration
        : 0.0;

    return Stack(
      key: const ValueKey('player_view'),
      fit: StackFit.expand,
      children: [
        // ── Dark relaxing background ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // ── Particle background ──
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  animValue: _particleController.value,
                  isPaused: widget.isAudioPaused,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),

        // ── Player UI or Feedback Card ──
        if (widget.showFeedback)
          _buildFeedbackOverlay()
        else
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 70),

                  // Title
                  CustomFadeIn(
                    duration: const Duration(milliseconds: 500),
                    slideUp: false,
                    child: Column(
                      children: [
                        Text(
                          _audioTitles[(widget.selectedAudioIndex ?? 1) - 1],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sesión de ${widget.selectedMinutes} ${widget.selectedMinutes == 1 ? 'minuto' : 'minutos'}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF88D49E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Circular progress timer ──
                  RepaintBoundary(
                    child: SizedBox(
                      width: circleSize,
                      height: circleSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background arc
                          SizedBox(
                            width: circleSize,
                            height: circleSize,
                            child: CustomPaint(
                              painter: CircularProgressPainter(
                                progress: progress,
                                trackColor: Colors.white.withValues(alpha: 0.1),
                                progressColor: const Color(0xFF88D49E),
                                strokeWidth: 8,
                              ),
                            ),
                          ),

                          // Progress indicator dot
                          SizedBox(
                            width: circleSize,
                            height: circleSize,
                            child: CustomPaint(
                              painter: ProgressDotPainter(
                                progress: progress,
                                dotColor: Colors.white,
                                dotSize: 14,
                              ),
                            ),
                          ),

                          // Play/Pause button in center
                          GestureDetector(
                            onTap: widget.onTogglePause,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.85),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.isAudioPaused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                size: 36,
                                color: const Color(0xFF2D3142),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Time display + controls ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rewind
                      GestureDetector(
                        onTap: () => widget.onSeekRelative(-10),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.replay_10_rounded, size: 22, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Time pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '${_formatTimeShort(widget.currentAudioPosition)} - ${_formatTimeShort(widget.totalAudioDuration)}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Forward
                      GestureDetector(
                        onTap: () => widget.onSeekRelative(10),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.forward_10_rounded, size: 22, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Stop button
                  TextButton.icon(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.stop_circle_outlined, size: 20),
                    label: Text(
                      'Terminar sesión',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent.shade200,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
