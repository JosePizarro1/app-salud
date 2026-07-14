import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player/video_player.dart';

class MeditationRecommendationsView extends StatefulWidget {
  final List<Map<String, dynamic>> recommendedVideos;
  final bool isLoadingVideos;
  final VoidCallback onExit;
  final Function(String url) onVideoStarted;
  final VoidCallback onVideoEnded;

  const MeditationRecommendationsView({
    super.key,
    required this.recommendedVideos,
    required this.isLoadingVideos,
    required this.onExit,
    required this.onVideoStarted,
    required this.onVideoEnded,
  });

  @override
  State<MeditationRecommendationsView> createState() => _MeditationRecommendationsViewState();
}

class _MeditationRecommendationsViewState extends State<MeditationRecommendationsView> {
  String? _playingVideoUrl;
  VideoPlayerController? _activeVideoController;
  bool _isPlayerInitialized = false;

  @override
  void dispose() {
    _activeVideoController?.dispose();
    super.dispose();
  }

  void _playVideo(String url) async {
    HapticFeedback.mediumImpact();
    widget.onVideoStarted(url);
    await _activeVideoController?.dispose();
    
    setState(() {
      _playingVideoUrl = url;
      _isPlayerInitialized = false;
      _activeVideoController = VideoPlayerController.networkUrl(Uri.parse(url));
    });

    try {
      await _activeVideoController!.initialize();
      if (mounted && _playingVideoUrl == url) {
        setState(() {
          _isPlayerInitialized = true;
        });
        _activeVideoController!.play();
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  void _closeVideoPlayer() {
    _activeVideoController?.pause();
    widget.onVideoEnded();
    setState(() {
      _playingVideoUrl = null;
      _isPlayerInitialized = false;
    });
  }

  Widget _buildRecommendationsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TITI RECOMIENDA:',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF88D49E),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '"MEDITACIÓN Y RELAJACIÓN"',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF88D49E), width: 1.5),
            image: const DecorationImage(
              image: AssetImage('assets/images/mascot.webp'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRecommendations() {
    return Center(
      child: Text(
        'No se encontraron recomendaciones disponibles.',
        style: GoogleFonts.poppins(color: Colors.white70),
      ),
    );
  }

  Widget _buildFeaturedVideoCard(Map<String, dynamic> video) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: () => _playVideo(video['video_url']),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2030),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        video['thumbnail_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF2B2D3C),
                          child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 40),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 3),
                              Text(
                                video['duration'],
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF28AF52),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF28AF52).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardVideoRow(Map<String, dynamic> video) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () => _playVideo(video['video_url']),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2030),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        video['thumbnail_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF2B2D3C),
                          child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 24),
                        ),
                      ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.15),
                      ),
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            video['duration'],
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF28AF52),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsExitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: widget.onExit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF28AF52),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Volver al Menú',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _closeVideoPlayer,
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: _isPlayerInitialized && _activeVideoController != null
                    ? Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: AspectRatio(
                          aspectRatio: _activeVideoController!.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_activeVideoController!.value.isPlaying) {
                                      _activeVideoController!.pause();
                                    } else {
                                      _activeVideoController!.play();
                                    }
                                  });
                                },
                                child: VideoPlayer(_activeVideoController!),
                              ),
                              if (!_activeVideoController!.value.isPlaying)
                                GestureDetector(
                                  onTap: () => setState(() => _activeVideoController!.play()),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                                  ),
                                ),
                              VideoProgressIndicator(
                                _activeVideoController!,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Color(0xFF28AF52),
                                  bufferedColor: Colors.white24,
                                  backgroundColor: Colors.white12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF28AF52),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F121D),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: widget.isLoadingVideos && widget.recommendedVideos.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF28AF52),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 80),
                          _buildRecommendationsHeader(),
                          const SizedBox(height: 16),
                          Expanded(
                            child: widget.recommendedVideos.isEmpty
                                ? _buildEmptyRecommendations()
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: widget.recommendedVideos.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == widget.recommendedVideos.length) {
                                        return _buildRecommendationsExitButton();
                                      }
                                      
                                      final video = widget.recommendedVideos[index];
                                      if (index == 0) {
                                        return _buildFeaturedVideoCard(video);
                                      }
                                      return _buildStandardVideoRow(video);
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          if (_playingVideoUrl != null)
            _buildVideoPlayerOverlay(),
        ],
      ),
    );
  }
}
