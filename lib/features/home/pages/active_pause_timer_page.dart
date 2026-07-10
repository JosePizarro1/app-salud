import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

class ActivePauseExercise {
  final int number;
  final String title;
  final String description;
  final int durationSeconds;
  final Color color;
  final String imagePath;

  ActivePauseExercise({
    required this.number,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.color,
    required this.imagePath,
  });
}

class ActivePauseTimerPage extends StatefulWidget {
  final ActivePauseExercise exercise;

  const ActivePauseTimerPage({super.key, required this.exercise});

  @override
  State<ActivePauseTimerPage> createState() => _ActivePauseTimerPageState();
}

class _ActivePauseTimerPageState extends State<ActivePauseTimerPage>
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _showCelebration = false;
  bool _celebrationVisible = false; // Controls the fade animation
  bool _hasPlayedOnce = false;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.exercise.durationSeconds;
    _prepareAudio();
  }

  /// Pre-loads the audio source so playback is instant on completion
  Future<void> _prepareAudio() async {
    try {
      await _audioPlayer.setSource(AssetSource('audio/success_cheerful.mp3'));
      await _audioPlayer.setVolume(0.7);
      _audioReady = true;
    } catch (_) {
      _audioReady = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSuccessSound() async {
    try {
      if (_audioReady) {
        // Seek to start and play the pre-loaded audio
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.resume();
      } else {
        // Fallback: play directly if preload failed
        await _audioPlayer.play(
          AssetSource('audio/success_cheerful.mp3'),
          volume: 0.7,
        );
      }
    } catch (_) {
      // Silently fail if audio issue
    }
  }

  void _onTimerComplete() {
    _timer?.cancel();

    // Haptic feedback for a premium tactile feel
    HapticFeedback.mediumImpact();

    setState(() {
      _isRunning = false;
      _showCelebration = true;
    });

    // Trigger fade-in after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _celebrationVisible = true);
      }
    });

    _playSuccessSound();

    // Fade out the celebration after 3.5 seconds, then remove
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() => _celebrationVisible = false);
        // Remove the overlay widget after the fade-out completes
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _showCelebration = false);
          }
        });
      }
    });
  }

  void _toggleTimer() {
    // Haptic feedback on button press
    HapticFeedback.lightImpact();

    if (_remainingSeconds <= 0) {
      // Reset
      setState(() {
        _remainingSeconds = widget.exercise.durationSeconds;
        _isRunning = false;
        _showCelebration = false;
        _celebrationVisible = false;
        _hasPlayedOnce = false;
      });
      // Re-prepare audio for next round
      _prepareAudio();
      return;
    }

    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      if (!_hasPlayedOnce) {
        _playSuccessSound();
        _hasPlayedOnce = true;
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
          // Check if just reached 0
          if (_remainingSeconds <= 0) {
            _onTimerComplete();
          }
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  String get _timeString {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double progress = _remainingSeconds / widget.exercise.durationSeconds;
    bool isComplete = _remainingSeconds <= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 110,
        leading: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: widget.exercise.color),
            onPressed: () => context.pop(),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            'Pausa activa',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.exercise.color,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background decorations (to prevent it from being too white)
          Positioned(
            bottom: -30,
            left: -30,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(45 / 360),
              child: Icon(
                Icons.spa_rounded,
                size: 180,
                color: widget.exercise.color.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: -40,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(-20 / 360),
              child: Icon(
                Icons.directions_run_rounded,
                size: 160,
                color: widget.exercise.color.withValues(alpha: 0.10),
              ),
            ),
          ),
          // ── Main Content ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.exercise.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Image
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: Image.asset(
                        widget.exercise.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Timer Widget with animated progress
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 1.0, end: progress),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                              builder: (context, value, _) {
                                return CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 8,
                                  backgroundColor: widget.exercise.color
                                      .withValues(alpha: 0.15),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isComplete
                                        ? const Color(0xFF4CAF50)
                                        : widget.exercise.color,
                                  ),
                                  strokeCap: StrokeCap.round,
                                );
                              },
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isComplete)
                                FadeInUp(
                                  duration: const Duration(milliseconds: 400),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF4CAF50),
                                    size: 48,
                                  ),
                                )
                              else
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _timeString,
                                    key: ValueKey(_remainingSeconds),
                                    style: GoogleFonts.outfit(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2C2C2C),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description with animated transition
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        key: ValueKey(isComplete),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isComplete
                              ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                              : widget.exercise.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isComplete
                              ? '¡Excelente trabajo! Has completado este ejercicio. 🎉'
                              : widget.exercise.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color(0xFF2C2C2C),
                            height: 1.5,
                            fontWeight:
                                isComplete ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Play / Pause / Reset Button with scale animation
                    AnimatedScale(
                      scale: _isRunning ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: _toggleTimer,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isComplete
                                ? const Color(0xFF4CAF50)
                                : widget.exercise.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isComplete
                                        ? const Color(0xFF4CAF50)
                                        : widget.exercise.color)
                                    .withValues(alpha: 0.3),
                                blurRadius: _isRunning ? 20 : 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isComplete
                                  ? Icons.replay_rounded
                                  : (_isRunning
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded),
                              key: ValueKey(isComplete
                                  ? 'replay'
                                  : (_isRunning ? 'pause' : 'play')),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // ── Lottie Celebration Overlay with fade ──
          if (_showCelebration)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _celebrationVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: Container(
                    color: Colors.transparent,
                    child: DotLottieView(
                      sourceType: 'asset',
                      source: 'assets/lottie/success_celebration.lottie',
                      autoplay: true,
                      loop: false,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
