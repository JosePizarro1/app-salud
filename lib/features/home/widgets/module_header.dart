import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../../app/services/background_music_manager.dart';

class ModuleHeader extends StatefulWidget {
  final bool showHome;
  final bool showBack;
  final VoidCallback? onBackTap;

  const ModuleHeader({
    super.key,
    this.showHome = false,
    this.showBack = false,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Cerrar sesión',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142),
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.outfit(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A71),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Cerrar sesión',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
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
            top: screenHeight * 0.10,
            child: AnimatedScale(
              scale: _isConfigPressed ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: () {
                  _triggerConfig();
                  _showLogoutDialog(context);
                },
                child: SizedBox(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
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
          right: screenWidth * 0.24,
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
                    _triggerSound();
                    BackgroundMusicManager().toggleMusic();
                    HapticFeedback.lightImpact();
                  },
                  child: SizedBox(
                    width: screenWidth * 0.13,
                    height: screenWidth * 0.13,
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
                  _triggerBack();
                  HapticFeedback.lightImpact();
                  if (widget.onBackTap != null) {
                    widget.onBackTap!();
                  } else {
                    context.pop();
                  }
                },
                child: SizedBox(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
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
                ? screenWidth * 0.18
                : screenWidth * 0.05,
            top: screenHeight * 0.091,
            child: AnimatedScale(
              scale: _isHomePressed ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: () {
                  _triggerHome();
                  context.go('/home');
                },
                child: SizedBox(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  child: Image.asset(
                    'assets/images/Bhome.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

        // ── Botón Emergencia (Pulsando de forma aislada para optimizar CPU) ──
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
        onTap: _triggerEmergency,
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
