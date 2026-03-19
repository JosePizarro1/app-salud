import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/widgets/theme_switcher.dart';
import '../../../app/widgets/staggered_entry.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;
  AnimationController? _entryController; // Make it nullable to avoid late issues during hot reload

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entryController?.forward();
  }

  @override
  void dispose() {
    _entryController?.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utilize native Theme colors instead of explicit hex references 
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // We get colors natively so when main.dart rebuilds through ThemeController, this catches it
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        child: isLoading 
          ? _buildLoadingTransition(primaryTextColor)
          : _buildLoginForm(isDark, secondaryTextColor, primaryTextColor),
      ),
    );
  }

  Widget _buildLoadingTransition(Color primaryTextColor) {
    return SizedBox(
      key: const ValueKey('loading'),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(seconds: 1),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: const SizedBox(
              height: 300,
              width: 300,
              child: DotLottieView(
                source: "https://lottie.host/062056d9-b5d2-4b27-99df-e36652a9b97d/IMWRJOJKFZ.lottie",
                sourceType: 'url',
                autoplay: true,
                loop: true,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _AnimatedLoadingText(color: primaryTextColor),
        ],
      ),
    );
  }

  Widget _buildLoginForm(bool isDark, Color secondaryTextColor, Color primaryTextColor) {
    return SafeArea(
      key: const ValueKey('form'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Switcher fluído con la pantalla
            const Align(
              alignment: Alignment.centerRight,
              child: ThemeSwitcher(),
            ),
            
            const SizedBox(height: 50),

            // 🎬 Animación Lottie
            StaggeredEntry(
                  controller: _entryController!,
                  index: 0,
                  child: Center(
                    child: SizedBox(
                      height: 180,
                      width: 180,
                      child: DotLottieView(
                        source: "https://lottie.host/5319cb02-834d-421c-a067-65deaffde35b/LsVuvLnSuc.lottie",
                        sourceType: 'url',
                        autoplay: true,
                        loop: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

            // 💎 Nombre de la app imponente
            StaggeredEntry(
                  controller: _entryController!,
                  index: 1,
                  child: Text(
                    "VITALI APP",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: primaryTextColor,
                      letterSpacing: 3.0,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                StaggeredEntry(
                  controller: _entryController!,
                  index: 2,
                  child: Text(
                    "Inicia sesión para continuar",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: secondaryTextColor, height: 1.5),
                  ),
                ),

                const SizedBox(height: 40),

                // 📩 Campo email
                StaggeredEntry(
                  controller: _entryController!,
                  index: 3,
                  child: _inputField(
                    label: "Correo institucional",
                    controller: emailCtrl,
                    icon: Icons.email_outlined,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 20),

                // 🔐 Campo contraseña
                StaggeredEntry(
                  controller: _entryController!,
                  index: 4,
                  child: _inputField(
                    label: "Contraseña",
                    controller: passCtrl,
                    icon: Icons.lock_outline,
                    obscure: true,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 50),

                // 🔵 Botón
                StaggeredEntry(
                  controller: _entryController!,
                  index: 5,
                  child: _AnimatedLoginButton(onPressed: _login),
                ),
              ],
            ),
          ),
    );
  }

  // 🧩 Función login con animación mejorada
  void _login() async {
    // Escondemos el teclado si está abierto
    FocusScope.of(context).unfocus();
    
    setState(() => isLoading = true);
    
    // Simular validación
    await Future.delayed(const Duration(milliseconds: 3000));
    
    if (mounted) {
      context.go('/home'); // Redirigir a Home directamente
    }
  }

  // 📦 Widget campo de texto reutilizable
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            )),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isDark ? Colors.white38 : Colors.black38),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            hintText: label,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
          ),
        ),
      ],
    );
  }
}

// 🚀 WIDGET PARA TEXTO DE CARGA ANIMADO
class _AnimatedLoadingText extends StatefulWidget {
  final Color color;
  const _AnimatedLoadingText({required this.color});

  @override
  State<_AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<_AnimatedLoadingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        "Preparando tu experiencia Vitali...",
        style: TextStyle(color: widget.color, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    );
  }
}

// 🚀 BOTÓN DE LOGIN ANIMADO (REUTILIZANDO ESTILO DE HOME)
class _AnimatedLoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedLoginButton({required this.onPressed});

  @override
  State<_AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<_AnimatedLoginButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), lowerBound: 0.95, upperBound: 1.0, value: 1.0);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
            boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          alignment: Alignment.center,
          child: const Text("INICIAR SESIÓN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
        ),
      ),
    );
  }
}

