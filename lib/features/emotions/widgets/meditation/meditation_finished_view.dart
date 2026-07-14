import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/widgets/custom_fade_in.dart';

class MeditationFinishedView extends StatelessWidget {
  final int selectedMinutes;
  final VoidCallback onExit;

  const MeditationFinishedView({
    super.key,
    required this.selectedMinutes,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('finished_view'),
      child: CustomFadeIn(
        duration: const Duration(milliseconds: 600),
        slideUp: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF88D49E), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🌸',
                  style: TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 20),
                Text(
                  '¡Excelente trabajo!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3B60B3),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Has completado tu sesión de meditación consciente de $selectedMinutes ${selectedMinutes == 1 ? 'minuto' : 'minutos'}.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    color: Colors.grey.shade700,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onExit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28AF52),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Regresar al Menú',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
