import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  bool _isBetterPressed = false;
  bool _isChatPressed = false;
  bool _isHomePressed = false;

  void _triggerHome() async {
    setState(() => _isHomePressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isHomePressed = false);
      context.go('/home');
    }
  }

  void _onBetterTap() async {
    setState(() => _isBetterPressed = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() => _isBetterPressed = false);
      // Navigate beautifully to the active pause module
      context.pushReplacement('/active_pause');
    }
  }

  void _onChatTap() async {
    setState(() => _isChatPressed = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() => _isChatPressed = false);
      context.push('/titi_chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image (Cozy fondotiti)
          Image.asset(
            'assets/images/fondotiti.jpg',
            fit: BoxFit.cover,
          ),

          // 2. Blur Overlay (Glassmorphism design)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // White Card with bright green border
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 380),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFF28AF52), // Brand green border matching screenshot
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // RichText Title
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Botón de ',
                                    style: TextStyle(color: Color(0xFF3B60B3)),
                                  ),
                                  TextSpan(
                                    text: 'emergencia',
                                    style: TextStyle(color: Color(0xFF28AF52)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Subtitle
                            Text(
                              'Tómate un momento para respirar, relajarte o conversar con Titi cuando lo necesites.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4C7CC2), // Indigo subtitle
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Button 1: Ayúdame a sentirme mejor ──
                            AnimatedScale(
                              scale: _isBetterPressed ? 0.92 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              child: GestureDetector(
                                onTap: _onBetterTap,
                                child: SizedBox(
                                  width: screenWidth * 0.756,
                                  height: screenWidth * 0.189,
                                  child: Image.asset(
                                    'assets/images/modulo_respiracion/Bsentirme_mejor.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Button 2: Habla con Titi ──
                            AnimatedScale(
                              scale: _isChatPressed ? 0.92 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              child: GestureDetector(
                                onTap: _onChatTap,
                                child: SizedBox(
                                  width: screenWidth * 0.72,
                                  height: screenWidth * 0.18,
                                  child: Image.asset(
                                    'assets/images/modulo_respiracion/Bchat_titi.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Ocelot Cat GIF ──
                            SizedBox(
                              width: screenWidth * 0.46,
                              height: screenWidth * 0.46,
                              child: Image.asset(
                                'assets/images/modulo_respiracion/titi emergencia-2.gif',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Positioned Home Button (Bhome.PNG) - Replaces the simple back button
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            top: MediaQuery.of(context).size.height * 0.091,
            child: AnimatedScale(
              scale: _isHomePressed ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: _triggerHome,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: Image.asset(
                    'assets/images/Bhome.PNG',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
