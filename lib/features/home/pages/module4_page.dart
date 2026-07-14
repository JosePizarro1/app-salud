import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../app/services/background_music_manager.dart';
import '../widgets/module_header.dart';

class Module4Page extends StatefulWidget {
  const Module4Page({super.key});

  @override
  State<Module4Page> createState() => _Module4PageState();
}

class _Module4PageState extends State<Module4Page> {
  final AudioPlayer _sfxPlayer = AudioPlayer();

  Future<void> _playTapSound() async {
    if (!BackgroundMusicManager().isPlaying) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(
        AssetSource('audio/sonido_cuando dejan de arratrar.wav'),
        volume: 0.8,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo_modulo4_sueno_titi.webp',
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // DESCANSO letrero — centered, 60% above vertical center
          Align(
            alignment: const Alignment(0, -0.6),
            child: Image.asset(
              'assets/images/letreros/DESCANSO.webp',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),
          ),

          // Navigation buttons: 2×2 grid — columns pushed to screen edges
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left column
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildImageButton(
                        context,
                        'assets/images/modulo4_botones/boton1_modulosuenio_lectura_sueno.png',
                        '/sleep_care',
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      _buildImageButton(
                        context,
                        'assets/images/modulo4_botones/boton3_modulosuenio_alarma.png',
                        '/alarm',
                      ),
                    ],
                  ),
                  // Right column
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildImageButton(
                        context,
                        'assets/images/modulo4_botones/boton2_modulosuenio_rutina_nocturna.png',
                        '/night_routine',
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      _buildImageButton(
                        context,
                        'assets/images/modulo4_botones/boton4_modulosuenio_playlist.png',
                        '/playlist',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(BuildContext context, String imagePath, String route) {
    final double size = MediaQuery.of(context).size.width * 0.205;
    return SizedBox(
      width: size,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: () {
          HapticFeedback.mediumImpact();
          _playTapSound();
          context.push(route);
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
