import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../widgets/module_header.dart';

class Module4Page extends StatelessWidget {
  const Module4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo_modulo4_sueno_titi.webp',
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // Contenedor para los botones de navegación
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.08,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageButton(
                    context,
                    'assets/images/modulo4_botones/boton1_modulosuenio_lectura_sueno.png',
                    '/sleep_care',
                  ),
                  _buildImageButton(
                    context,
                    'assets/images/modulo4_botones/boton2_modulosuenio_rutina_nocturna.png',
                    '/night_routine',
                  ),
                  _buildImageButton(
                    context,
                    'assets/images/modulo4_botones/boton3_modulosuenio_alarma.png',
                    '/alarm',
                  ),
                  _buildImageButton(
                    context,
                    'assets/images/modulo4_botones/boton4_modulosuenio_playlist.png',
                    '/playlist',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(BuildContext context, String imagePath, String route) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            context.push(route);
          },
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

