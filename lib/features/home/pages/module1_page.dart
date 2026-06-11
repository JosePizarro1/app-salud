import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/module_header.dart';

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo modulo1 juegos.png',
            fit: BoxFit.cover,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // Botón en la parte inferior (siguiendo el estilo del modulo 3)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.78,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuButton(
                  imagePath: 'assets/images/Bsudoku.png',
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
    return AnimatedScale(
      scale: _isButtonScaled ? 1.4 : 1.15,
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
