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
    return AnimatedScale(
      scale: _isButtonScaled[index] ? 1.4 : 1.15,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () {
          SfxManager().playClick();
          onTap();
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.3 * sizeScale,
          height: MediaQuery.of(context).size.height * 0.15 * sizeScale,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
