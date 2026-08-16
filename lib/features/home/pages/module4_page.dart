import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../app/services/background_music_manager.dart';
import '../../../app/services/sfx_manager.dart';
import '../widgets/module_header.dart';

class Module4Page extends StatefulWidget {
  const Module4Page({super.key});

  @override
  State<Module4Page> createState() => _Module4PageState();
}

class _Module4PageState extends State<Module4Page> {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isLampOff = false;
  bool _isRedButtonPressed = false;

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

  void _toggleLamp() async {
    SfxManager().playClick();
    HapticFeedback.mediumImpact();
    setState(() {
      _isRedButtonPressed = true;
      _isLampOff = !_isLampOff;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isRedButtonPressed = false);
    }
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
          // Background (Conmutado al presionar el botón rojo)
          Image.asset(
            _isLampOff
                ? 'assets/images/fondo_descanso_lampara_apagada.webp'
                : 'assets/images/fondo_modulo4_sueno_titi.webp',
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
                        0,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      _buildImageButton(
                        context,
                        'assets/images/modulo4_botones/boton3_modulosuenio_alarma.png',
                        '/alarm',
                        1,
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
                        2,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      _buildImageButton(
                        context,
                        'assets/images/modulo4_botones/boton4_modulosuenio_playlist.png',
                        '/playlist',
                        3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Botón Rojo Central (Interruptor de la Lámpara) ──
          Align(
            alignment: const Alignment(0, 0.75),
            child: AnimatedScale(
              scale: _isRedButtonPressed ? 0.85 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: _toggleLamp,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.16,
                  height: MediaQuery.of(context).size.width * 0.16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFF5252),
                        Color(0xFFD32F2F),
                        Color(0xFF8B0000),
                      ],
                      center: Alignment(-0.2, -0.2),
                      radius: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.6),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.power_settings_new_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(BuildContext context, String imagePath, String route, int index) {
    final double size = MediaQuery.of(context).size.width * 0.205;
    return _FloatingModuleButton(
      index: index,
      child: SizedBox(
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
                  color: Colors.white.withValues(alpha: 0.95),
                  blurRadius: 22,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: const Color(0xFFFFB74D).withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingModuleButton extends StatefulWidget {
  final int index;
  final Widget child;

  const _FloatingModuleButton({
    required this.index,
    required this.child,
  });

  @override
  State<_FloatingModuleButton> createState() => _FloatingModuleButtonState();
}

class _FloatingModuleButtonState extends State<_FloatingModuleButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3800 + (widget.index % 3) * 600),
    );

    _offsetAnimation = Tween<double>(begin: 0.0, end: -2.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 250), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnimation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
