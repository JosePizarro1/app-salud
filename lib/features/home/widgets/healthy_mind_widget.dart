import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

enum HealthyMindState { overview, equilibrio, estres }

class HealthyMindWidget extends StatefulWidget {
  final VoidCallback? onDetailChanged;
  const HealthyMindWidget({super.key, this.onDetailChanged});

  @override
  State<HealthyMindWidget> createState() => HealthyMindWidgetState();
}

class HealthyMindWidgetState extends State<HealthyMindWidget> {
  HealthyMindState _viewState = HealthyMindState.overview;
  final List<bool> _benefitScales = [false, false];

  bool get isDetailActive => _viewState != HealthyMindState.overview;

  void resetToOverview() {
    setState(() {
      _viewState = HealthyMindState.overview;
    });
    widget.onDetailChanged?.call();
  }

  Widget _buildBulletPoint(String emoji, String text, {double verticalPadding = 8}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.35,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16), // Top spacing
            // Title: "BENEFICIOS"
            FadeInDown(
              key: ValueKey('title_beneficios_${_viewState.name}'),
              duration: const Duration(milliseconds: 500),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'BENEFICIOS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            
            // Subtitle: "MENTE SANA"
            FadeInDown(
              key: ValueKey('title_mentesana_${_viewState.name}'),
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'MENTE SANA',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_viewState == HealthyMindState.overview) ...[
              // Button 1: Equilibrio Nutricional
              FadeInRight(
                duration: const Duration(milliseconds: 500),
                child: AnimatedScale(
                  scale: _benefitScales[0] ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() => _benefitScales[0] = true);
                      await Future.delayed(const Duration(milliseconds: 150));
                      if (context.mounted) {
                        setState(() {
                          _benefitScales[0] = false;
                          _viewState = HealthyMindState.equilibrio;
                        });
                        widget.onDetailChanged?.call();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 85,
                      child: Image.asset(
                        'assets/images/healthy_eating/images/boton equilibrio nutricional.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Button 2: Prevención del estrés
              FadeInLeft(
                duration: const Duration(milliseconds: 500),
                child: AnimatedScale(
                  scale: _benefitScales[1] ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() => _benefitScales[1] = true);
                      await Future.delayed(const Duration(milliseconds: 150));
                      if (context.mounted) {
                        setState(() {
                          _benefitScales[1] = false;
                          _viewState = HealthyMindState.estres;
                        });
                        widget.onDetailChanged?.call();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 85,
                      child: Image.asset(
                        'assets/images/healthy_eating/images/boton prevencion del estres.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mascot (titi deportista)
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Image.asset(
                  'assets/images/healthy_eating/gifs/titi deportista.gif',
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/healthy_eating/images/titi patita.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ] else if (_viewState == HealthyMindState.equilibrio) ...[
              // Active Button 1
              FadeInRight(
                duration: const Duration(milliseconds: 500),
                child: GestureDetector(
                  onTap: resetToOverview,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 85,
                    child: Image.asset(
                      'assets/images/healthy_eating/images/boton equilibrio nutricional.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bullet points for Equilibrio
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    _buildBulletPoint('🧠', 'Reduce el estrés y la fatiga.'),
                    _buildBulletPoint('🧠', 'Mejora el control emocional.'),
                    _buildBulletPoint('💪', 'Favorece la concentración y el rendimiento diario.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mascot (Titi patita waving)
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Image.asset(
                  'assets/images/gato1.png',
                  height: 185,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/healthy_eating/images/titi patita.png',
                    height: 165,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ] else if (_viewState == HealthyMindState.estres) ...[
              // Active Button 2
              FadeInLeft(
                duration: const Duration(milliseconds: 500),
                child: GestureDetector(
                  onTap: resetToOverview,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 2),
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 85,
                    child: Image.asset(
                      'assets/images/healthy_eating/images/boton prevencion del estres.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Bullet points for Estrés
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    _buildBulletPoint('🧠', 'Evita la alimentación compulsiva por estrés.', verticalPadding: 4),
                    _buildBulletPoint('😌', 'Ayuda a mantener un mejor estado de ánimo.', verticalPadding: 4),
                    _buildBulletPoint('💚', 'Promueve hábitos saludables para afrontar situaciones de tensión.', verticalPadding: 4),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Mascot (Titi lentes)
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Image.asset(
                  'assets/images/healthy_eating/images/titi lentes.png',
                  height: 165,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/gato1.png',
                    height: 145,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
            
            // Add some padding at the bottom so it doesn't collide with the controls
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
