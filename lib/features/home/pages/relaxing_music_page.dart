import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/module_header.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/bounceable_scale.dart';
import '../../../app/services/background_music_manager.dart';

class RelaxingMusicPage extends StatefulWidget {
  const RelaxingMusicPage({super.key});

  @override
  State<RelaxingMusicPage> createState() => _RelaxingMusicPageState();
}

class _RelaxingMusicPageState extends State<RelaxingMusicPage> {
  int? _playingIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _soundOptions = [
    {
      'title': 'Sonidos binaurales',
      'imagePath': 'assets/images/sonidos_bina.webp',
      'audioAsset': 'audio/ruido_binaural.mp3',
    },
    {
      'title': 'Ruido blanco',
      'imagePath': 'assets/images/ruido_blanco.webp',
      'audioAsset': 'audio/ruido_blanco.mp3',
    },
    {
      'title': 'Piano suave',
      'imagePath': 'assets/images/piano_suave.webp',
      'audioAsset': 'audio/piano_para_estudiar.mp3',
    },
    {
      'title': 'Concentración',
      'imagePath': 'assets/images/concentracion.webp',
      'audioAsset': 'audio/sonido_concentracion.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    BackgroundMusicManager().isPlayingNotifier.addListener(_onBgMusicChanged);
  }

  void _onBgMusicChanged() {
    // Si el usuario activa manualmente la música de fondo desde el header, pausamos la tarjeta actual
    if (BackgroundMusicManager().isPlaying && _playingIndex != null) {
      if (mounted) {
        setState(() {
          _playingIndex = null;
        });
      }
      _audioPlayer.pause();
    }
  }

  @override
  void dispose() {
    BackgroundMusicManager().isPlayingNotifier.removeListener(_onBgMusicChanged);
    // Restaura la música de fondo al salir si el usuario la tenía activada
    BackgroundMusicManager().unsuspendMusic();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Source _getWebSafeSource(String relativeAssetPath) {
    if (kIsWeb) {
      return UrlSource('assets/$relativeAssetPath');
    }
    return AssetSource(relativeAssetPath);
  }

  void _togglePlay(int index) async {
    HapticFeedback.mediumImpact();

    if (_playingIndex == index) {
      // Si el mismo sonido está sonando, lo pausamos
      setState(() {
        _playingIndex = null;
      });
      await _audioPlayer.pause();
    } else {
      // Suspendemos la música ambiental sin borrar la preferencia del usuario (ícono del header a desactivado)
      await BackgroundMusicManager().suspendMusic();

      setState(() {
        _playingIndex = index;
      });

      final String audioAsset = _soundOptions[index]['audioAsset'];
      try {
        await _audioPlayer.stop();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(_getWebSafeSource(audioAsset));
      } catch (e) {
        debugPrint('Error reproduciendo pista de sonido $audioAsset: $e');
      }
    }

    final String title = _soundOptions[index]['title'];
    final bool isNowPlaying = _playingIndex == index;

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowPlaying
              ? '▶️ Reproduciendo: $title'
              : '⏸️ Pausado: $title',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isNowPlaying ? AppColors.secondary : Colors.grey[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image con filtro sutil de desenfoque
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_modulo3.webp',
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),

          // Scrollable Body Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 155), // Espacio limpio bajo los íconos de ModuleHeader

                  // Title: SONIDOS RELAJANTES
                  Text(
                    'SONIDOS RELAJANTES',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: const Color(0xFF234728),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 1. Hero Card ("Encuentra tu calma" con Titi y marcas de agua)
                  FadeInUp(
                    duration: const Duration(milliseconds: 450),
                    child: _buildHeroCard(),
                  ),

                  const SizedBox(height: 16),

                  // 2. Los 4 Botones de Sonidos personalizados en imágenes WebP con animación escalonada
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _soundOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final option = _soundOptions[index];
                      final bool isPlaying = _playingIndex == index;

                      return FadeInUp(
                        duration: const Duration(milliseconds: 450),
                        delay: Duration(milliseconds: 120 + index * 140),
                        child: _buildSoundCard(
                          index: index,
                          title: option['title'],
                          imagePath: option['imagePath'],
                          isPlaying: isPlaying,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Header estándar siempre presente en la parte superior
          const ModuleHeader(showHome: true),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFDF7),
            Color(0xFFFFF0D6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5A138),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A138).withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Watermark Soft Icons (Hojas, Destellos y Notas musicales translúcidas)
          Positioned(
            top: -12,
            left: -10,
            child: Icon(
              Icons.spa_rounded,
              size: 75,
              color: const Color(0xFF28AF52).withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: -15,
            left: 50,
            child: Icon(
              Icons.music_note_rounded,
              size: 65,
              color: const Color(0xFFE5A138).withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 6,
            right: 120,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 32,
              color: const Color(0xFFE5A138).withValues(alpha: 0.15),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: Icon(
              Icons.eco_rounded,
              size: 70,
              color: const Color(0xFF28AF52).withValues(alpha: 0.09),
            ),
          ),

          // Main Card Content Layer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text Column Left: "Encuentra tu calma"
                Expanded(
                  flex: 5,
                  child: Text(
                    'Encuentra\ntu calma',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF234728),
                      height: 1.15,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Titi sleeping image right
                Expanded(
                  flex: 4,
                  child: Image.asset(
                    'assets/images/titi_escuchando_musica.webp',
                    fit: BoxFit.contain,
                    height: 105,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/mascot.webp',
                        fit: BoxFit.contain,
                        height: 90,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('🎧🐯', style: TextStyle(fontSize: 36)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundCard({
    required int index,
    required String title,
    required String imagePath,
    required bool isPlaying,
  }) {
    return BounceableScale(
      onTap: () => _togglePlay(index),
      child: AnimatedScale(
        scale: isPlaying ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              if (isPlaying)
                BoxShadow(
                  color: const Color(0xFF28AF52).withValues(alpha: 0.5),
                  blurRadius: 18,
                  spreadRadius: 4,
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPlaying ? const Color(0xFF28AF52) : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF234728),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
