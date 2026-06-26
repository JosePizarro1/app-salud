import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../widgets/module_header.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Shared Header with Home Button
            const ModuleHeader(showHome: true),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.alarm_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Alarma y Reloj',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Próximamente disponible',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
