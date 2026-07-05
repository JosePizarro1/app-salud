import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/module_header.dart';

class Module6Page extends StatefulWidget {
  const Module6Page({super.key});

  @override
  State<Module6Page> createState() => _Module6PageState();
}

class _Module6PageState extends State<Module6Page> {
  // Estado de escala para los 4 botones
  final List<bool> _buttonScales = [false, false, false, false];

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
            'assets/images/fondo_modulo6.png',
            fit: BoxFit.cover,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // 4 Buttons in 1 single row at the bottom (matching module 3 and 5 style)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.78,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuButton(
                  index: 0,
                  imagePath: 'assets/images/Modulo6/boton1 modoulo lecciones_actividad_fisica.png',
                  onTap: () async {
                    await _triggerScale(0);
                    if (context.mounted) {
                      context.push('/physical_activity');
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildMenuButton(
                  index: 1,
                  imagePath: 'assets/images/Modulo6/boton2 modulo leccion.png',
                  onTap: () async {
                    await _triggerScale(1);
                    if (context.mounted) {
                      context.push('/healthy_eating');
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildMenuButton(
                  index: 2,
                  imagePath: 'assets/images/Modulo6/boton3 modulo leccion.png',
                  onTap: () async {
                    await _triggerScale(2);
                    // Action for button 3
                  },
                ),
                const SizedBox(width: 8),
                _buildMenuButton(
                  index: 3,
                  imagePath: 'assets/images/Modulo6/boton 4 modulo leccion.png',
                  onTap: () async {
                    await _triggerScale(3);
                    // Action for button 4 - Conociendo el Estrés
                    if (context.mounted) {
                      context.push('/knowing_stress');
                    }
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
      scale: _buttonScales[index] ? 1.4 : 1.05,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.20,
          height: MediaQuery.of(context).size.height * 0.10,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Text(
                'B${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
