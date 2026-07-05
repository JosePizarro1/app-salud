import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';

class HealthyEatingCompletionWidget extends StatefulWidget {
  const HealthyEatingCompletionWidget({super.key});

  @override
  State<HealthyEatingCompletionWidget> createState() => _HealthyEatingCompletionWidgetState();
}

class _HealthyEatingCompletionWidgetState extends State<HealthyEatingCompletionWidget> {
  bool _showCheck1 = false;
  bool _showCheck2 = false;
  bool _showCheck3 = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startSequentialChecks();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('images/healthy_eating/sonido_noti_entrada.mp3'));
    } catch (e) {
      debugPrint('Error playing check notification sound: $e');
    }
  }

  void _startSequentialChecks() {
    // Check 1
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _showCheck1 = true);
        _playSound();
      }
    });

    // Check 2
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) {
        setState(() => _showCheck2 = true);
        _playSound();
      }
    });

    // Check 3
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _showCheck3 = true);
        _playSound();
      }
    });
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/healthy_eating/images/boton check.png',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 34,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 17.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Title: "MÓDULO DE NUTRICIÓN AL 100%"
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Text(
                'MÓDULO DE NUTRICIÓN AL 100%',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E7D32),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Large Title: "¡MISIÓN NUTRICIONAL CUMPLIDA!"
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  '¡MISIÓN NUTRICIONAL CUMPLIDA!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle text: "¡Titi está listo para el éxito!"
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 150),
              child: Text(
                '¡Titi está listo para el éxito!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Mascot (Titi héroe felzi with cape - compacted)
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: Image.asset(
                'assets/images/healthy_eating/images/titi heroe felzi.png',
                height: 210,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/healthy_eating/images/titi patita.png',
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Checks list
            if (_showCheck1)
              FadeInLeft(
                duration: const Duration(milliseconds: 400),
                child: _buildCheckItem('Súper memoria protegida.'),
              ),
            if (_showCheck2)
              FadeInLeft(
                duration: const Duration(milliseconds: 400),
                child: _buildCheckItem('Energía estable y constante.'),
              ),
            if (_showCheck3)
              FadeInLeft(
                duration: const Duration(milliseconds: 400),
                child: _buildCheckItem('Cero ansiedad nocturna.'),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
