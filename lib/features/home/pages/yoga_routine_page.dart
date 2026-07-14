import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../widgets/module_header.dart';
import '../../../app/services/background_music_manager.dart';
import '../services/yoga_storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class YogaRoutinePage extends StatefulWidget {
  const YogaRoutinePage({super.key});

  @override
  State<YogaRoutinePage> createState() => _YogaRoutinePageState();
}

class _YogaRoutinePageState extends State<YogaRoutinePage> {
  final AudioPlayer _yogaAudioPlayer = AudioPlayer()
    ..setAudioContext(AudioContext(
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
      ),
    ));

  bool _hasPlayed = false;

  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  static const List<Map<String, dynamic>> _postures = [
    {
      'title': 'Postura del Niño',
      'image': 'assets/images/ModuloYoga/postura_1_yoga.webp',
      'description': 'Arrodíllate en el suelo, siéntate sobre tus talones y dobla el torso hacia adelante, extendiendo los brazos al frente. Apoya la frente en el suelo y respira profundamente para liberar tensión en la espalda.',
      'benefits': [
        'Alivia la ansiedad y la depresión.',
        'Relaja los músculos de la espalda.',
        'Calma la mente de forma natural.'
      ],
    },
    {
      'title': 'Postura de Zancada Alta',
      'image': 'assets/images/ModuloYoga/postura_2_yoga.webp',
      'description': 'Da un gran paso hacia atrás con un pie, mantén la pierna trasera estirada y la rodilla delantera doblada a 90 grados. Eleva los brazos hacia el cielo, abre el pecho y siente la fuerza en tus piernas.',
      'benefits': [
        'Fortalece las piernas y rodillas.',
        'Mejora la concentración mental.',
        'Expande el pecho y los pulmones.'
      ],
    },
    {
      'title': 'Postura de la Mariposa',
      'image': 'assets/images/ModuloYoga/postura_3_yoga.webp',
      'description': 'Siéntate con la espalda recta, junta las plantas de tus pies y deja que las rodillas caigan suavemente hacia los lados. Sujeta tus pies con las manos y realiza movimientos suaves para estirar las caderas.',
      'benefits': [
        'Abre y relaja las caderas.',
        'Libera el estrés acumulado.',
        'Mejora la circulación abdominal.'
      ],
    },
    {
      'title': 'Postura de la Montaña',
      'image': 'assets/images/ModuloYoga/postura_4_yoga.webp',
      'description': 'Párate derecho con los pies juntos, los brazos a los lados del cuerpo y el peso distribuido uniformemente. Activa tu abdomen, alinea tu columna y respira con calma, sintiendo estabilidad y firmeza.',
      'benefits': [
        'Mejora tu postura corporal.',
        'Aumenta la estabilidad física.',
        'Promueve la respiración profunda.'
      ],
    },
    {
      'title': 'Postura de Piernas a la Pared',
      'image': 'assets/images/ModuloYoga/postura_5_yoga.webp',
      'description': 'Acuéstate sobre tu espalda y eleva las piernas apoyándolas verticalmente contra la pared. Mantén tus brazos relajados a los lados y disfruta de esta postura restaurativa que mejora la circulación.',
      'benefits': [
        'Aumenta el flujo sanguíneo al cerebro.',
        'Alivia piernas pesadas y cansadas.',
        'Regula tu sistema nervioso.'
      ],
    },
    {
      'title': 'Postura Parada de Hombros',
      'image': 'assets/images/ModuloYoga/postura_6_yoga.webp',
      'description': 'Acuéstate boca arriba, eleva las piernas y la cadera apoyándolas con las manos en la espalda baja para soporte. Mantén el peso en los hombros (no en el cuello) y respira con cuidado para calmar la mente.',
      'benefits': [
        'Mejora la claridad mental.',
        'Estabiliza tus emociones.',
        'Estimula la glándula tiroides.'
      ],
    },
  ];

  static const Map<int, List<Map<String, String>>> _postureSteps = {
    0: [
      {'image': 'assets/images/ModuloYoga/pasos/postura_1_paso_1.webp', 'text': 'Paso 1: Arrodíllate sobre la colchoneta con los pies juntos y siéntate sobre tus talones.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_1_paso_2.webp', 'text': 'Paso 2: Mantén la espalda recta y coloca las manos suavemente sobre tus rodillas.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_1_paso_3.webp', 'text': 'Paso 3: Exhala y desliza el torso hacia adelante, extendiendo los brazos al frente sobre el suelo.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_1_paso_4.webp', 'text': 'Paso 4: Apoya la frente en la colchoneta y relaja completamente los hombros y la espalda.'},
    ],
    1: [
      {'image': 'assets/images/ModuloYoga/pasos/postura_2_paso_1.webp', 'text': 'Paso 1: Comienza de pie en el centro de tu colchoneta con el cuerpo erguido.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_2_paso_2.webp', 'text': 'Paso 2: Da un paso largo hacia atrás con tu pie izquierdo, manteniendo el talón elevado.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_2_paso_3.webp', 'text': 'Paso 3: Flexiona tu rodilla delantera derecha a 90 grados, asegurando que no pase de la punta del pie.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_2_paso_4.webp', 'text': 'Paso 4: Eleva los brazos estirados hacia el cielo con las palmas mirándose y abre tu pecho.'},
    ],
    2: [
      {'image': 'assets/images/ModuloYoga/pasos/postura_3_paso_1.webp', 'text': 'Paso 1: Siéntate en el suelo con las piernas extendidas al frente and la espalda erguida.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_3_paso_2.webp', 'text': 'Paso 2: Flexiona ambas rodillas, junta las plantas de tus pies y llévalos cerca de tu pelvis.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_3_paso_3.webp', 'text': 'Paso 3: Sujeta firmemente tus pies o tobillos con ambas manos mientras mantienes los hombros relajados.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_3_paso_4.webp', 'text': 'Paso 4: Presiona suavemente las rodillas hacia el suelo e inclina el torso al frente desde la cadera.'},
    ],
    3: [
      {'image': 'assets/images/ModuloYoga/pasos/postura_4_paso_1.webp', 'text': 'Paso 1: Párate derecho con los pies juntos, activando los muslos y el abdomen.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_4_paso_2.webp', 'text': 'Paso 2: Lleva las palmas de tus manos juntas al centro del pecho en posición de oración.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_4_paso_3.webp', 'text': 'Paso 3: Estira tus brazos hacia arriba por encima de la cabeza, manteniendo los hombros relajados.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_4_paso_4.webp', 'text': 'Paso 4: Entrelaza los dedos y empuja con las palmas hacia arriba, alarga todo tu cuerpo.'},
    ],
    4: [
      {'image': 'assets/images/ModuloYoga/pasos/postura_5_paso_1.webp', 'text': 'Paso 1: Coloca tu colchoneta perpendicular a la pared y siéntate de lado muy cerca de ella.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_5_paso_2.webp', 'text': 'Paso 2: Recuesta tu espalda sobre el suelo y gira tu cuerpo para elevar las piernas apoyándolas en la pared.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_5_paso_3.webp', 'text': 'Paso 3: Asegura que tus glúteos queden lo más cerca posible de la base de la pared.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_5_paso_4.webp', 'text': 'Paso 4: Extiende tus brazos a los lados con las palmas hacia arriba y respira con tranquilidad.'},
    ],
    5: [
      {'image': 'assets/images/ModuloYoga/pasos/postura_6_paso_1.webp', 'text': 'Paso 1: Acuéstate boca arriba sobre la colchoneta con los brazos extendidos a los lados del cuerpo.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_6_paso_2.webp', 'text': 'Paso 2: Dobla tus rodillas acercando los talones a la cadera con los pies apoyados en el suelo.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_6_paso_3.webp', 'text': 'Paso 3: Impulsa tus caderas y piernas hacia arriba apoyando tus manos firmemente en la espalda baja.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_6_paso_4.webp', 'text': 'Paso 4: Sigue presionando las palmas de las manos contra la espalda; siente cómo tu cuerpo se estira y se vuelve recto.'},
      {'image': 'assets/images/ModuloYoga/pasos/postura_6_paso_5.webp', 'text': 'Paso 5: Respira profundamente varias veces antes de soltar suavemente la postura.'},
    ],
  };

  @override
  void initState() {
    super.initState();
    // 1. Temporarily suspend general background music without changing user preference
    BackgroundMusicManager().suspendMusic();

    // 2. Configure player
    _yogaAudioPlayer.setReleaseMode(ReleaseMode.loop);

    // 3. Start audio if enabled in preferences
    _handleSoundToggle();

    // 4. Listen to sound updates
    BackgroundMusicManager().isPlayingNotifier.addListener(_handleSoundToggle);

    // 5. Listen to internet connection updates to sync dynamically
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasConnection = results.any((result) => result != ConnectivityResult.none);
      if (hasConnection) {
        YogaStorageService.syncPendingData();
      }
    });

    // 6. Trigger initial background sync
    YogaStorageService.syncPendingData();
  }

  @override
  void dispose() {
    BackgroundMusicManager().isPlayingNotifier.removeListener(_handleSoundToggle);
    _connectivitySubscription.cancel();
    _yogaAudioPlayer.dispose();
    // Restore background music when leaving the page
    BackgroundMusicManager().unsuspendMusic();
    super.dispose();
  }

  void _handleSoundToggle() {
    final isPlaying = BackgroundMusicManager().isPlaying;
    if (isPlaying) {
      if (!_hasPlayed) {
        _yogaAudioPlayer.play(AssetSource('audio/audio_yoga.mp3'));
        _hasPlayed = true;
      } else {
        _yogaAudioPlayer.resume();
      }
    } else {
      _yogaAudioPlayer.pause();
    }
  }

  void _showPostureDetail(BuildContext context, Map<String, dynamic> posture) async {
    // Record yoga practice on click (offline-first)
    await YogaStorageService.recordPractice();
    
    final index = _postures.indexOf(posture);
    final steps = _postureSteps[index] ?? [];
    
    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return FadeIn(
          duration: const Duration(milliseconds: 300),
          child: _PostureDetailDialog(posture: posture, steps: steps),
        );
      },
    );

    if (completed == true && context.mounted) {
      _showBenefitsOverlay(context, posture);
    }
  }

  void _showBenefitsOverlay(BuildContext context, Map<String, dynamic> posture) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) {
        return _BenefitsDialog(posture: posture);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo_modulo2.webp',
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),

          // Central Card
          Positioned(
            top: screenHeight * 0.18, // Spaces of respect (safe below header)
            bottom: screenHeight * 0.04, // Spaces of respect (above bottom)
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
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
                child: Column(
                  children: [
                    // Header / Title: "Rutina de Yoga"
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Rutina de ',
                            style: TextStyle(color: AppColors.secondary),
                          ),
                          TextSpan(
                            text: 'Yoga',
                            style: TextStyle(color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scrollable list of postures
                    Expanded(
                      child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        thickness: 4,
                        radius: const Radius.circular(10),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: List.generate(_postures.length, (index) {
                              final posture = _postures[index];
                              // Escalas de ancho individuales para cada postura:
                              double widthScale = 1.0;
                              if (index == 0) {
                                // Postura 1: Postura del Niño
                                widthScale = 1.0;
                              } else if (index == 1) {
                                // Postura 2: Postura de Zancada Alta
                                widthScale = 0.98;
                              } else if (index == 2) {
                                // Postura 3: Postura de la Mariposa
                                widthScale = 0.94; // -5% de ancho
                              } else if (index == 3) {
                                // Postura 4: Postura de la Montaña
                                widthScale = 0.93; // -5% de ancho
                              } else if (index == 4) {
                                // Postura 5: Postura de Piernas a la Pared
                                widthScale = 0.90; // -9% de ancho
                              } else if (index == 5) {
                                // Postura 6: Postura Parada de Hombros
                                widthScale = 0.85; // -15% de ancho
                              }
                              return _PostureButton(
                                imagePath: posture['image']!,
                                widthScale: widthScale,
                                onTap: () => _showPostureDetail(context, posture),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Header with Home, Back & Emergency Buttons
          const ModuleHeader(showHome: true, showBack: true),
        ],
      ),
    );
  }
}

class _PostureButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final double widthScale;

  const _PostureButton({
    required this.imagePath,
    required this.onTap,
    this.widthScale = 1.0,
  });

  @override
  State<_PostureButton> createState() => _PostureButtonState();
}

class _PostureButtonState extends State<_PostureButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.05, // Subtle premium scale bounce effect
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
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Transform.scale(
            scaleX: widget.widthScale,
            child: Image.asset(
              widget.imagePath,
              height: 72, // Perfect height for premium visuals in the card
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _PostureDetailDialog extends StatefulWidget {
  final Map<String, dynamic> posture;
  final List<Map<String, String>> steps;

  const _PostureDetailDialog({
    required this.posture,
    required this.steps,
  });

  @override
  State<_PostureDetailDialog> createState() => _PostureDetailDialogState();
}

class _PostureDetailDialogState extends State<_PostureDetailDialog> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  int _currentStep = 0;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _handleAutoNext();
        }
      });
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache all step images to avoid flickering when swiping pages
    for (final step in widget.steps) {
      final imgPath = step['image'];
      if (imgPath != null) {
        precacheImage(AssetImage(imgPath), context);
      }
    }
  }

  void _handleAutoNext() {
    if (_currentStep < widget.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Loop back to the first step
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _animationController.stop();
      } else {
        if (_animationController.isCompleted) {
          _animationController.reset();
        }
        _animationController.forward();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.success,
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Posture Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32), // Spacer to center the title
                Expanded(
                  child: Text(
                    widget.posture['title']!,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Image Container (PageView)
            GestureDetector(
              onTap: _togglePlayPause,
              child: SizedBox(
                height: 280, // Increased height significantly
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      _currentStep = page;
                      if (_isPlaying) {
                        _animationController.forward(from: 0.0);
                      } else {
                        _animationController.value = 0.0;
                      }
                    });
                  },
                  itemCount: widget.steps.length,
                  itemBuilder: (context, index) {
                    final step = widget.steps[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFF9FAFC),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          step['image']!,
                          fit: BoxFit.contain, // Fits perfectly with no cropping
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Step Indicator & Auto-Play Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Paso ${_currentStep + 1} de ${widget.steps.length}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Step Text Description
            SizedBox(
              height: 70, // Fixed height to prevent resizing dialog on different texts
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  widget.steps[_currentStep]['text']!,
                  style: GoogleFonts.outfit(
                    fontSize: 16, // Slightly larger text
                    fontWeight: widget.steps[_currentStep]['text']!.length > 100
                        ? FontWeight.w500
                        : FontWeight.w600,
                    color: AppColors.textPrimaryLight.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Actions Row: Anterior, Play/Pause Indicator, Siguiente
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Anterior Button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: _currentStep > 0 ? AppColors.secondary : Colors.grey.withValues(alpha: 0.3),
                  onPressed: _currentStep > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),

                // Play / Pause / Finish Circular Progress
                Builder(
                  builder: (context) {
                    final bool isLastStep = _currentStep == widget.steps.length - 1;
                    return GestureDetector(
                      onTap: isLastStep ? () => Navigator.of(context).pop(true) : _togglePlayPause,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Always show circular progress — on last step it fills then loops
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return CircularProgressIndicator(
                                  value: _animationController.value,
                                  strokeWidth: 4,
                                  color: AppColors.success,
                                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              isLastStep
                                  ? Icons.check_rounded
                                  : (_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                              color: AppColors.success,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),

                // Siguiente Button
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  color: _currentStep < widget.steps.length - 1 ? AppColors.secondary : Colors.grey.withValues(alpha: 0.3),
                  onPressed: _currentStep < widget.steps.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitsDialog extends StatefulWidget {
  final Map<String, dynamic> posture;
  const _BenefitsDialog({required this.posture});

  @override
  State<_BenefitsDialog> createState() => _BenefitsDialogState();
}

class _BenefitsDialogState extends State<_BenefitsDialog> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _showCard = false;
  int _currentBenefitIndex = 0;
  Timer? _benefitTimer;

  @override
  void initState() {
    super.initState();
    _playSound();
    // Tarjeta aparece casi de inmediato para coincidir mejor con el sonido
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _showCard = true);
        _startBenefitRotation();
      }
    });
  }

  void _startBenefitRotation() {
    final benefitsList = widget.posture['benefits'] as List<String>? ?? ['Beneficios para tu cuerpo y mente.'];
    if (benefitsList.length > 1) {
      _benefitTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          setState(() {
            _currentBenefitIndex = (_currentBenefitIndex + 1) % benefitsList.length;
          });
        }
      });
    }
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.setSource(AssetSource('audio/success_cheerful.mp3'));
      await _audioPlayer.setVolume(0.7);
      await _audioPlayer.resume();
    } catch (_) {}
  }

  @override
  void dispose() {
    _benefitTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lottie Animation Overlay
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
        // Benefits Card Premium
        if (_showCard)
          Center(
            child: ZoomIn(
              duration: const Duration(milliseconds: 400), // Más rápido
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF4FAFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 3 Estrellas Animadas (Mucha menos demora)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 44),
                          ),
                          const SizedBox(width: 8),
                          ZoomIn(
                            delay: const Duration(milliseconds: 300),
                            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 64),
                          ),
                          const SizedBox(width: 8),
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 44),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Título
                      FadeIn(
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          '¡Excelente Trabajo!',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [AppColors.secondary, AppColors.primary],
                              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Separador elegante
                      FadeIn(
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Caja de Beneficios
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.success,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 0.2),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    (widget.posture['benefits'] as List<String>?)?[_currentBenefitIndex] ?? 'Beneficios para tu cuerpo y mente.',
                                    key: ValueKey<int>(_currentBenefitIndex),
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimaryLight,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Botón - Círculo Verde
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.success, Color(0xFF43A047)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
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
}
