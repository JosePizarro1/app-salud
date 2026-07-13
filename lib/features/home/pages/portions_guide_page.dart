import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/services/sfx_manager.dart';
import '../widgets/module_header.dart';

class PortionsGuidePage extends StatefulWidget {
  const PortionsGuidePage({super.key});

  @override
  State<PortionsGuidePage> createState() => _PortionsGuidePageState();
}

class _PortionsGuidePageState extends State<PortionsGuidePage> {
  int _filledPortions = 0; // 0: Empty, 1: Veggies, 2: Protein, 3: Grains/Complete
  bool _showSuccessBubble = false;
  bool _showCelebration = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache optimized WebP and PNG assets to prevent any flickering or blank frame during taps
    precacheImage(const AssetImage('assets/images/healthy_eating/plato_vacio.webp'), context);
    precacheImage(const AssetImage('assets/images/healthy_eating/solo_verdurass.webp'), context);
    precacheImage(const AssetImage('assets/images/healthy_eating/verduras_proteina.webp'), context);
    precacheImage(const AssetImage('assets/images/healthy_eating/plato_completo.webp'), context);
    precacheImage(const AssetImage('assets/images/healthy_eating/images/titi triste.png'), context);
  }

  void _onPlateTap() {
    if (_filledPortions >= 3) {
      // Tap again when complete to restart and try again
      setState(() {
        _filledPortions = 0;
        _showSuccessBubble = false;
        _showCelebration = false;
      });
      SfxManager().playClick();
      return;
    }

    SfxManager().playClick();
    setState(() {
      _filledPortions++;
      if (_filledPortions == 3) {
        _showSuccessBubble = true;
        _showCelebration = true;
        SfxManager().playCompletion(); // Plays the completado_sonid.mp3 completion sound
        
        // Hide celebration after 4 seconds
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _showCelebration = false;
            });
          }
        });
      }
    });
  }

  String _getPlateInstruction() {
    switch (_filledPortions) {
      case 0:
        return ''; // Custom widget with Titi triste will be shown below instead
      case 1:
        return 'Toca el plato para servir la proteína 🍗';
      case 2:
        return 'Toca el plato para servir los cereales/féculas 🌾';
      default:
        return '¡Tu plato está completo y balanceado! 🌟';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4D7), // Matching peach background
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

            // Scrollable Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 155), // Increased from 120 to 155 to avoid clashing with header
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
                  child: Column(
                    children: [
                      // Mascot speaking intro bubble
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/healthy_eating/images/titi patita.webp',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Icon(Icons.stars_rounded, size: 50, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¡Hola! Soy TITI',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Te enseño cómo porcionar tus alimentos para que logres tu meta de alimentación saludable.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFFFF8A71)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Así se ve un plato balanceado:',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Interactive Plate Stack
                      GestureDetector(
                        onTap: _onPlateTap,
                        child: Container(
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pre-cached, GPU-optimized IndexedStack to render the plate states instantaneously
                              IndexedStack(
                                index: _filledPortions,
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/healthy_eating/plato_vacio.webp',
                                    width: 290,
                                    height: 290,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => _buildPlateFallback(),
                                  ),
                                  Image.asset(
                                    'assets/images/healthy_eating/solo_verdurass.webp',
                                    width: 290,
                                    height: 290,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => _buildPlateFallback(),
                                  ),
                                  Image.asset(
                                    'assets/images/healthy_eating/verduras_proteina.webp',
                                    width: 290,
                                    height: 290,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => _buildPlateFallback(),
                                  ),
                                  Image.asset(
                                    'assets/images/healthy_eating/plato_completo.webp',
                                    width: 290,
                                    height: 290,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => _buildPlateFallback(),
                                  ),
                                ],
                              ),

                              // Central Click/Instruction Prompt inside plate if empty
                              if (_filledPortions == 0)
                                Bounce(
                                  infinite: true,
                                  duration: const Duration(milliseconds: 1500),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.touch_app_rounded, size: 16, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          '¡Toca para servir!',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 24),

                      // Interactive Subtitle Hint Badge or Titi triste prompt
                      if (_filledPortions == 0)
                        FadeIn(
                          duration: const Duration(milliseconds: 450),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/healthy_eating/images/titi triste.png',
                                height: 85,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.sentiment_very_dissatisfied_rounded,
                                  size: 60,
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF2ED),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFD5CC),
                                  ),
                                ),
                                child: Text(
                                  'Titi no ha comido, ¡ayúdala! 😢',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFC2410C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Dynamic standard instructions shown when plate has food
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _filledPortions == 3 ? const Color(0xFFEDF7ED) : const Color(0xFFFFF2ED),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _filledPortions == 3 ? const Color(0xFFC2E7C2) : const Color(0xFFFFD5CC),
                            ),
                          ),
                          child: Text(
                            _getPlateInstruction(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _filledPortions == 3 ? const Color(0xFF1E4620) : const Color(0xFFC2410C),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // --- PORTION LABELS SECTION (Reversed: Newest on Top) ---
                      if (_filledPortions >= 3) ...[
                        FadeIn(
                          duration: const Duration(milliseconds: 400),
                          child: _buildPortionLabelCard(
                            color: const Color(0xFFFFC107),
                            title: '1/4 de Cereales / Féculas',
                            desc: 'Arroz, legumbres, avena, papas o fideos para brindarte energía.',
                            icon: '🌾',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_filledPortions >= 2) ...[
                        FadeIn(
                          duration: const Duration(milliseconds: 400),
                          child: _buildPortionLabelCard(
                            color: const Color(0xFFFF8A71),
                            title: '1/4 de Proteína',
                            desc: 'Carnes magras, pollo, pescado, huevo o legumbres para tus músculos.',
                            icon: '🍗',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_filledPortions >= 1) ...[
                        FadeIn(
                          duration: const Duration(milliseconds: 400),
                          child: _buildPortionLabelCard(
                            color: Colors.green,
                            title: '1/2 de Verduras',
                            desc: 'Ensaladas de vegetales frescos para aportar vitaminas, minerales y fibra.',
                            icon: '🥗',
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Success Advice dialog bubble with Heart
                      if (_showSuccessBubble)
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7F5),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFFFD5CC),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFE4D7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('❤️', style: TextStyle(fontSize: 22)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Recuerda: las porciones adecuadas te dan la energía que necesitas, te ayudan a mantenerte saludable y a sentirte increíble cada día.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFC2410C),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Restart option when plate is full
                      if (_filledPortions == 3) ...[
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _filledPortions = 0;
                              _showSuccessBubble = false;
                              _showCelebration = false;
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFF8A71)),
                          label: Text(
                            'Vaciar plato y volver a empezar',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFF8A71),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Header (Back & Home buttons)
            const ModuleHeader(showHome: true, showBack: true),

            // Confetti/Success celebration overlay
            if (_showCelebration)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.transparent,
                    child: DotLottieView(
                      sourceType: 'asset',
                      source: 'assets/lottie/success_celebration.lottie',
                      autoplay: true,
                      loop: false,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlateFallback() {
    return Container(
      width: 290,
      height: 290,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant, size: 80, color: Colors.black12),
    );
  }

  Widget _buildPortionLabelCard({
    required Color color,
    required String title,
    required String desc,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
