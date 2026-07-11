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
  bool _isPrecached = false;
  final List<bool> _buttonScales = [false, false];

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
