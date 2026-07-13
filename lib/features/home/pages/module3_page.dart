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
    // Escala base 1.25 como pidió el usuario
    return AnimatedScale(
      scale: _buttonScales[index] ? 1.4 : 1.15,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () {
          SfxManager().playClick();
          onTap();
        },
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
