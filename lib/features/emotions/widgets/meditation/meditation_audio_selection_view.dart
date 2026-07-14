import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/widgets/bounceable_scale.dart';
import '../../../../app/widgets/custom_fade_in.dart';

class MeditationAudioSelectionView extends StatelessWidget {
  final int selectedMinutes;
  final Function(int audioIndex) onAudioSelected;
  final VoidCallback onClose;

  static const List<String> _audioTitles = [
    'Meditación de Calma Interior 🌸',
    'Conexión con tu Respiración 🌿',
    'Relajación Consciente 🌙',
    'Momento de Bienestar ✨',
  ];

  const MeditationAudioSelectionView({
    super.key,
    required this.selectedMinutes,
    required this.onAudioSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('audio_selection_view'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              CustomFadeIn(
                duration: const Duration(milliseconds: 500),
                slideUp: false,
                child: Column(
                  children: [
                    const Text('🎧', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Elige tu meditación',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3B60B3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sesión de $selectedMinutes ${selectedMinutes == 1 ? 'minuto' : 'minutos'}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF28AF52),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Audio option cards
              ...List.generate(4, (i) {
                final idx = i + 1;
                final colors = [
                  [const Color(0xFF88D49E), const Color(0xFF28AF52)],
                  [const Color(0xFF9BB8ED), const Color(0xFF3B60B3)],
                  [const Color(0xFFE8A0C8), const Color(0xFFE56BB5)],
                  [const Color(0xFFFFCC80), const Color(0xFFFF9800)],
                ];
                final bgColors = [
                  const Color(0xFFEBF7EE), // Solid Light Green
                  const Color(0xFFEEF2FC), // Solid Light Blue
                  const Color(0xFFFDF0F8), // Solid Light Pink
                  const Color(0xFFFFF7EB), // Solid Light Orange/Cream
                ];
                final icons = ['🌸', '🌿', '🌙', '✨'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: CustomFadeIn(
                    duration: const Duration(milliseconds: 400),
                    delay: i * 0.12,
                    slideUp: true,
                    child: BounceableScale(
                      onTap: () => onAudioSelected(idx),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          color: bgColors[i],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors[i][1],
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors[i][0].withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colors[i][1].withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(icons[i], style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Audio $idx',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: colors[i][1],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _audioTitles[i],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2D3142),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.play_circle_fill_rounded,
                              color: colors[i][1],
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              // Back button
              TextButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'Volver al menú',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
