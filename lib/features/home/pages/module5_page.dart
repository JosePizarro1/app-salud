import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/module_header.dart';

class Module5Page extends StatefulWidget {
  const Module5Page({super.key});

  @override
  State<Module5Page> createState() => _Module5PageState();
}

class _Module5PageState extends State<Module5Page> {
  // Estado de escala para los botones (0: Diario, 1: Emociones)
  final List<bool> _isButtonScaled = [false, false];

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo modulo5calendario.png',
            fit: BoxFit.cover,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // Botones en la parte inferior (siguiendo el estilo del modulo 1 y 3)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.78,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuButton(
                  imagePath: 'assets/images/boton diario (1).png',
                  index: 0,
                  sizeScale: 0.67,
                  onTap: () async {
                    await _triggerScale(0);
                    if (context.mounted) context.push('/organizer');
                  },
                ),
                const SizedBox(width: 15),
                _buildMenuButton(
                  imagePath: 'assets/images/Bemociones.png',
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
        onTap: onTap,
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
