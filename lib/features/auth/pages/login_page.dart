import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/vitali_dialog.dart';
import '../../../app/services/sfx_manager.dart';
import '../../../app/services/background_music_manager.dart';
import '../../../app/services/stats_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final emailCtrl = _DomainTextEditingController(domain: "@unjbg.edu.pe");
  final passCtrl = TextEditingController();
  bool isLoading = false;
  bool _obscurePass = true;

  // Banner properties
  bool _showBanner = false;
  Timer? _bannerTimer;
  late final AnimationController _bannerPulseController;
  bool _isPrecached = false;

  @override
  void initState() {
    super.initState();
    _bannerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0.98,
      upperBound: 1.02,
    );
    // Show login banner after 1.5 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _showLoginBanner();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      precacheImage(const AssetImage('assets/images/noti_interna.webp'), context);
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPulseController.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _showLoginBanner() {
    if (!mounted) return;
    
    // Play noti sound inside the app if global settings allow
    SfxManager().playNotiSound();

    setState(() {
      _showBanner = true;
    });

    _bannerPulseController.repeat(reverse: true);

    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showBanner = false;
        });
        _bannerPulseController.stop();
      }
    });
  }

  void _login() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      VitaliDialog.show(
        context,
        title: "Campos vacíos",
        message: "Por favor ingresa tu correo y contraseña para continuar.",
      );
      return;
    }

    // Interceptar acceso de Administrador
    final username = emailCtrl.text.replaceAll('@unjbg.edu.pe', '').trim();
    if (username == 'admin123' && passCtrl.text.trim() == 'admin123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin_mode', true);
      
      // Intentar autenticación en Supabase en segundo plano para habilitar permisos RLS
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: 'admin123@unjbg.edu.pe',
          password: 'admin123',
        );
      } catch (_) {
        // Fallback silencioso si no hay conexión o no existe el usuario en la DB
      }
      
      if (mounted) context.go('/admin/dashboard');
      return;
    }

    setState(() => isLoading = true);
    
    try {
      final fullEmail = emailCtrl.text.trim().contains('@') 
          ? emailCtrl.text.trim() 
          : "${emailCtrl.text.trim()}@unjbg.edu.pe";
          
      await Supabase.instance.client.auth.signInWithPassword(
        email: fullEmail,
        password: passCtrl.text.trim(),
      );
      // Sync any offline stats recorded previously
      StatsSyncService().syncUnsyncedStats();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin_mode', false);
      
      if (mounted) context.go('/home');
    } on AuthException catch (_) {
      if (mounted) {
        setState(() => isLoading = false);
        VitaliDialog.show(
          context,
          title: "Acceso denegado",
          message: "Credenciales incorrectas. Por favor, revisa tu correo o contraseña.",
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoading = false);
        VitaliDialog.show(
          context,
          title: "Algo salió mal",
          message: "Ocurrió un error inesperado. Por favor intenta de nuevo.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image with Blur ──
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(
              begin: 0.0,
              end: MediaQuery.of(context).viewInsets.bottom > 0 ? 5.0 : 0.0,
            ),
            builder: (context, blurValue, child) {
              return ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                child: Image.asset(
                  'assets/images/login_fondo.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  gaplessPlayback: true,
                ),
              );
            },
          ),

          // ── Botón de Sonido en la esquina superior derecha ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: ValueListenableBuilder<bool>(
              valueListenable: BackgroundMusicManager().isPlayingNotifier,
              builder: (context, isPlaying, child) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    BackgroundMusicManager().toggleMusic();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: isDark ? Colors.white70 : const Color(0xFF6B4F35),
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: MediaQuery.of(context).viewInsets.bottom > 0
                ? MediaQuery.of(context).size.height * 0.22
                : MediaQuery.of(context).size.height * 0.60,
            bottom: 0,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 30,
                right: 30,
                bottom: 37 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // 📧 User Input (Mint)
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _VitaliInput(
                          controller: emailCtrl,
                          hint: "Usuario institucional",
                          icon: Icons.alternate_email_rounded,
                          color: Colors.white,
                          borderColor: AppColors.accent,
                          isDark: isDark,
                          enabled: !isLoading,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔒 Pass Input (Lavender)
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _VitaliInput(
                          controller: passCtrl,
                          hint: "Contraseña",
                          icon: Icons.lock_outline_rounded,
                          isObscure: _obscurePass,
                          color: Colors.white,
                          borderColor: AppColors.primary.withValues(alpha: 0.3),
                          isDark: isDark,
                          enabled: !isLoading,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                            onPressed: isLoading ? null : () => setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 🚀 Login Button
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _VitaliButton(
                          text: "Iniciar Sesión",
                          onPressed: isLoading ? () {} : _login,
                          color: isLoading ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 📝 Register link
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "¿No tienes una cuenta? ",
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                            GestureDetector(
                              onTap: isLoading ? null : () => context.push('/register'),
                              child: const Text(
                                "Regístrate",
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),

          // ── Notification Banner (Right to left entry, top right location) ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            top: MediaQuery.of(context).size.height * 0.08,
            right: _showBanner ? MediaQuery.of(context).size.width * 0.05 : -MediaQuery.of(context).size.width,
            child: AnimatedBuilder(
              animation: _bannerPulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _showBanner ? _bannerPulseController.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.72,
                height: (MediaQuery.of(context).size.width * 0.72) * (269 / 600),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/noti_interna.webp'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 36, left: 16, right: 16, bottom: 16),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        'Vamos, ingresa. Titi te espera, ayúdale a ordenar su cuarto',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C381E), // Brown color
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitaliInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final bool isObscure;
  final Widget? suffix;
  final bool isDark;
  final bool enabled;

  const _VitaliInput({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.color,
    required this.borderColor,
    this.isObscure = false,
    this.suffix,
    required this.isDark,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : color,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white10 : borderColor, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        enabled: enabled,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
          prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black45, size: 22),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }
}

class _VitaliButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const _VitaliButton({required this.text, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // 👈 mismo color que splash
          ),
        ),
      ),
    );
  }
}


class _DomainTextEditingController extends TextEditingController {
  final String domain;
  _DomainTextEditingController({required this.domain}) {
    if (text.isEmpty) {
      text = domain;
      selection = const TextSelection.collapsed(offset: 0);
    }
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final String fullText = text;
    if (!fullText.endsWith(domain)) {
      return TextSpan(text: fullText, style: style);
    }

    final String userText = fullText.substring(0, fullText.length - domain.length);
    return TextSpan(
      style: style,
      children: [
        TextSpan(text: userText),
        TextSpan(
          text: domain,
          style: style?.copyWith(color: style.color ?? Colors.black),
        ),
      ],
    );
  }

  @override
  set value(TextEditingValue newValue) {
    String newText = newValue.text;
    TextSelection newSelection = newValue.selection;

    if (!newText.endsWith(domain)) {
      if (newText.length < domain.length || !newText.contains(domain)) {
         newText = domain;
         newSelection = const TextSelection.collapsed(offset: 0);
      } else {
        final parts = newText.split(domain);
        newText = "${parts[0]}$domain";
        newSelection = TextSelection.collapsed(offset: parts[0].length);
      }
    }

    if (newSelection.start > newText.length - domain.length) {
      newSelection = TextSelection.collapsed(offset: newText.length - domain.length);
    }

    super.value = newValue.copyWith(text: newText, selection: newSelection);
  }
}


