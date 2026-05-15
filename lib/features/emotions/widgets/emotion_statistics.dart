import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emotion_entry.dart';
import '../services/emotion_storage.dart';

class EmotionStatistics extends StatelessWidget {
  final Map<EmotionType, int> monthlyStats;
  final Map<EmotionType, int> weeklyStats;
  final int year;
  final int month;

  const EmotionStatistics({
    super.key,
    required this.monthlyStats,
    required this.weeklyStats,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    // Find predominant emotion for the month
    EmotionType? predominant;
    int maxCount = 0;
    for (final entry in monthlyStats.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        predominant = entry.key;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Estadísticas',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Predominant Emotion ──
          if (predominant != null && maxCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: predominant.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: predominant.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Text(predominant.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emoción predominante del mes',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          predominant.label,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: predominant.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Center(
              child: Text(
                'Aún no hay registros este mes',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
