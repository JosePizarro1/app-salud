import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

enum HealthyEnergyState { overview, proteccion, vitalidad }

class HealthyEnergyWidget extends StatefulWidget {
  final VoidCallback? onDetailChanged;
  const HealthyEnergyWidget({super.key, this.onDetailChanged});

  @override
  State<HealthyEnergyWidget> createState() => HealthyEnergyWidgetState();
}

class HealthyEnergyWidgetState extends State<HealthyEnergyWidget> {
  HealthyEnergyState _viewState = HealthyEnergyState.overview;
  final List<bool> _benefitScales = [false, false];

  bool get isDetailActive => _viewState != HealthyEnergyState.overview;

  void resetToOverview() {
    setState(() {
      _viewState = HealthyEnergyState.overview;
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
              key: ValueKey('title_beneficios_energy_${_viewState.name}'),
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
            
            // Subtitle: "FULL ENERGÍA Y PROTECCIÓN"
            FadeInDown(
              key: ValueKey('title_energy_${_viewState.name}'),
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'FULL ENERGÍA Y\nPROTECCIÓN',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_viewState == HealthyEnergyState.overview) ...[
              // Button 1: Protección Inmune
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
                          _viewState = HealthyEnergyState.proteccion;
                        });
                        widget.onDetailChanged?.call();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 85,
                      child: Image.asset(
                        'assets/images/healthy_eating/images/boton proteccion inmune.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Button 2: Vitalidad Activa
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
                          _viewState = HealthyEnergyState.vitalidad;
                        });
                        widget.onDetailChanged?.call();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 85,
                      child: Image.asset(
                        'assets/images/healthy_eating/images/boton vitalidad activa.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mascot (Titi sitting happily)
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Image.asset(
                  'assets/images/gato1.png',
                  height: 185,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/healthy_eating/images/titi patita.webp',
                    height: 165,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ] else if (_viewState == HealthyEnergyState.proteccion) ...[
              // Active Button 1
              FadeInRight(
                duration: const Duration(milliseconds: 500),
                child: GestureDetector(
                  onTap: resetToOverview,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 2),
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 85,
                    child: Image.asset(
                      'assets/images/healthy_eating/images/boton proteccion inmune.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Bullet points for Protección
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    _buildBulletPoint('🥦', 'Fortalece las defensas naturales del cuerpo.', verticalPadding: 4),
                    _buildBulletPoint('🥦', 'Protege las células contra el daño oxidativo.', verticalPadding: 4),
                    _buildBulletPoint('💧', 'Ayuda a mantener una hidratación y digestión óptimas.', verticalPadding: 4),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Mascot
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Image.asset(
                  'assets/images/gato1.png',
                  height: 165,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/healthy_eating/images/titi patita.webp',
                    height: 145,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ] else if (_viewState == HealthyEnergyState.vitalidad) ...[
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
                      'assets/images/healthy_eating/images/boton vitalidad activa.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Bullet points for Vitalidad
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    _buildBulletPoint('⚡', 'Proporciona energía constante sin bajones.', verticalPadding: 4),
                    _buildBulletPoint('⚡', 'Mejora la resistencia física durante el ejercicio.', verticalPadding: 4),
                    _buildBulletPoint('🍎', 'Aporta nutrientes clave para la recuperación muscular.', verticalPadding: 4),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Mascot
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Image.asset(
                  'assets/images/gato1.png',
                  height: 165,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/healthy_eating/images/titi patita.webp',
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
