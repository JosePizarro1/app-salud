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
          const SizedBox(height: 12),

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
                'assets/images/healthy_eating/images/titi patita.webp',
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
