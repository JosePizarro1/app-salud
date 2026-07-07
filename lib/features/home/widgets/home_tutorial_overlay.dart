import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class HomeTutorialOverlay extends StatelessWidget {
  final VoidCallback onFinish;

  const HomeTutorialOverlay({
    super.key,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Semi-transparent dark background covering the whole screen
        Container(
          color: Colors.black.withValues(alpha: 0.78),
        ),

        // Center Welcome speech bubble & Mascot
        Center(
          child: FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Speech bubble
                Container(
                  width: width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0ED),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFFFECE5), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '¡BIENVENIDO A VITALI!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFF8A71),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '¡Hola! Soy Titi. Bienvenido a tu habitación de bienestar. Aquí podrás explorar diferentes módulos interactivos diseñados para cuidar tu salud física y mental durante tu vida universitaria.\n\n¡Toca los objetos de la habitación para descubrirlos!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onFinish();
                        },
                        child: Container(
                          width: 150,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8A71),
                            borderRadius: BorderRadius.circular(23),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '¡Entendido!',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Titi patita mascot
                Image.asset(
                  'assets/images/healthy_eating/images/titi patita.png',
                  height: 170,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
