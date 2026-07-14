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
      backgroundColor: const Color(0xFFFAF6F0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo_modulo6.webp',
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true, showBack: true),

          // LECCIONES letrero — centered, 60% above vertical center
          Align(
            alignment: const Alignment(0, -0.6),
            child: Image.asset(
              'assets/images/letreros/LECCIONES.webp',
              width: MediaQuery.of(context).size.width * 0.756,
              fit: BoxFit.contain,
            ),
          ),

          // Navigation buttons: 2×2 grid — columns pushed to screen edges
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left column
                  Column(
                    mainAxisSize: MainAxisSize.min,
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      _buildMenuButton(
                        index: 2,
                        imagePath: 'assets/images/Modulo6/boton3 modulo leccion.png',
                        onTap: () async {
                          await _triggerScale(2);
                          if (context.mounted) {
                            context.push('/study_techniques');
                          }
                        },
                      ),
                    ],
                  ),
                  // Right column
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      _buildMenuButton(
                        index: 3,
                        imagePath: 'assets/images/Modulo6/boton 4 modulo leccion.png',
                        onTap: () async {
                          await _triggerScale(3);
                          if (context.mounted) {
                            context.push('/knowing_stress');
                          }
                        },
                      ),
                    ],
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
    required int index,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final double size = MediaQuery.of(context).size.width * 0.205;
    return AnimatedScale(
      scale: _buttonScales[index] ? 1.4 : 1.05,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: size,
              height: size,
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
