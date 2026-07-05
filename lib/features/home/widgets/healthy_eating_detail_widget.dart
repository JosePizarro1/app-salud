import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class HealthyEatingDetailWidget extends StatelessWidget {
  final String imagePath;
  final String description;

  const HealthyEatingDetailWidget({
    super.key,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'ALIMENTACIÓN\nSALUDABLE',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 150),
            child: Text(
              '¿Qué descubriremos hoy?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Button image at the top
          FadeInRight(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: MediaQuery.of(context).size.width * 0.85,
              height: 85,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Text description
          FadeInLeft(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 450),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Mascot Titi sitting and smiling
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 600),
            child: Image.asset(
              'assets/images/gato1.png',
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/healthy_eating/images/titi patita.png',
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
