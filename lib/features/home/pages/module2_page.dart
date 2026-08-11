import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/module_header.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/services/sfx_manager.dart';

class Module2Page extends StatefulWidget {
  const Module2Page({super.key});

  @override
  State<Module2Page> createState() => _Module2PageState();
}

class _Module2PageState extends State<Module2Page> {
  // Estado de escala para los 2 botones
  bool _isPrecached = false;
  final List<bool> _buttonScales = [false, false];
  int _videoAnimKey = 0;

  Future<void> _triggerScale(int index) async {
    setState(() => _buttonScales[index] = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _buttonScales[index] = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      // Precache assets for the sub-pages of Bienestar Físico (Yoga and Relax)
      precacheImage(const AssetImage('assets/images/ModuloYoga/boton_relajacion_profunda.webp'), context);
      precacheImage(const AssetImage('assets/images/ModuloYoga/boton_respiracion_equilibrada.webp'), context);
      precacheImage(const AssetImage('assets/images/ModuloYoga/titi_modulo_yoga.webp'), context);
      precacheImage(const AssetImage('assets/images/ModuloYoga/postura_1_yoga.webp'), context);
      precacheImage(const AssetImage('assets/images/ModuloYoga/postura_2_yoga.webp'), context);
      precacheImage(const AssetImage('assets/images/ModuloYoga/postura_3_yoga.webp'), context);
      precacheImage(const AssetImage('assets/images/ModuloYoga/postura_4_yoga.webp'), context);
      precacheImage(const AssetImage('assets/images/ModuloYoga/postura_5_yoga.webp'), context);
      precacheImage(const AssetImage('assets/images/ModuloYoga/postura_6_yoga.webp'), context);
    }
  }

  @override
  Widget build(BuildContext context) {
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

          // ── GIF Character (Mismas dimensiones del Módulo 3) ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.203,
            top: MediaQuery.of(context).size.height * 0.32,
            child: FadeIn(
              child: GestureDetector(
                onTap: () {
                  SfxManager().playClick();
                  setState(() {
                    _videoAnimKey++;
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.673,
                  height: MediaQuery.of(context).size.height * 0.673,
                  child: Bounce(
                    key: ValueKey(_videoAnimKey),
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset(
                      'assets/images/Video.webp',
                      key: ValueKey('img_$_videoAnimKey'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // BIENESTAR letrero — centered, 60% above vertical center
          Align(
            alignment: const Alignment(0, -0.6),
            child: Image.asset(
              'assets/images/letreros/BIENESTAR.webp',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),
          ),

          // Botones en la parte inferior (2% más arriba)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.84,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Ejercicios (boton_ejer)
                _buildMenuButton(
                  index: 0,
                  imagePath: 'assets/images/ModuloYoga/boton_ejer.webp',
                  onTap: () async {
                    await _triggerScale(0);
                    if (!context.mounted) return;
                    context.push('/yoga');
                  },
                ),
                
                SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                
                // Botón Nube (boton_nube)
                _buildMenuButton(
                  index: 1,
                  imagePath: 'assets/images/ModuloYoga/boton_nube.webp',
                  onTap: () async {
                    await _triggerScale(1);
                    if (!context.mounted) return;
                    context.push('/relax');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required int index,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final double btnWidth = MediaQuery.of(context).size.width * 0.175;
    final double btnHeight = MediaQuery.of(context).size.height * 0.075;

    return AnimatedScale(
      scale: _buttonScales[index] ? 1.4 : 1.15,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () {
          SfxManager().playClick();
          onTap();
        },
        child: _FloatingModuleButton(
          index: index,
          child: SizedBox(
            width: btnWidth,
            height: btnHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Resplandor Neumórfico & Soft Shadow (Efecto Glow) ──
                Container(
                  width: btnWidth * 1.05,
                  height: btnHeight * 1.05,
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
                ),
                Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ],
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
