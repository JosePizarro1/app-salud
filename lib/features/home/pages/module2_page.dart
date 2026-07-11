import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/module_header.dart';

class Module2Page extends StatefulWidget {
  const Module2Page({super.key});

  @override
  State<Module2Page> createState() => _Module2PageState();
}

class _Module2PageState extends State<Module2Page> {
  // Estado de escala para los 2 botones
  final List<bool> _buttonScales = [false, false];

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
            'assets/images/fondo_modulo2.PNG',
            fit: BoxFit.cover,
          ),

          // ── GIF Character (Mismas dimensiones del Módulo 3) ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.203,
            top: MediaQuery.of(context).size.height * 0.32,
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
                  imagePath: 'assets/images/ModuloYoga/boton_ejer.png',
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
                  imagePath: 'assets/images/ModuloYoga/boton_nube.png',
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
    return AnimatedScale(
      scale: _buttonScales[index] ? 1.4 : 1.15,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.175,
          height: MediaQuery.of(context).size.height * 0.075,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
