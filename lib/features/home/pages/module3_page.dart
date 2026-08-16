import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/module_header.dart';
import '../../../app/services/sfx_manager.dart';
import '../../../app/services/stats_sync_service.dart';

class Module3Page extends StatefulWidget {
  const Module3Page({super.key});

  @override
  State<Module3Page> createState() => _Module3PageState();
}

class _Module3PageState extends State<Module3Page> {
  // Estado de escala para los 2 botones
  final List<bool> _buttonScales = [false, false];
  bool _isPrecached = false;
  bool _isCatScaled = false;
  int _videoAnimKey = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      precacheImage(const AssetImage('assets/images/Bmeditacion.webp'), context);
      precacheImage(const AssetImage('assets/images/Brespiracion.webp'), context);
    }
  }

  Future<void> _triggerScale(int index) async {
    setState(() => _buttonScales[index] = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _buttonScales[index] = false);
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
            'assets/images/fondo_modulo3.webp',
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),

          // ── GIF Character (Escalado y posicionado) ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.203,
            top: MediaQuery.of(context).size.height * 0.27,
            child: FadeIn(
              child: GestureDetector(
                onTap: () async {
                  SfxManager().playClick();
                  setState(() {
                    _isCatScaled = true;
                    _videoAnimKey++;
                  });
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (mounted) {
                    setState(() => _isCatScaled = false);
                  }
                },
                child: AnimatedScale(
                  scale: _isCatScaled ? 0.92 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.673,
                    height: MediaQuery.of(context).size.height * 0.673,
                    child: Bounce(
                      key: ValueKey(_videoAnimKey),
                      duration: const Duration(milliseconds: 500),
                      child: Image.asset(
                        'assets/images/Video.webp',
                        key: ValueKey('img_cat_$_videoAnimKey'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Central WebP letrero (Optimizado y Posicionado de forma responsiva)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12, // Subido al 12% de la pantalla para celulares
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/letreros/letrero_meditacion.webp',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),

          // Botones en la parte inferior (30% más abajo del centro)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.78,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Meditación
                _buildMenuButton(
                  index: 0,
                  imagePath: 'assets/images/Bmeditacion.webp',
                  onTap: () async {
                    await _triggerScale(0);
                    // Track meditation sub-module access
                    StatsSyncService().logModuleAccess('/meditation');
                    if (context.mounted) context.push('/meditation');
                  },
                ),
                
                const SizedBox(width: 15),
                
                // Botón Respiración
                _buildMenuButton(
                  index: 1,
                  imagePath: 'assets/images/Brespiracion.webp',
                  onTap: () async {
                    await _triggerScale(1);
                    // Track breathing sub-module access
                    StatsSyncService().logModuleAccess('/breathing');
                    if (context.mounted) context.push('/breathing');
                  },
                ),
              ],
            ),
          ),

          // Shared Header with Home Button (colocado al final para quedar encima de todo y recibir toques)
          const ModuleHeader(showHome: true),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required int index,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final double btnWidth = MediaQuery.of(context).size.width * 0.3;
    final double btnHeight = MediaQuery.of(context).size.height * 0.15;

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
