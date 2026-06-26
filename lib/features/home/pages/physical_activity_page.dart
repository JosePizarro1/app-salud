import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/module_header.dart';

class PhysicalActivityPage extends StatefulWidget {
  const PhysicalActivityPage({super.key});

  @override
  State<PhysicalActivityPage> createState() => _PhysicalActivityPageState();
}

class _PhysicalActivityPageState extends State<PhysicalActivityPage> {
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentPage = 0;

  // Scale states for the 6 benefits buttons
  final List<bool> _benefitScales = List.generate(6, (_) => false);

  // Card open state tracker (4 intro cards)
  final List<bool> _isCardOpened = [false, false, false, false];

  // Animation keys to trigger animate_do Bounce animation on click
  final List<int> _cardIconAnimKeys = [0, 0, 0, 0];

  final List<Map<String, dynamic>> _introCards = [
    {
      'number': '1',
      'title': '¿Qué es?',
      'desc': 'Es cualquier movimiento que hace tu cuerpo.',
      'iconPath': 'assets/images/Modulo6/???.png',
      'isAsset': true,
      'bgColor': const Color(0xFFF3F0FF), // Soft lavender background
      'borderColor': const Color(0xFF9083ED), // Purple border from AppColors.secondary
      'textColor': const Color(0xFF4F3A8A),
      'badgeBg': const Color(0xFF9083ED),
      'revealedIcon': Icons.accessibility_new_rounded,
    },
    {
      'number': '2',
      'title': '¿Por qué es buena?',
      'desc': 'Mejora tu salud, te da energía y te hace sentir bien.',
      'iconPath': 'assets/images/Modulo6/!!!.png',
      'isAsset': true,
      'bgColor': const Color(0xFFE8F6F1), // Soft Mint background
      'borderColor': const Color(0xFF4CAF50), // Green border
      'textColor': const Color(0xFF1E523A),
      'badgeBg': const Color(0xFF2E7D32),
      'revealedIcon': Icons.bolt_rounded,
    },
    {
      'number': '3',
      'title': '¿Sabías que?',
      'desc': 'No necesitas una cancha. ¡Muévete en cualquier lugar!',
      'iconPath': '',
      'isAsset': false, // Sparkles
      'bgColor': const Color(0xFFFFF9E6), // Soft Yellow background
      'borderColor': const Color(0xFFFBBF24), // Warning Yellow from AppColors.warning
      'textColor': const Color(0xFF7A5C00),
      'badgeBg': const Color(0xFFFFA000),
      'revealedIcon': Icons.sports_gymnastics_rounded,
    },
    {
      'number': '4',
      'title': '¡Tú puedes!',
      'desc': 'Pequeños movimientos cada día, grandes cambios en tu vida.',
      'iconPath': 'assets/images/Modulo6/titi modulo leccion1 (1) (1).gif',
      'isAsset': true,
      'fallbackIconPath': 'assets/images/gato1.png',
      'bgColor': const Color(0xFFFFF2ED), // Soft Coral/Pink background
      'borderColor': const Color(0xFFFF8A71), // Primary Coral from AppColors.primary
      'textColor': const Color(0xFF9E2A3B),
      'badgeBg': const Color(0xFFFF8A71),
      'revealedIcon': Icons.trending_up_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onCardTapped(int index) async {
    HapticFeedback.mediumImpact();
    
    final wasOpen = _isCardOpened[index];
    setState(() {
      _cardIconAnimKeys[index]++;
      _isCardOpened[index] = !_isCardOpened[index];
    });

    // Play sound when info is discovered/revealed
    if (!wasOpen) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('audio/success_cheerful.mp3'));
      } catch (e) {
        debugPrint('Error playing success audio: $e');
      }
    }
  }

  Widget _buildCardIcon(Map<String, dynamic> card) {
    if (card['isAsset'] as bool) {
      final path = card['iconPath'] as String;
      if (path.endsWith('.gif')) {
        return Image.asset(
          path,
          height: 230, // Scaled x1.5 (from 155)
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            if (card.containsKey('fallbackIconPath')) {
              return Image.asset(
                card['fallbackIconPath'] as String,
                height: 195, // Scaled x1.5 (from 130)
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.favorite_rounded,
                  size: 150, // Scaled x1.5 (from 100)
                  color: Colors.redAccent,
                ),
              );
            }
            return const Icon(
              Icons.star_rounded,
              size: 150, // Scaled x1.5 (from 100)
              color: Colors.amber,
            );
          },
        );
      }
      return Image.asset(
        path,
        height: 210, // Scaled x1.5 (from 140)
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.help_outline_rounded,
          size: 150, // Scaled x1.5 (from 100)
          color: Colors.indigo,
        ),
      );
    } else {
      return ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFFFA000), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Icon(
          Icons.auto_awesome_rounded,
          size: 195, // Scaled x1.5 (from 130)
          color: Colors.white,
        ),
      );
    }
  }

  Widget _buildTopProgressBar() {
    if (_currentPage > 4) return const SizedBox(width: 128); // Empty space to align on benefits page
    
    // Map current page to active progress segment:
    // Page 0 (Welcome): Segment 0 active
    // Page 1 (Card 1): Segment 0 active
    // Page 2 (Card 2): Segment 1 active
    // Page 3 (Card 3): Segment 2 active
    // Page 4 (Card 4): Segment 3 active
    int activeSegment = 0;
    if (_currentPage >= 1 && _currentPage <= 4) {
      activeSegment = _currentPage - 1;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index <= activeSegment;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4CAF50) : Colors.black12,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSlide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            children: const [
              TextSpan(
                text: 'Actividad ',
                style: TextStyle(color: Color(0xFF5C6BC0)), // Indigo
              ),
              TextSpan(
                text: 'Física',
                style: TextStyle(color: Color(0xFF4CAF50)), // Green
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Mascot
        Image.asset(
          'assets/images/Modulo6/titi modulo leccion1 (1) (1).gif',
          height: 220,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/gato1.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),

        // Subtitle
        Text(
          'Desliza para aprender algo nuevo',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroCardPage(Map<String, dynamic> card, int cardIndex) {
    final isOpen = _isCardOpened[cardIndex];
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: card['bgColor'] as Color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: card['borderColor'] as Color,
            width: 4.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (card['borderColor'] as Color).withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Header: Circular number and progression tracker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: card['badgeBg'] as Color,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    card['number'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${card['number']} de 4',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: (card['textColor'] as Color).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 2),

            // Animated Center Icon
            Center(
              child: Bounce(
                key: ValueKey(_cardIconAnimKeys[cardIndex]),
                duration: const Duration(milliseconds: 600),
                child: GestureDetector(
                  onTap: () => _onCardTapped(cardIndex),
                  child: _buildCardIcon(card),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Card Title & Text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _onCardTapped(cardIndex),
                  child: Text(
                    card['title'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: card['textColor'] as Color,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _onCardTapped(cardIndex),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 32),
                      alignment: Alignment.center,
                      child: isOpen
                          ? ZoomIn(
                              duration: const Duration(milliseconds: 350),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    card['revealedIcon'] as IconData,
                                    size: 32,
                                    color: card['borderColor'] as Color,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    card['desc'] as String,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 19.0, // Larger letter size
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 16,
                                  color: (card['borderColor'] as Color).withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Toca para descubrir info',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: (card['textColor'] as Color).withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // internal card progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (dotIndex) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: cardIndex == dotIndex ? 10 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: cardIndex == dotIndex
                        ? (card['borderColor'] as Color)
                        : Colors.black12,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerBenefitScale(int index) async {
    setState(() => _benefitScales[index] = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() => _benefitScales[index] = false);
    }
  }

  void _showBenefitDetail(BuildContext context, int index) {
    final details = [
      {
        'title': 'Reduce el estrés',
        'desc': 'Realizar actividad física ayuda a reducir los niveles de cortisol (la hormona del estrés) y estimula la producción de endorfinas, promoviendo una sensación de calma y bienestar.',
        'color': const Color(0xFFE8F6F1),
        'textColor': const Color(0xFF1E523A),
        'icon': '🧘‍♀️',
      },
      {
        'title': 'Mejora tu estado de ánimo',
        'desc': 'El movimiento estimula neurotransmisores como la dopamina y la serotonina, ayudando a combatir la tristeza, mejorar el humor y darte más energía.',
        'color': const Color(0xFFFFF7E6),
        'textColor': const Color(0xFF8A6200),
        'icon': '☀️',
      },
      {
        'title': 'Disminuye la ansiedad',
        'desc': 'La actividad física ayuda a liberar la tensión muscular acumulada y relaja la mente, disminuyendo de forma efectiva los síntomas de la ansiedad y la tensión mental.',
        'color': const Color(0xFFF3EDFF),
        'textColor': const Color(0xFF532E91),
        'icon': '☁️',
      },
      {
        'title': 'Aumenta tu concentración',
        'desc': 'El ejercicio incrementa el flujo de oxígeno al cerebro, lo que mejora la memoria, la atención y la claridad cognitiva para tus actividades de estudio.',
        'color': const Color(0xFFE6F0FF),
        'textColor': const Color(0xFF1F4A85),
        'icon': '🧠',
      },
      {
        'title': 'Mejora tu rendimiento',
        'desc': 'Al estar más concentrado y menos estresado, tu cerebro procesa y retiene mejor la información, facilitando el aprendizaje y la productividad académica.',
        'color': const Color(0xFFFFECEF),
        'textColor': const Color(0xFF9E2A3B),
        'icon': '📚',
      },
      {
        'title': 'Mejora tu calidad de sueño',
        'desc': 'Gastar energía de forma saludable durante el día ayuda a conciliar el sueño más rápido y a disfrutar de un descanso más profundo y reparador por la noche.',
        'color': const Color(0xFFE6F5FF),
        'textColor': const Color(0xFF0F5A8F),
        'icon': '🌙',
      },
    ];

    final detail = details[index];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return FadeIn(
          duration: const Duration(milliseconds: 300),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: detail['color'] as Color, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    detail['icon'] as String,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    detail['title'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: detail['textColor'] as Color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    detail['desc'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: detail['textColor'] as Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '¡Entendido!',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBgColor() {
    switch (_currentPage) {
      case 0:
        return const Color(0xFFF6FAF8); // Very light mint/white
      case 1:
        return const Color(0xFFF6F5FD); // Very light lavender
      case 2:
        return const Color(0xFFF5FAF6); // Very light green
      case 3:
        return const Color(0xFFFFFDF5); // Very light amber/yellow
      case 4:
        return const Color(0xFFFFF5F6); // Very light pink/red
      case 5:
        return const Color(0xFFF7F5FC); // Very light purple (benefits)
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        color: _getBgColor(), // Dynamic background color based on card step
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Soft green background leaf decorations
            Positioned(
              bottom: -20,
              left: -20,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(45 / 360),
                child: Icon(
                  Icons.spa_rounded,
                  size: 150,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              right: -30,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(-30 / 360),
                child: Icon(
                  Icons.spa_rounded,
                  size: 130,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                ),
              ),
            ),

            // Original ModuleHeader (untouched)
            const ModuleHeader(showHome: true),

            // Center progress bar overlay
            Positioned(
              top: screenHeight * 0.105,
              left: 0,
              right: 0,
              child: Center(
                child: _buildTopProgressBar(),
              ),
            ),

            // Main PageView content (floats directly on the background)
            Positioned(
              top: screenHeight * 0.16,
              bottom: screenHeight * 0.13,
              left: 0,
              right: 0,
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomeSlide(),
                  _buildIntroCardPage(_introCards[0], 0),
                  _buildIntroCardPage(_introCards[1], 1),
                  _buildIntroCardPage(_introCards[2], 2),
                  _buildIntroCardPage(_introCards[3], 3),
                  _buildBenefitsSlide(),
                ],
              ),
            ),

            // Bottom Controls (Next/Back button)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: _currentPage == 0 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (hidden on Page 0)
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F6F1), // Soft mint back circle
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF4CAF50),
                          size: 26,
                        ),
                      ),
                    ),

                  // Center/Right Next/Done Button
                  if (_currentPage < 5)
                    GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50), // Green circle next button
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    )
                  else
                    // Listo Button for final page (Benefits)
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Listo',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                        ),
                      ],
                    ),
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

  Widget _buildBenefitsSlide() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Title
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: '¿Cuáles ',
                    style: TextStyle(color: Color(0xFF5C6BC0)), // Indigo
                  ),
                  TextSpan(
                    text: 'son los beneficios?',
                    style: TextStyle(color: Color(0xFF4CAF50)), // Green
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instruction Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEFB), // Soft Purple
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD3C5F5), width: 1.2),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Toca cualquiera de los beneficios para descubrir cómo pueden ayudarte.',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4F3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List of the 6 benefits buttons
            ...List.generate(6, (index) {
              return Container(
                margin: EdgeInsets.zero,
                child: AnimatedScale(
                  scale: _benefitScales[index] ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onTap: () async {
                      await _triggerBenefitScale(index);
                      if (!mounted) return;
                      _showBenefitDetail(context, index);
                    },
                    child: SizedBox(
                      height: 64,
                      child: ClipRect(
                        child: Image.asset(
                          'assets/images/Modulo6/beneficio${index + 1}.png',
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 64,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EEFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Beneficio ${index + 1}',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
