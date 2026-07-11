import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/module_header.dart';

class Module3Page extends StatefulWidget {
  const Module3Page({super.key});

  @override
  State<Module3Page> createState() => _Module3PageState();
}

class _Module3PageState extends State<Module3Page> {
  // Estado de escala para los 3 botones
  final List<bool> _buttonScales = [false, false, false];

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo_modulo3.PNG',
            fit: BoxFit.cover,
          ),

          // ── GIF Character (Escalado y posicionado) ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.203,
            top: MediaQuery.of(context).size.height * 0.27,
            child: FadeIn(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.673,
                height: MediaQuery.of(context).size.height * 0.673,
                child: Image.asset(
                  'assets/images/Video.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

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
                  imagePath: 'assets/images/Bmeditacion.png',
                  onTap: () async {
                    await _triggerScale(0);
                    if (context.mounted) context.push('/meditation');
                  },
                ),
                
                const SizedBox(width: 10),
                
                // Botón Respiración
                _buildMenuButton(
                  index: 1,
                  imagePath: 'assets/images/Brespiracion.png',
                  onTap: () async {
                    await _triggerScale(1);
                    if (context.mounted) context.push('/breathing');
                  },
                ),
                
                const SizedBox(width: 10),
                
                // Botón Emociones
                _buildMenuButton(
                  index: 2,
                  imagePath: 'assets/images/Bemociones.png',
                  onTap: () async {
                    await _triggerScale(2);
                    if (context.mounted) context.push('/emotions');
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
    // Escala base 1.25 como pidió el usuario
    return AnimatedScale(
      scale: _buttonScales[index] ? 1.4 : 1.15,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.15,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
