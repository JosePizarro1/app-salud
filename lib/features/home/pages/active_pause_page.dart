import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'active_pause_timer_page.dart';
import '../../../app/services/background_music_manager.dart';
import '../../../app/services/sfx_manager.dart';

class ActivePausePage extends StatefulWidget {
  const ActivePausePage({super.key});

  @override
  State<ActivePausePage> createState() => _ActivePausePageState();
}

class _ActivePausePageState extends State<ActivePausePage> with WidgetsBindingObserver {
  final AudioPlayer _activePauseAudioPlayer = AudioPlayer()
    ..setAudioContext(AudioContext(
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
      ),
    ));

  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 1. Temporarily suspend general background music without changing user preference
    BackgroundMusicManager().suspendMusic();

    // 2. Configure player
    _activePauseAudioPlayer.setReleaseMode(ReleaseMode.loop);

    // 3. Start audio if enabled in preferences
    _handleSoundToggle();

    // 4. Listen to sound updates
    BackgroundMusicManager().isPlayingNotifier.addListener(_handleSoundToggle);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundMusicManager().isPlayingNotifier.removeListener(_handleSoundToggle);
    _activePauseAudioPlayer.dispose();
    // Restore background music when leaving the page
    BackgroundMusicManager().unsuspendMusic();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      try {
        _activePauseAudioPlayer.pause();
      } catch (_) {}
    } else if (state == AppLifecycleState.resumed) {
      _handleSoundToggle();
    }
  }

  void _handleSoundToggle() {
    final isPlaying = BackgroundMusicManager().isPlaying;
    if (isPlaying) {
      if (!_hasPlayed) {
        _activePauseAudioPlayer.play(AssetSource('audio/pausa_activa.mp3'));
        _hasPlayed = true;
      } else {
        _activePauseAudioPlayer.resume();
      }
    } else {
      _activePauseAudioPlayer.pause();
    }
  }

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
                      onPressed: () {
                        SfxManager().playClick();
                        context.pop();
                      },
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
                  const SizedBox(width: 12),
                  ValueListenableBuilder<bool>(
                    valueListenable: BackgroundMusicManager().isPlayingNotifier,
                    builder: (context, isPlaying, child) {
                      return GestureDetector(
                        onTap: () {
                          SfxManager().playClick();
                          BackgroundMusicManager().toggleMusic();
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            color: const Color(0xFF28AF52),
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background decorations (to prevent it from being too white)
          Positioned(
            bottom: -30,
            left: -30,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(45 / 360),
              child: Icon(
                Icons.spa_rounded,
                size: 180,
                color: const Color(0xFF28AF52).withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: -40,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(-20 / 360),
              child: Icon(
                Icons.directions_run_rounded,
                size: 160,
                color: const Color(0xFF28AF52).withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -40,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(15 / 360),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 150,
                color: const Color(0xFF28AF52).withValues(alpha: 0.10),
              ),
            ),
          ),

          ListView(
            physics: const BouncingScrollPhysics(),
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
          SfxManager().playClick();
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
