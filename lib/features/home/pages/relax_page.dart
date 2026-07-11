import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../widgets/module_header.dart';

class RelaxPage extends StatelessWidget {
  const RelaxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo_modulo2.webp',
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),

          // Central Card (respecting safe areas and header spaces, wrapping content dynamically)
          Positioned(
            top: screenHeight * 0.21, // Safe space below the header (lowered by 6% from 0.15)
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.success,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Wrap content dynamically!
                  children: [
                    // Title and Description
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Relaja tu ',
                            style: TextStyle(color: AppColors.secondary),
                          ),
                          TextSpan(
                            text: 'cuerpo',
                            style: TextStyle(color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rutinas para después de clases o evaluaciones intensas que te ayudarán a relajarte y recuperar tu equilibrio.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons (Stacked)
                    Column(
                      children: [
                        // Botón de "Relajación profunda 4-7-8"
                        _ActionButton(
                          imagePath: 'assets/images/ModuloYoga/boton_relajacion_profunda.webp',
                          baseScale: 1.27, // Increased scale (total 1.27)
                          onTap: () {
                            context.push('/breathing');
                          },
                          todoComment: 'Relajación profunda 4-7-8',
                        ),
                        const SizedBox(height: 8),
                        // Botón de "Respiración equilibrada"
                        _ActionButton(
                          imagePath: 'assets/images/ModuloYoga/boton_respiracion_equilibrada.webp',
                          baseScale: 1.37, // Increased scale (total 1.37)
                          onTap: () {
                            context.push('/box_breathing');
                          },
                          todoComment: 'Respiración equilibrada',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Character GIF at the bottom (2x speed modified, responsive layout)
                    Container(
                      height: screenHeight * 0.22,
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        'assets/images/ModuloYoga/titi_modulo_yoga.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Header with Home, Back & Emergency Buttons
          const ModuleHeader(showHome: true, showBack: true),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final String todoComment;
  final double baseScale;

  const _ActionButton({
    required this.imagePath,
    required this.onTap,
    required this.todoComment,
    this.baseScale = 1.0,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? (widget.baseScale * 0.95) : widget.baseScale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Image.asset(
            widget.imagePath,
            height: 65, // Altura óptima para legibilidad y estética premium móvil
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
