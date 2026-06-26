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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo modulo4 sueño titi.png',
            fit: BoxFit.cover,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),

          // Contenedor para los dos botones de navegación
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  // Botón de Playlist
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () => context.push('/playlist'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.playlist_play_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Playlist',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Botón de Alarma
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () => context.push('/alarm'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.alarm_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Alarma',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

