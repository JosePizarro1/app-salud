import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/bounceable_scale.dart';
import '../../../../app/widgets/custom_fade_in.dart';

class MeditationSelectionView extends StatefulWidget {
  final Function(int minutes) onStartSession;

  const MeditationSelectionView({
    super.key,
    required this.onStartSession,
  });

  @override
  State<MeditationSelectionView> createState() => _MeditationSelectionViewState();
}

class _MeditationSelectionViewState extends State<MeditationSelectionView> {
  int? _selectedTimeOption;
  bool _isCommitted = false;
  bool _wiggleCheckbox = false;

  void _onTimeButtonTap(int minutes) {
    setState(() {
      _selectedTimeOption = minutes;
    });
    if (_isCommitted) {
      widget.onStartSession(minutes);
    }
  }

  void _triggerWiggle() {
    setState(() => _wiggleCheckbox = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _wiggleCheckbox = false);
      }
    });
  }

  void _handleStartPress() {
    if (_selectedTimeOption == null) return;
    if (!_isCommitted) {
      _triggerWiggle();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Por favor, confirma tu compromiso de bienestar primero! 🌸',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }
    widget.onStartSession(_selectedTimeOption!);
  }

  Widget _buildTimeButton({required String imagePath, required int minutes}) {
    final bool isSelected = _selectedTimeOption == minutes;
    final bool isAnySelected = _selectedTimeOption != null;
    final double opacity = !isAnySelected || isSelected ? 1.0 : 0.55;

    return BounceableScale(
      onTap: () => _onTimeButtonTap(minutes),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: opacity,
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.088,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCommitmentCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: _wiggleCheckbox
          ? Matrix4.translationValues(5.0 * (DateTime.now().millisecond % 2 == 0 ? 1 : -1), 0.0, 0.0)
          : Matrix4.identity(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _wiggleCheckbox
            ? const Color(0xFFFFF2ED)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isCommitted = !_isCommitted;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 2, right: 12),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _isCommitted ? const Color(0xFF28AF52) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isCommitted
                      ? const Color(0xFF28AF52)
                      : _wiggleCheckbox
                          ? AppColors.primary
                          : const Color(0xFF28AF52),
                  width: 2.2,
                ),
              ),
              child: _isCommitted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isCommitted = !_isCommitted;
                });
              },
              child: Text(
                'Me comprometo a participar activamente en mis sesiones de meditación guiada para apoyar mi bienestar emocional y universitario.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('selection_view'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 110),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF88D49E),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomFadeIn(
                      duration: const Duration(milliseconds: 600),
                      slideUp: false,
                      child: Column(
                        children: [
                          Text(
                            '¡Tomemos una',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3B60B3),
                              height: 1.15,
                            ),
                          ),
                          Text(
                            'pequeña pausa!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF28AF52),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Cada sesión se adapta a tu tiempo disponible.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4C7CC2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTimeButton(
                      imagePath: 'assets/images/modulo_respiracion/B1minuto.webp',
                      minutes: 1,
                    ),
                    const SizedBox(height: 10),
                    _buildTimeButton(
                      imagePath: 'assets/images/modulo_respiracion/B3minutos.webp',
                      minutes: 3,
                    ),
                    const SizedBox(height: 10),
                    _buildTimeButton(
                      imagePath: 'assets/images/modulo_respiracion/B5minutos.webp',
                      minutes: 5,
                    ),

                    if (_selectedTimeOption != null) ...[
                      const SizedBox(height: 24),
                      CustomFadeIn(
                        duration: const Duration(milliseconds: 350),
                        slideUp: true,
                        child: Column(
                          children: [
                            Text(
                              'Hoy elijo dedicarme unos minutos',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4C7CC2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCommitmentCheckbox(),
                            if (_isCommitted) ...[
                              const SizedBox(height: 20),
                              CustomFadeIn(
                                duration: const Duration(milliseconds: 250),
                                slideUp: true,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _handleStartPress,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF28AF52),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 1.5,
                                    ),
                                    child: Text(
                                      'Comenzar Meditación',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
