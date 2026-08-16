import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/module_header.dart';
import '../../../app/services/sfx_manager.dart';

class Module5Page extends StatefulWidget {
  const Module5Page({super.key});

  @override
  State<Module5Page> createState() => _Module5PageState();
}

class _Module5PageState extends State<Module5Page> {
  // Estado de escala para los botones (0: Diario, 1: Emociones)
  final List<bool> _isButtonScaled = [false, false];
  bool _isPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      precacheImage(const AssetImage('assets/images/boton_diario.webp'), context);
      precacheImage(const AssetImage('assets/images/Bemociones.webp'), context);
    }
  }

  Future<void> _triggerScale(int index) async {
    setState(() => _isButtonScaled[index] = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isButtonScaled[index] = false);
    }
    // Esperamos a que la escala regrese a su tamaño original antes de continuar
    await Future.delayed(const Duration(milliseconds: 150));
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
            'assets/images/fondo_modulo5_calendario.webp',
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // HORARIO letrero — centered, 60% above vertical center
          Align(
            alignment: const Alignment(0, -0.6),
            child: Image.asset(
              'assets/images/letreros/HORARIO.webp',
              width: MediaQuery.of(context).size.width * 0.756,
              fit: BoxFit.contain,
            ),
          ),

          // Navigation buttons: 2 buttons pushed to screen edges (left: Diario, right: Emociones)
          Align(
            alignment: const Alignment(0, 0.4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildMenuButton(
                    imagePath: 'assets/images/boton_diario.webp',
                    index: 0,
                    sizeScale: 0.67,
                    onTap: () async {
                      await _triggerScale(0);
                      if (context.mounted) context.push('/organizer');
                    },
                  ),
                  _buildMenuButton(
                    imagePath: 'assets/images/Bemociones.webp',
                    index: 1,
                    sizeScale: 0.95,
                    onTap: () async {
                      await _triggerScale(1);
                      if (context.mounted) context.push('/emotions');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String imagePath,
    required int index,
    required VoidCallback onTap,
    double sizeScale = 1.0,
  }) {
    final double btnWidth = MediaQuery.of(context).size.width * 0.3 * sizeScale;
    final double btnHeight = MediaQuery.of(context).size.height * 0.15 * sizeScale;

    return AnimatedScale(
      scale: _isButtonScaled[index] ? 1.4 : 1.15,
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
                        color: const Color(0xFFFFB74D).withValues(alpha: 0.6), // Cálido dorado/durazno para contraste sobre crema
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
