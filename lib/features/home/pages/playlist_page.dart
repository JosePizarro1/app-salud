// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  // ── Audio Player State ──
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentIndex = 0;
  bool _isLooping = false;
  bool _isShuffle = false;

  // View state: false = List View, true = Spotify Player View
  bool _showPlayer = false;

  // Volume state
  double _volume = 0.5;

  // Stream Subscriptions
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _completionSub;
  StreamSubscription? _stateSub;

  // Track Liked State (Map of track index to liked boolean)
  late final Map<int, bool> _likedTracks;

  // ── Tracks List (Themed colors and icons) ──
  final List<Map<String, dynamic>> _tracks = [
    {
      'title': 'Clair de Lune',
      'subtitle': 'Claude Debussy',
      'path': 'audio/playlist/Clair de Lune (Studio Version).mp3',
      'duration': '05:07',
      'color': const Color(0xFF7D72F0), // Vibrant lavender
      'icon': Icons.keyboard_rounded,
    },
    {
      'title': 'Nocturne Op. 9 No. 2',
      'subtitle': 'Frédéric Chopin',
      'path': 'audio/playlist/Chopin - Nocturne op.9 No.2.mp3',
      'duration': '04:30',
      'color': const Color(0xFF3884E0), // Vibrant blue
      'icon': Icons.nightlight_round_rounded,
    },
    {
      'title': 'Spiegel im Spiegel',
      'subtitle': 'Arvo Pärt',
      'path': 'audio/playlist/Spiegel im Spiegel, for Viola & Piano.mp3',
      'duration': '10:04',
      'color': const Color(0xFF2AA29C), // Vibrant teal
      'icon': Icons.spa_rounded,
    },
    {
      'title': 'River Flows in You',
      'subtitle': 'Yiruma',
      'path': 'audio/playlist/Yiruma - River Flows in You.mp3',
      'duration': '03:33',
      'color': const Color(0xFF1E9BB8), // Vibrant cyan
      'icon': Icons.waves_rounded,
    },
    {
      'title': 'Interstellar Main Theme',
      'subtitle': 'Hans Zimmer',
      'path': 'audio/playlist/Hans Zimmer - Interstellar - Main Theme (Piano Version)  Sheet Music.mp3',
      'duration': '04:47',
      'color': const Color(0xFFDC6C43), // Vibrant coral
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _likedTracks = {
      0: true, // Clair de Lune liked by default as in the mockup
    };
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.setVolume(_volume);

    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _completionSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        if (_isLooping) {
          _playCurrentTrack();
        } else {
          _playNextTrack();
        }
      }
    });
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completionSub?.cancel();
    _stateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ── Audio Player Actions ──
  Future<void> _playCurrentTrack() async {
    try {
      final path = _tracks[_currentIndex]['path']!;
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('Error playing track: $e');
    }
  }

  Future<void> _selectAndPlayTrack(int index) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentIndex = index;
      _position = Duration.zero;
      _duration = Duration.zero;
      _showPlayer = true;
    });
    await _playCurrentTrack();
  }

  Future<void> _togglePlayPause() async {
    HapticFeedback.mediumImpact();
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_position == Duration.zero && _duration == Duration.zero) {
        await _playCurrentTrack();
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  Future<void> _playNextTrack() async {
    HapticFeedback.lightImpact();
    int nextIndex = _currentIndex;
    if (_isShuffle) {
      final list = List.generate(_tracks.length, (i) => i)..remove(_currentIndex);
      list.shuffle();
      nextIndex = list.first;
    } else {
      nextIndex = (_currentIndex + 1) % _tracks.length;
    }

    setState(() {
      _currentIndex = nextIndex;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await _playCurrentTrack();
  }

  Future<void> _playPreviousTrack() async {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = (_currentIndex - 1 + _tracks.length) % _tracks.length;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await _playCurrentTrack();
  }

  Future<void> _seekTo(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  Future<void> _changeVolume(double value) async {
    setState(() => _volume = value);
    await _audioPlayer.setVolume(value);
  }

  void _toggleLike(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      final currentLiked = _likedTracks[index] ?? false;
      _likedTracks[index] = !currentLiked;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo_playlist.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _showPlayer ? _buildPlayerView() : _buildListView(),
        ),
      ),
    );
  }

  // Helper to build audio visualizer waveform bar row
  Widget _buildWaveform(bool isActive) {
    final random = Random(42); // Seed to keep visual layout stable
    return SizedBox(
      height: 14,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(26, (index) {
          final double baseHeight = 3.0 + random.nextInt(8);
          // Subtle pulsation simulation when active
          final double height = isActive
              ? (baseHeight + (index % 3 == 0 ? 3.0 : -1.0)).clamp(3.0, 14.0)
              : baseHeight;

          return Container(
            width: 1.5,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 0.75),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF9083ED) // Active brand purple
                  : Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }

  // ── 1. List / Selection View (Mockup Style) ──
  Widget _buildListView() {
    return SafeArea(
      key: const ValueKey('ListView'),
      child: Column(
        children: [
          const SizedBox(height: 20), // Generous top margin for mobile notches
          
          // Translucent top navigation buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  
                  // Row: Title on Left, Sleep Cat (gato1.png) on Right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Escucha y',
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Relájate',
                              style: GoogleFonts.outfit(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF9083ED),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Música relajante para dormir\ny encontrar tu calma',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sleeping Ocelot Titi (titi zzz.png)
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/titi zzz.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 36),

                  // Sparkle selection tag
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFF9083ED), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Selección especial',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9B82F6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // Tracks Cards List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _tracks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final track = _tracks[index];
                      final isSelected = index == _currentIndex;
                      final isPlayingThis = isSelected && _isPlaying;
                      final isLiked = _likedTracks[index] ?? false;

                      return GestureDetector(
                        onTap: () => _selectAndPlayTrack(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF9083ED).withOpacity(0.2)
                                  : Colors.white.withOpacity(0.04),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Art Thumbnail with play overlay
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: track['cover'] != null
                                      ? DecorationImage(
                                          image: AssetImage(track['cover'] as String),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  gradient: track['cover'] == null
                                      ? LinearGradient(
                                          colors: [
                                            (track['color'] as Color).withOpacity(0.35),
                                            (track['color'] as Color).withOpacity(0.1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    if (track['cover'] == null)
                                      Center(
                                        child: Icon(
                                          track['icon'] as IconData,
                                          color: Colors.white.withOpacity(0.6),
                                          size: 26,
                                        ),
                                      ),
                                    // Play/Pause circle overlay
                                    Center(
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isPlayingThis
                                              ? const Color(0xFF9083ED).withOpacity(0.85)
                                              : Colors.black.withOpacity(0.4),
                                          boxShadow: isPlayingThis
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF9083ED).withOpacity(0.45),
                                                    blurRadius: 8,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Icon(
                                          isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Track detail and Waveform
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track['title']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      track['subtitle']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.4),
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Render visualizer waveform
                                    _buildWaveform(isPlayingThis),
                                  ],
                                ),
                              ),

                              // Duration and Heart icon
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      track['duration']!,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () => _toggleLike(index),
                                      child: Icon(
                                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        color: isLiked ? const Color(0xFF9083ED) : Colors.white.withOpacity(0.2),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50), // Generous bottom padding for mobile systems
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Player View (Spotify style) ──
  Widget _buildPlayerView() {
    final currentTrack = _tracks[_currentIndex];

    return SafeArea(
      key: const ValueKey('PlayerView'),
      child: Column(
        children: [
          const SizedBox(height: 20), // Generous top margin for mobile notches
          
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showPlayer = false),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 44.0), // Balance arrow width
                      child: Text(
                        'REPRODUCIENDO...',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Player Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 50), // Spaced top & bottom margins for mobile
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Beautiful Glowing Crescent Moon and Stars Widget (Sleeping Moon theme)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.72,
                    height: MediaQuery.of(context).size.width * 0.72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0F172A).withOpacity(0.8), // Deep slate-dark
                          const Color(0xFF1E293B).withOpacity(0.5), // Slate-dark
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Inner ring for depth
                        Container(
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                        ),
                        // Golden crescent moon
                        const Icon(
                          Icons.nights_stay_rounded,
                          size: 110,
                          color: Color(0xFFFFDF6D), // Beautiful soft gold moon
                        ),
                        // Floating Star 1
                        Positioned(
                          top: 45,
                          right: 55,
                          child: Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        // Floating Star 2
                        Positioned(
                          bottom: 50,
                          left: 60,
                          child: Icon(
                            Icons.star_rounded,
                            size: 10,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        // Floating Star 3
                        Positioned(
                          top: 130,
                          left: 45,
                          child: Icon(
                            Icons.star_border_purple500_rounded,
                            size: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Track Metadata
                  Text(
                    currentTrack['title']!.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentTrack['subtitle']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Position Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.secondary,
                      inactiveTrackColor: Colors.white.withOpacity(0.12),
                      thumbColor: Colors.white,
                      overlayColor: AppColors.secondary.withOpacity(0.2),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      min: 0,
                      max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 100.0,
                      value: _position.inSeconds.toDouble().clamp(
                            0.0,
                            _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 100.0,
                          ),
                      onChanged: _seekTo,
                    ),
                  ),

                  // Timing Label Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Player control buttons (Shuffle, Prev, Play, Next, Repeat)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shuffle
                      IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: _isShuffle ? const Color(0xFF9083ED) : Colors.white.withOpacity(0.6),
                        ),
                        iconSize: 24,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _isShuffle = !_isShuffle);
                        },
                      ),

                      // Skip Previous
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                        iconSize: 36,
                        onPressed: _playPreviousTrack,
                      ),

                      // Play / Pause Circle
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      // Skip Next
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                        iconSize: 36,
                        onPressed: _playNextTrack,
                      ),

                      // Repeat / Loop
                      IconButton(
                        icon: Icon(
                          _isLooping ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                          color: _isLooping ? const Color(0xFF9083ED) : Colors.white.withOpacity(0.6),
                        ),
                        iconSize: 24,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _isLooping = !_isLooping);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Volume Bar
                  Row(
                    children: [
                      Icon(
                        Icons.volume_down_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 20,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white.withOpacity(0.6),
                            inactiveTrackColor: Colors.white.withOpacity(0.1),
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withOpacity(0.1),
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                          ),
                          child: Slider(
                            value: _volume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: _changeVolume,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
