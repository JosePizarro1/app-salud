import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'active_pause_timer_page.dart';

class ActivePausePage extends StatelessWidget {
  const ActivePausePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFEBF7EE), // Soft green background
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0, left: 16.0, right: 16.0, bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF28AF52)),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Pausa activa',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.accessibility_new_rounded, color: Color(0xFF28AF52)),
                          ],
                        ),
                        Text(
                          'Muévete, respira y recarga tu energía',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4A5D4E),
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildExerciseCard(
            context: context,
            number: 1,
            title: 'Marcha activa',
            description: 'Camina por tu escuela/casa o donde estés, balanceando los brazos.',
            time: '1 minuto',
            durationSeconds: 60,
            imagePath: 'assets/images/pausa_activa/image1.png',
            color: const Color(0xFF81C784), // Green
          ),
          _buildExerciseCard(
            context: context,
            number: 2,
            title: 'Estiramiento del cuello',
            description: 'Inclina suavemente la cabeza hacia adelante y hacia atrás.',
            time: '20 segundos',
            durationSeconds: 20,
            imagePath: 'assets/images/pausa_activa/image2.png',
            color: const Color(0xFF64B5F6), // Blue
          ),
          _buildExerciseCard(
            context: context,
            number: 3,
            title: 'Rotación de hombros',
            description: 'Haz círculos con ambos hombros hacia adelante y atrás.',
            time: '20 segundos',
            durationSeconds: 20,
            imagePath: 'assets/images/pausa_activa/image3.png',
            color: const Color(0xFFFFD54F), // Yellow
          ),
          _buildExerciseCard(
            context: context,
            number: 4,
            title: 'Estiramiento de brazos y espalda',
            description: 'Entrelaza los dedos y empuja los brazos al frente mientras se encorva ligeramente la espalda.',
            time: '20 segundos',
            durationSeconds: 20,
            imagePath: 'assets/images/pausa_activa/image4.png',
            color: const Color(0xFFBA68C8), // Purple
          ),
          _buildExerciseCard(
            context: context,
            number: 5,
            title: 'Estiramiento lateral',
            description: 'Eleva un brazo y flexiona el tronco hacia el lado contrario. Alterna ambos lados.',
            time: '20 segundos',
            durationSeconds: 20,
            imagePath: 'assets/images/pausa_activa/image5.png',
            color: const Color(0xFF4DB6AC), // Teal
          ),
          _buildExerciseCard(
            context: context,
            number: 6,
            title: 'Respiración profunda',
            description: 'Inhala por nariz y exhala lentamente por boca.',
            time: '30 segundos',
            durationSeconds: 30,
            imagePath: 'assets/images/pausa_activa/image6.png',
            color: const Color(0xFF64B5F6), // Blue
          ),
          
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF7EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFF28AF52)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Pequeñas pausas, grandes cambios!\nTu cuerpo y mente te lo agradecerán.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF1B5E20),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Icon(Icons.favorite_outline_rounded, color: Color(0xFF28AF52)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExerciseCard({
    required BuildContext context,
    required int number,
    required String title,
    required String description,
    required String time,
    required int durationSeconds,
    required String imagePath,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          final exercise = ActivePauseExercise(
            number: number,
            title: title,
            description: description,
            durationSeconds: durationSeconds,
            color: color,
            imagePath: imagePath,
          );
          context.push('/active_pause_timer', extra: exercise);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Number Circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$number',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                    ),
                    // Time Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }
}
