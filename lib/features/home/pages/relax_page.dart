import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../widgets/module_header.dart';

import '../../../app/services/sfx_manager.dart';

import 'package:audioplayers/audioplayers.dart';
import '../../../app/services/background_music_manager.dart';

class RelaxPage extends StatefulWidget {
  const RelaxPage({super.key});

  @override
  State<RelaxPage> createState() => _RelaxPageState();
}

class _RelaxPageState extends State<RelaxPage> with WidgetsBindingObserver {
  final AudioPlayer _relaxAudioPlayer = AudioPlayer()
    ..setAudioContext(AudioContext(
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
      ),
    ));

  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 1. Temporarily suspend general background music without changing user preference
    BackgroundMusicManager().suspendMusic();

    // 2. Configure player
    _relaxAudioPlayer.setReleaseMode(ReleaseMode.loop);

    // 3. Start audio if enabled in preferences
    _handleSoundToggle();

    // 4. Listen to sound updates
    BackgroundMusicManager().isPlayingNotifier.addListener(_handleSoundToggle);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundMusicManager().isPlayingNotifier.removeListener(_handleSoundToggle);
    _relaxAudioPlayer.dispose();
    // Restore background music when leaving the page
    BackgroundMusicManager().unsuspendMusic();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      try {
        _relaxAudioPlayer.pause();
      } catch (_) {}
    } else if (state == AppLifecycleState.resumed) {
      _handleSoundToggle();
    }
  }

  void _handleSoundToggle() {
    final isPlaying = BackgroundMusicManager().isPlaying;
    if (isPlaying) {
      if (!_hasPlayed) {
        _relaxAudioPlayer.play(AssetSource('audio/audio_yoga.mp3'));
        _hasPlayed = true;
      } else {
        _relaxAudioPlayer.resume();
      }
    } else {
      _relaxAudioPlayer.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

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

          // Central Card (respecting safe areas and header spaces, wrapping content dynamically)
          Positioned(
            top: screenHeight * 0.21, // Safe space below the header (lowered by 6% from 0.15)
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
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Wrap content dynamically!
                  children: [
                    // Title and Description
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Relaja tu ',
                            style: TextStyle(color: AppColors.secondary),
                          ),
                          TextSpan(
                            text: 'cuerpo',
                            style: TextStyle(color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rutinas para después de clases o evaluaciones intensas que te ayudarán a relajarte y recuperar tu equilibrio.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons (Stacked)
                    Column(
                      children: [
                        // Botón de "Relajación profunda 4-7-8"
                        _ActionButton(
                          imagePath: 'assets/images/ModuloYoga/boton_relajacion_profunda.webp',
                          baseScale: 1.27, // Increased scale (total 1.27)
                          onTap: () {
                            _showInstructionBottomSheet(
                              context,
                              title: 'Relajación Profunda 4-7-8',
                              subtitle: 'Esta técnica de respiración actúa como un tranquilizante natural para el sistema nervioso, ideal para relajarte y liberar el estrés.',
                              routePath: '/breathing',
                            );
                          },
                          todoComment: 'Relajación profunda 4-7-8',
                        ),
                        const SizedBox(height: 8),
                        // Botón de "Respiración equilibrada"
                        _ActionButton(
                          imagePath: 'assets/images/ModuloYoga/boton_respiracion_equilibrada.webp',
                          baseScale: 1.37, // Increased scale (total 1.37)
                          onTap: () {
                            _showInstructionBottomSheet(
                              context,
                              title: 'Respiración Equilibrada (Caja)',
                              subtitle: 'Técnica utilizada para calmar la mente y mejorar la concentración, ideal después de estudiar o rendir evaluaciones.',
                              routePath: '/box_breathing',
                            );
                          },
                          todoComment: 'Respiración equilibrada',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Character GIF at the bottom (2x speed modified, responsive layout)
                    Container(
                      height: screenHeight * 0.22,
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        'assets/images/ModuloYoga/titi_modulo_yoga.webp',
                        fit: BoxFit.contain,
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

  void _showInstructionBottomSheet(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String routePath,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Bar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Button - Start Now
              ElevatedButton(
                onPressed: () {
                  SfxManager().playClick();
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                  context.push(routePath);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.success.withValues(alpha: 0.3),
                ),
                child: Text(
                  'Empezar Ahora',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
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
          SfxManager().playClick();
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Image.asset(
            widget.imagePath,
            height: 65, // Altura óptima para legibilidad y estética premium móvil
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
