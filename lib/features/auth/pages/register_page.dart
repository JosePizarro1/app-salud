import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/theme_switcher.dart';
import '../../../app/widgets/vitali_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final nameCtrl = TextEditingController();
  final emailCtrl = _DomainTextEditingController(domain: "@unjbg.edu.pe");
  final codeCtrl = TextEditingController();
  bool isLoading = false;
  bool _obscureCode = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    codeCtrl.dispose();
    super.dispose();
  }

  void _register() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || codeCtrl.text.isEmpty) {
      VitaliDialog.show(
        context,
        title: "Campos incompletos",
        message: "Por favor, completa todos los campos para crear tu cuenta.",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final fullEmail = emailCtrl.text.trim().contains('@') 
          ? emailCtrl.text.trim() 
          : "${emailCtrl.text.trim()}@unjbg.edu.pe";

      final authResponse = await Supabase.instance.client.auth.signUp(
        email: fullEmail,
        password: codeCtrl.text.trim(),
        data: {
          'full_name': nameCtrl.text.trim(),
          'student_code': codeCtrl.text.trim(),
        },
      );

      if (authResponse.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro exitoso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        VitaliDialog.show(
          context,
          title: "Aviso de Registro",
          message: "No pudimos completar el registro. Por favor, verifica tus datos e intenta de nuevo.",
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      body: Stack(
        children: [
          // 🌊 Wavy Header (Consistent with Login)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _WavyHeader(),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 15), // Extra space for back button and switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FadeInLeft(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white60,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: isDark ? Colors.white : const Color(0xFF2D3142),
                            ),
                          ),
                        ),
                      ),
                      FadeInRight(child: const ThemeSwitcher()),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 🧘 Mascot (Register specific)
                  FadeInDown(
                    child: Center(
                      child: Container(
                        height: 160,
                        width: 160,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: const _SafeLottie(
                          source: "https://lottie.host/ebd46162-4aa8-43d9-9524-733a1e263d95/f9C4eU7x6p.json", // Meditating person
                          fallbackIcon: Icons.how_to_reg_rounded,
                          fallbackColor: AppColors.mint,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🏷️ Title
                  FadeInUp(
                    child: Column(
                      children: [
                        Text(
                          "Únete a Vitali",
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF2D3142),
                          ),
                        ),
                        Text(
                          "Crea tu cuenta de bienestar",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 👤 Name Input (Peach)
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _VitaliInput(
                      controller: nameCtrl,
                      hint: "Nombre completo",
                      icon: Icons.person_outline_rounded,
                      color: AppColors.peachLight,
                      borderColor: AppColors.peach,
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📧 Email Input (Mint)
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _VitaliInput(
                      controller: emailCtrl,
                      hint: "Usuario",
                      icon: Icons.alternate_email_rounded,
                      color: AppColors.mintLight,
                      borderColor: AppColors.mint,
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔒 Pass Input (Lavender)
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _VitaliInput(
                      controller: codeCtrl,
                      hint: "Contraseña (Mín. 6 caracteres)",
                      icon: Icons.lock_outline_rounded,
                      isObscure: _obscureCode,
                      color: AppColors.lavenderLight,
                      borderColor: AppColors.lavender,
                      isDark: isDark,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureCode ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        onPressed: () => setState(() => _obscureCode = !_obscureCode),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🚀 Register Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: isLoading 
                      ? const CircularProgressIndicator()
                      : _VitaliButton(
                          text: "Crear Cuenta",
                          onPressed: _register,
                          color: AppColors.mint,
                        ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿Ya tienes una cuenta? ", style: TextStyle(color: Colors.black45)),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          "Inicia Sesión",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌊 Reusing the Wavy Header logic for consistency
class _WavyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          ClipPath(
            clipper: _TopWaveClipper(),
            child: Container(color: AppColors.lavender.withValues(alpha: 0.3)),
          ),
          ClipPath(
            clipper: _BottomWaveClipper(),
            child: Container(color: AppColors.mint.withValues(alpha: 0.2)),
          ),
        ],
      ),
    );
  }
}

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);
    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.6);
    var secondEndPoint = Offset(size.width, size.height * 0.8);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.5);
    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.3);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.7);
    var secondEndPoint = Offset(size.width, size.height * 0.5);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// 📦 Reusing consistent Input fields
class _VitaliInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final bool isObscure;
  final Widget? suffix;
  final bool isDark;

  const _VitaliInput({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.color,
    required this.borderColor,
    this.isObscure = false,
    this.suffix,
    required this.isDark,
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
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
      ),
    );
  }
}

class _SafeLottie extends StatelessWidget {
  final String source;
  final IconData fallbackIcon;
  final Color fallbackColor;
  const _SafeLottie({required this.source, required this.fallbackIcon, required this.fallbackColor});

  @override
  Widget build(BuildContext context) {
    return _LottieErrorBoundary(
      fallback: Icon(fallbackIcon, size: 80, color: fallbackColor),
      child: DotLottieView(
        source: source,
        sourceType: 'url',
        autoplay: true,
        loop: true,
      ),
    );
  }
}

class _LottieErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget fallback;
  const _LottieErrorBoundary({required this.child, required this.fallback});
  @override
  State<_LottieErrorBoundary> createState() => _LottieErrorBoundaryState();
}

class _LottieErrorBoundaryState extends State<_LottieErrorBoundary> {
  bool _hasError = false;
  @override
  Widget build(BuildContext context) {
    if (_hasError) return widget.fallback;
    final oldBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasError) setState(() => _hasError = true);
      });
      return widget.fallback;
    };
    final result = Builder(builder: (context) => widget.child);
    ErrorWidget.builder = oldBuilder;
    return result;
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
          style: style?.copyWith(color: style.color?.withValues(alpha: 0.3) ?? Colors.grey),
        ),
      ],
    );
  }

  @override
  set value(TextEditingValue newValue) {
    String newText = newValue.text;
    TextSelection newSelection = newValue.selection;

    if (!newText.endsWith(domain)) {
      // Intentó borrar parte del dominio o escribir después
      if (newText.length < domain.length || !newText.contains(domain)) {
         newText = domain;
         newSelection = const TextSelection.collapsed(offset: 0);
      } else {
        // Probablemente borró algo entre medio, forzamos re-formato
        final parts = newText.split(domain);
        newText = "${parts[0]}$domain";
        newSelection = TextSelection.collapsed(offset: parts[0].length);
      }
    }

    // Evitar que el cursor entre al dominio
    if (newSelection.start > newText.length - domain.length) {
      newSelection = TextSelection.collapsed(offset: newText.length - domain.length);
    }

    super.value = newValue.copyWith(text: newText, selection: newSelection);
  }
}
