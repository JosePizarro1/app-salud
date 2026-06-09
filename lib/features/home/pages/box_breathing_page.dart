import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../app/theme/app_colors.dart';
import '../widgets/module_header.dart';

enum BreathingPhase { inhale, hold, exhale, holdEmpty, done }

class BoxBreathingPage extends StatefulWidget {
  const BoxBreathingPage({super.key});

  @override
  State<BoxBreathingPage> createState() => _BoxBreathingPageState();
}

class _BoxBreathingPageState extends State<BoxBreathingPage> with TickerProviderStateMixin {
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _currentCycle = 1;
  int _secondsLeft = 4;
  Timer? _timer;

  // Lottie Celebration
  bool _showCelebration = false;
  bool _celebrationVisible = false;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioReady = false;

  // Controladores de animación
  late AnimationController _progressController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _prepareAudio();
    _startPhase(BreathingPhase.inhale);
  }

  Future<void> _prepareAudio() async {
    try {
      await _audioPlayer.setSource(AssetSource('audio/completado_sonid.mp3'));
      await _audioPlayer.setVolume(0.7);
      _audioReady = true;
    } catch (_) {
      _audioReady = false;
    }
  }

  Future<void> _playSuccessSound() async {
    try {
      if (_audioReady) {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(
          AssetSource('audio/completado_sonid.mp3'),
          volume: 0.7,
        );
      }
    } catch (_) {
      // Silently fail if audio issue
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startPhase(BreathingPhase phase) {
    if (!mounted) return;
    setState(() {
      _currentPhase = phase;
      if (phase == BreathingPhase.inhale) {
        _secondsLeft = 4;
        _progressController.duration = const Duration(seconds: 4);
        _progressController.forward(from: 0.0);
      } else if (phase == BreathingPhase.hold) {
        _secondsLeft = 4;
        _progressController.duration = const Duration(seconds: 4);
        _progressController.value = 1.0; // Mantiene el progreso lleno
      } else if (phase == BreathingPhase.exhale) {
        _secondsLeft = 4;
        _progressController.duration = const Duration(seconds: 4);
        _progressController.reverse(from: 1.0); // Se vacía el progreso
      } else if (phase == BreathingPhase.holdEmpty) {
        _secondsLeft = 4;
        _progressController.duration = const Duration(seconds: 4);
        _progressController.value = 0.0; // Mantiene el progreso vacío
      } else if (phase == BreathingPhase.done) {
        _progressController.stop();
        _showCelebration = true;
        _playSuccessSound();
        HapticFeedback.mediumImpact();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _celebrationVisible = true);
          }
        });

        // Ocultar la celebración después de 3.5 segundos
        Future.delayed(const Duration(milliseconds: 3500), () {
          if (mounted) {
            setState(() => _celebrationVisible = false);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() => _showCelebration = false);
              }
            });
          }
        });
      }
    });

    _timer?.cancel();
    if (phase != BreathingPhase.done) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          if (_secondsLeft > 1) {
            _secondsLeft--;
          } else {
            timer.cancel();
            _nextPhase();
          }
        });
      });
    }
  }

  void _nextPhase() {
    if (_currentPhase == BreathingPhase.inhale) {
      _startPhase(BreathingPhase.hold);
    } else if (_currentPhase == BreathingPhase.hold) {
      _startPhase(BreathingPhase.exhale);
    } else if (_currentPhase == BreathingPhase.exhale) {
      _startPhase(BreathingPhase.holdEmpty);
    } else if (_currentPhase == BreathingPhase.holdEmpty) {
      if (_currentCycle < 4) {
        setState(() {
          _currentCycle++;
        });
        _startPhase(BreathingPhase.inhale);
      } else {
        _startPhase(BreathingPhase.done);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo de pantalla del módulo 2
          Image.asset(
            'assets/images/fondo_modulo2.PNG',
            fit: BoxFit.cover,
          ),

          // Tarjeta central (coordenada exacta igual que relax_page.dart)
          Positioned(
            top: screenHeight * 0.21,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.success,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _currentPhase == BreathingPhase.done
                    ? _buildSuccessView(screenHeight)
                    : _buildExerciseView(screenHeight),
              ),
            ),
          ),

          // Encabezado principal (Home y Emergencia)
          const ModuleHeader(showHome: true),

          // Animación de celebración Lottie (éxito)
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

  Widget _buildExerciseView(double screenHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Texto instructivo en la parte superior
        Text(
          'Procura repetirlo entre 4 a 6 ciclos',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 12),

        // Transición de textos superior según la fase
        SizedBox(
          height: 80,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildPhaseText(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Círculo de respiración con crecimiento y encogimiento según fase
        AnimatedBuilder(
          animation: Listenable.merge([_progressController, _pulseController]),
          builder: (context, child) {
            double scale = 1.0;
            if (_currentPhase == BreathingPhase.inhale) {
              scale = 1.0 + (0.3 * _progressController.value); // Crece de 1.0 a 1.3
            } else if (_currentPhase == BreathingPhase.hold) {
              scale = 1.3 + 0.03 * math.sin(_pulseController.value * 2 * math.pi); // Pulsa suavemente a 1.3
            } else if (_currentPhase == BreathingPhase.exhale) {
              scale = 1.0 + (0.3 * _progressController.value); // Decrece de 1.3 a 1.0
            } else if (_currentPhase == BreathingPhase.holdEmpty) {
              scale = 1.0 + 0.015 * math.sin(_pulseController.value * 2 * math.pi); // Pulsa sutilmente a 1.0
            }

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: _getPhaseColor().withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: BreathingCirclePainter(
                    progress: _progressController.value,
                    phase: _currentPhase,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getPhaseLabel(),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_secondsLeft}s',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _getPhaseColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Contador de Ciclos
        Text(
          'Ciclo $_currentCycle de 4',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSuccessView(double screenHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        // Globo de diálogo personalizado de Titi
        CustomPaint(
          painter: SpeechBubblePainter(),
          child: Container(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Pulse(
                  infinite: true,
                  duration: const Duration(seconds: 2),
                  child: Text(
                    '¡EXCELENTE!',
                    style: GoogleFonts.outfit(
                      color: AppColors.success,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: AppColors.success.withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                        Shadow(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estás equilibrando tu respiración y ayudando a tu mente a mantenerse tranquila y enfocada.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Gato del home (Video.gif)
        SizedBox(
          height: screenHeight * 0.22,
          child: Image.asset(
            'assets/images/Video.gif',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),

        // Botón Back para regresar (guiándose de breathing_page.dart)
        _ActionButton(
          imagePath: 'assets/images/boton_back.png',
          baseScale: 1.15,
          onTap: () {
            context.pop();
          },
          todoComment: 'Regresar',
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPhaseText() {
    String text1 = '';
    String text2 = '';

    if (_currentPhase == BreathingPhase.inhale) {
      text1 = 'Inhala por la nariz ';
      text2 = 'durante...';
    } else if (_currentPhase == BreathingPhase.hold) {
      text1 = 'Mantén el aire ';
      text2 = 'durante...';
    } else if (_currentPhase == BreathingPhase.exhale) {
      text1 = 'Exhala lentamente por la boca ';
      text2 = 'durante...';
    } else if (_currentPhase == BreathingPhase.holdEmpty) {
      text1 = 'Mantén sin aire ';
      text2 = 'durante...';
    }

    return RichText(
      key: ValueKey(_currentPhase),
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          height: 1.25,
        ),
        children: [
          TextSpan(
            text: text1,
            style: TextStyle(color: AppColors.secondary),
          ),
          TextSpan(
            text: text2,
            style: TextStyle(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return AppColors.success;
      case BreathingPhase.hold:
        return AppColors.secondary;
      case BreathingPhase.exhale:
        return AppColors.primary;
      case BreathingPhase.holdEmpty:
        return AppColors.accent;
      case BreathingPhase.done:
        return AppColors.success;
    }
  }

  String _getPhaseLabel() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Inhala';
      case BreathingPhase.hold:
        return 'Retén';
      case BreathingPhase.exhale:
        return 'Exhala';
      case BreathingPhase.holdEmpty:
        return 'Vacío';
      case BreathingPhase.done:
        return 'Listo';
    }
  }
}

// Pintor del círculo de progreso con gradientes y estilos adaptados para 4 fases
class BreathingCirclePainter extends CustomPainter {
  final double progress;
  final BreathingPhase phase;

  BreathingCirclePainter({required this.progress, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 10.0;

    // Pintar fondo del círculo
    final bgPaint = Paint()
      ..color = const Color(0xFFE2DED6).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Pintar arco de progreso
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (phase == BreathingPhase.inhale) {
      progressPaint.color = AppColors.success;
      progressPaint.strokeWidth = strokeWidth;
    } else if (phase == BreathingPhase.hold) {
      progressPaint.color = AppColors.secondary;
      progressPaint.strokeWidth = strokeWidth + 2.0;
    } else if (phase == BreathingPhase.exhale) {
      progressPaint.color = AppColors.primary;
      progressPaint.strokeWidth = strokeWidth;
    } else if (phase == BreathingPhase.holdEmpty) {
      progressPaint.color = AppColors.accent;
      progressPaint.strokeWidth = strokeWidth + 2.0;
    }

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BreathingCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phase != phase;
  }
}

// Dibujo del globo de diálogo estilo comic con borde morado suave
class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.4) // Soft lavender outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 // Softer thickness
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final radius = 16.0;
    final arrowHeight = 12.0;
    final arrowWidth = 16.0;

    // Cuerpo principal
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - arrowHeight),
      Radius.circular(radius),
    ));

    // Flecha indicadora apuntando abajo
    final arrowLeft = (size.width - arrowWidth) / 2;
    final arrowPath = Path();
    arrowPath.moveTo(arrowLeft, size.height - arrowHeight);
    arrowPath.lineTo(arrowLeft + arrowWidth / 2, size.height);
    arrowPath.lineTo(arrowLeft + arrowWidth, size.height - arrowHeight);
    arrowPath.close();

    path.addPath(arrowPath, Offset.zero);

    // Draw soft premium drop shadow
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.04),
      6.0,
      true,
    );

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final String todoComment;
  final double baseScale;

  const _ActionButton({
    required this.imagePath,
    required this.onTap,
    required this.todoComment,
    this.baseScale = 1.0,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? (widget.baseScale * 0.95) : widget.baseScale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Image.asset(
            widget.imagePath,
            height: 65,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
