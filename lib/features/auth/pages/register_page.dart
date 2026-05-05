import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/theme/app_colors.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image (100%) ──
          Image.asset(
            'assets/images/register_fondo.png',
            fit: BoxFit.cover,
          ),

          // ── Back button ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: FadeInLeft(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
            ),
          ),

          // ── Form section (bottom) ──
          Positioned(
            bottom: 37,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // 👤 Name Input (Peach)
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _VitaliInput(
                      controller: nameCtrl,
                      hint: "Nombre completo",
                      icon: Icons.person_outline_rounded,
                      color: Colors.white,
                      borderColor: AppColors.primary.withValues(alpha: 0.3),
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 📧 Email Input (Mint)
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _VitaliInput(
                      controller: emailCtrl,
                      hint: "Usuario",
                      icon: Icons.alternate_email_rounded,
                      color: Colors.white,
                      borderColor: AppColors.accent,
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔒 Pass Input (Lavender)
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _VitaliInput(
                      controller: codeCtrl,
                      hint: "Contraseña (Mín. 6 caracteres)",
                      icon: Icons.lock_outline_rounded,
                      isObscure: _obscureCode,
                      color: Colors.white,
                      borderColor: AppColors.primary.withValues(alpha: 0.3),
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

                  const SizedBox(height: 20),

                  // 🚀 Register Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: isLoading 
                      ? const CircularProgressIndicator()
                      : _VitaliButton(
                          text: "Crear Cuenta",
                          onPressed: _register,
                          color: AppColors.primary,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // 📝 Login link
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "¿Ya tienes una cuenta? ",
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Text(
                            "Inicia Sesión",
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
        height: 54,
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
            color: Colors.white,
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
