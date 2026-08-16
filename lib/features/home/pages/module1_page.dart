import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/module_header.dart';
import '../../../app/services/sfx_manager.dart';

class Module1Page extends StatefulWidget {
  const Module1Page({super.key});

  @override
  State<Module1Page> createState() => _Module1PageState();
}

class _Module1PageState extends State<Module1Page> {
  // Estado de escala para el botón
  bool _isButtonScaled = false;

  Future<void> _triggerScale() async {
    setState(() => _isButtonScaled = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isButtonScaled = false);
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
            'assets/images/fondo_modulo1_juegos.webp',
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // JUEGOS letrero — centered, 60% above vertical center
          Align(
            alignment: const Alignment(0, -0.6),
            child: Image.asset(
              'assets/images/letreros/JUEGOS.webp',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),
          ),

          // Botón en la parte inferior (siguiendo el estilo del modulo 3)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.78,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuButton(
                  imagePath: 'assets/images/Bsudoku.webp',
                  onTap: () async {
                    await _triggerScale();
                    if (context.mounted) context.push('/sudoku');
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
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final double btnWidth = MediaQuery.of(context).size.width * 0.3;
    final double btnHeight = MediaQuery.of(context).size.height * 0.15;

    return AnimatedScale(
      scale: _isButtonScaled ? 1.4 : 1.15,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () {
          SfxManager().playClick();
          onTap();
        },
        child: _FloatingModuleButton(
          index: 0,
          child: SizedBox(
            width: btnWidth,
            height: btnHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Resplandor Neumórfico & Soft Shadow (Efecto Glow) ──
                Container(
                  width: btnWidth * 0.98,
                  height: btnHeight * 0.98,
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
