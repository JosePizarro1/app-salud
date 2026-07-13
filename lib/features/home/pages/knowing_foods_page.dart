import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/services/sfx_manager.dart';
import '../widgets/module_header.dart';

class KnowingFoodsPage extends StatefulWidget {
  const KnowingFoodsPage({super.key});

  @override
  State<KnowingFoodsPage> createState() => _KnowingFoodsPageState();
}

class _KnowingFoodsPageState extends State<KnowingFoodsPage> {
  // Scales for individual button tap feedback
  final List<double> _buttonScales = [1.0, 1.0, 1.0, 1.0, 1.0];

  void _onTapButton(int index, VoidCallback action) {
    SfxManager().playClick();
    HapticFeedback.mediumImpact();
    setState(() {
      _buttonScales[index] = 0.96;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _buttonScales[index] = 1.0;
        });
        action();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4D7), // Unified peach background
      body: SafeArea(
        child: Stack(
          children: [
            // Soft background food & health decorations
            Positioned(
              bottom: -20,
              left: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(15 / 360),
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 150,
                  color: Colors.black.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -30,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(-20 / 360),
                child: Icon(
                  Icons.apple_rounded,
                  size: 140,
                  color: Colors.black.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(45 / 360),
                child: Icon(
                  Icons.emoji_food_beverage_rounded,
                  size: 110,
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
            ),

            // Module Header (with Home and Back buttons)
            const ModuleHeader(showHome: true, showBack: true),

            // Main Scrollable Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 130), // Offset to avoid overlapping header
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // Submenu Header Card
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Grupos de alimentos',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E7D32),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Aprende qué aporta cada grupo a tu cuerpo y mente',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: const Color(0xFFC2410C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 5 Buttons with alternating slide-in animations and delays
                      // 1. El nutriente más importante
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: AnimatedScale(
                          scale: _buttonScales[0],
                          duration: const Duration(milliseconds: 100),
                          child: _buildMenuButton(
                            imagePath: 'assets/images/healthy_eating/Boton el nutriente mas importante.webp',
                            onTap: () => _onTapButton(0, () {
                              context.push('/discovery_foods/water');
                            }),
                          ),
                        ),
                      ),

                      // 2. Alimentos que reducen el estrés / Defensas
                      FadeInRight(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: AnimatedScale(
                          scale: _buttonScales[1],
                          duration: const Duration(milliseconds: 100),
                          child: _buildMenuButton(
                            imagePath: 'assets/images/healthy_eating/Boton alimentos que reducen el estres.webp',
                            onTap: () => _onTapButton(1, () {
                              context.push('/discovery_foods/stress');
                            }),
                          ),
                        ),
                      ),

                      // 3. Alimentos que fortalecen el cuerpo
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 300),
                        child: AnimatedScale(
                          scale: _buttonScales[2],
                          duration: const Duration(milliseconds: 100),
                          child: _buildMenuButton(
                            imagePath: 'assets/images/healthy_eating/Boton alimentos que fortalecen el cuerpo.webp',
                            onTap: () => _onTapButton(2, () {
                              context.push('/discovery_foods/strength');
                            }),
                          ),
                        ),
                      ),

                      // 4. Alimentos que dan energía
                      FadeInRight(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 400),
                        child: AnimatedScale(
                          scale: _buttonScales[3],
                          duration: const Duration(milliseconds: 100),
                          child: _buildMenuButton(
                            imagePath: 'assets/images/healthy_eating/Boton Alimentos que dan energia.webp',
                            onTap: () => _onTapButton(3, () {
                              context.push('/discovery_foods/energy');
                            }),
                          ),
                        ),
                      ),

                      // 5. Alimentos que cuidan el cerebro
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 500),
                        child: AnimatedScale(
                          scale: _buttonScales[4],
                          duration: const Duration(milliseconds: 100),
                          child: _buildMenuButton(
                            imagePath: 'assets/images/healthy_eating/Boton alimentos que cuidan el cerebro.webp',
                            onTap: () => _onTapButton(4, () {
                              context.push('/discovery_foods/brain');
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 75,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF8A71), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              imagePath.split('/').last.split('.').first,
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
