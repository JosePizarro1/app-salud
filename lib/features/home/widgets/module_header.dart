import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/services/background_music_manager.dart';
import '../../../app/services/sfx_manager.dart';
import '../../../app/theme/app_colors.dart';
import '../../../services/notification_service.dart';
import '../services/emergency_storage_service.dart';
import '../pages/forum_page.dart';

class ModuleHeader extends StatefulWidget {
  final bool showHome;
  final bool showBack;
  final bool showEmergency;
  final VoidCallback? onBackTap;

  const ModuleHeader({
    super.key,
    this.showHome = false,
    this.showBack = false,
    this.showEmergency = true,
    this.onBackTap,
  });

  @override
  State<ModuleHeader> createState() => _ModuleHeaderState();
}

class _ModuleHeaderState extends State<ModuleHeader> {
  bool _isConfigPressed = false;
  bool _isHomePressed = false;
  bool _isSoundPressed = false;
  bool _isBackPressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/modulo_respiracion/Bactivar_notificacion.webp'), context);
    precacheImage(const AssetImage('assets/images/modulo_respiracion/Bdesactivar_notificacion.webp'), context);
    precacheImage(const AssetImage('assets/images/boton_foro.webp'), context);
  }

  void _showSettingsDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool motivationalEnabled = prefs.getBool('motivational_notifications_enabled') ?? true;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: const Color(0xFFFFFDF9), // Modern warm wellness cream
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header Row (Title + Close Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ajustes de Bienestar',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            SfxManager().playClick();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close_rounded, size: 24, color: Color(0xFF8C8470)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 2. Sound Control Section
                    ValueListenableBuilder<bool>(
                      valueListenable: BackgroundMusicManager().isPlayingNotifier,
                      builder: (context, isPlaying, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isPlaying ? Icons.music_note_rounded : Icons.music_off_rounded,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Música de Fondo',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2D3142),
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      SfxManager().playClick();
                                      BackgroundMusicManager().toggleMusic();
                                      HapticFeedback.lightImpact();
                                    },
                                    child: SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: Image.asset(
                                        isPlaying
                                            ? 'assets/images/activar_sonido.webp'
                                            : 'assets/images/desactivar_sonido.webp',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Only show the volume slider if music is enabled/playing
                              if (isPlaying) ...[
                                const SizedBox(height: 12),
                                const Divider(color: Colors.white60, height: 1),
                                const SizedBox(height: 12),
                                ValueListenableBuilder<double>(
                                  valueListenable: BackgroundMusicManager().volumeNotifier,
                                  builder: (context, volume, child) {
                                    return Row(
                                      children: [
                                        const Icon(Icons.volume_mute_rounded, size: 20, color: Color(0xFF8C8470)),
                                        Expanded(
                                          child: Slider(
                                            value: volume,
                                            min: 0.0,
                                            max: 1.0,
                                            activeColor: AppColors.primary,
                                            inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                                            onChanged: (newVolume) {
                                              BackgroundMusicManager().setVolume(newVolume);
                                            },
                                          ),
                                        ),
                                        const Icon(Icons.volume_up_rounded, size: 20, color: Color(0xFF8C8470)),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 3. Motivational Notifications Control Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Frases Diarias',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D3142),
                                  ),
                                ),
                                Text(
                                  'Mensajes de aliento',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: const Color(0xFF8C8470),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              SfxManager().playClick();
                              final newValue = !motivationalEnabled;
                              setStateDialog(() {
                                motivationalEnabled = newValue;
                              });
                              HapticFeedback.lightImpact();
                              await prefs.setBool('motivational_notifications_enabled', newValue);
                              if (newValue) {
                                await NotificationService().scheduleMotivationalNotification(force: true);
                              } else {
                                await NotificationService().cancelMotivationalNotification();
                              }
                            },
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.asset(
                                motivationalEnabled
                                    ? 'assets/images/modulo_respiracion/Bactivar_notificacion.webp'
                                    : 'assets/images/modulo_respiracion/Bdesactivar_notificacion.webp',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE8E5CE), height: 1),
                    const SizedBox(height: 24),

                    // 4. Logout Section
                    ElevatedButton.icon(
                      onPressed: () async {
                        SfxManager().playClick();
                        Navigator.of(context).pop();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('is_admin_mode');
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                      label: Text(
                        'Cerrar sesión',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A71), // Coral
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _triggerConfig() async {
    setState(() => _isConfigPressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isConfigPressed = false);
    }
  }

  void _triggerBack() async {
    setState(() => _isBackPressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isBackPressed = false);
    }
  }

  void _triggerHome() async {
    setState(() => _isHomePressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isHomePressed = false);
    }
  }

  void _triggerSound() async {
    setState(() => _isSoundPressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isSoundPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // ── Botón Configuración (Tuerca) - Solo si no hay botones de navegación a la izquierda ──
        if (!widget.showHome && !widget.showBack)
          Positioned(
            left: screenWidth * 0.05,
            top: screenHeight * 0.091,
            child: AnimatedScale(
              scale: _isConfigPressed ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: () {
                  SfxManager().playClick();
                  _triggerConfig();
                  _showSettingsDialog(context);
                },
                child: SizedBox(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  child: Image.asset(
                    'assets/images/Bconfiguracion.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

        // ── Botón Sonido (Música de fondo) ──
        Positioned(
          right: widget.showEmergency ? screenWidth * 0.405 : screenWidth * 0.05,
          top: screenHeight * 0.092,
          child: ValueListenableBuilder<bool>(
            valueListenable: BackgroundMusicManager().isPlayingNotifier,
            builder: (context, isPlaying, child) {
              return AnimatedScale(
                scale: _isSoundPressed ? 1.3 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: GestureDetector(
                  onTap: () {
                    SfxManager().playClick();
                    _triggerSound();
                    BackgroundMusicManager().toggleMusic();
                    HapticFeedback.lightImpact();
                  },
                  child: SizedBox(
                    width: screenWidth * 0.143,
                    height: screenWidth * 0.143,
                    child: Image.asset(
                      isPlaying
                          ? 'assets/images/activar_sonido.webp'
                          : 'assets/images/desactivar_sonido.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Botón Back (Flecha atrás) ──
        if (widget.showBack)
          Positioned(
            left: screenWidth * 0.05,
            top: screenHeight * 0.091,
            child: AnimatedScale(
              scale: _isBackPressed ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: () {
                  SfxManager().playClick();
                  _triggerBack();
                  HapticFeedback.lightImpact();
                  if (widget.onBackTap != null) {
                    widget.onBackTap!();
                  } else {
                    context.pop();
                  }
                },
                child: SizedBox(
                  width: screenWidth * 0.165,
                  height: screenWidth * 0.165,
                  child: Image.asset(
                    'assets/images/boton_back.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

        // ── Botón Home (Solo si showHome es true) ──
        if (widget.showHome)
          Positioned(
            left: widget.showBack
                ? screenWidth * 0.198
                : screenWidth * 0.05,
            top: screenHeight * 0.091,
            child: AnimatedScale(
              scale: _isHomePressed ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: () {
                  SfxManager().playClick();
                  _triggerHome();
                  context.go('/home');
                },
                child: SizedBox(
                  width: screenWidth * 0.165,
                  height: screenWidth * 0.165,
                  child: Image.asset(
                    'assets/images/Bhome.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

        // ── Botón Foro (Al costado izquierdo del de emergencia) ──
        if (widget.showEmergency)
          Positioned(
            right: screenWidth * 0.228,
            top: screenHeight * 0.085,
            child: const _ForoButton(),
          ),

        // ── Botón Emergencia (Pulsando de forma aislada para optimizar CPU) ──
        if (widget.showEmergency)
          Positioned(
            right: screenWidth * 0.05,
            top: screenHeight * 0.085,
            child: const _EmergencyButton(),
          ),
      ],
    );
  }
}

class _EmergencyButton extends StatefulWidget {
  const _EmergencyButton();

  @override
  State<_EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<_EmergencyButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 1.0,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerEmergency() async {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
    
    // Save click locally and sync to Supabase (Lima, Peru/local timezone safe)
    EmergencyStorageService.recordClick();

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isPressed = false);
    }
    if (mounted) {
      context.push('/emergency');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 1.3 : _controller.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          SfxManager().playClick();
          _triggerEmergency();
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.166,
          height: MediaQuery.of(context).size.width * 0.166,
          child: Image.asset(
            'assets/images/Bemergencia.webp',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _ForoButton extends StatefulWidget {
  const _ForoButton();

  @override
  State<_ForoButton> createState() => _ForoButtonState();
}

class _ForoButtonState extends State<_ForoButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isPressed = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 1.0,
      upperBound: 1.06,
    )..repeat(reverse: true);

    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasConnection = results.any((result) => result != ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _isOnline = hasConnection;
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final hasConnection = results.any((result) => result != ConnectivityResult.none);
    if (mounted) {
      setState(() {
        _isOnline = hasConnection;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _triggerForo() async {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();

    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() => _isPressed = false);
    }
    
    if (mounted) {
      ForumPage.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.166,
        height: MediaQuery.of(context).size.width * 0.166,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.saturation,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/boton_foro.webp',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 1.2 : _controller.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          SfxManager().playClick();
          _triggerForo();
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.166,
          height: MediaQuery.of(context).size.width * 0.166,
          child: Image.asset(
            'assets/images/boton_foro.webp',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
