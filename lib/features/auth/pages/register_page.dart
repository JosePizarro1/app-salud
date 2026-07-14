import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
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
  final passCtrl = TextEditingController();
  final _audioPlayer = AudioPlayer();
  bool isLoading = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _register() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
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
        password: passCtrl.text.trim(),
        data: {
          'full_name': nameCtrl.text.trim(),
        },
      );

      if (authResponse.user != null) {
        if (mounted) {
          try {
            await _audioPlayer.play(AssetSource('audio/success_cheerful.mp3'));
          } catch (soundError) {
            debugPrint('Error playing success sound: $soundError');
          }
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
        String friendlyMessage = e.message;
        
        if (e.message.contains('already registered') || e.message.contains('already exists') || e.message.toLowerCase().contains('exists')) {
          friendlyMessage = "Este correo ya está registrado. Por favor, intenta iniciar sesión o usa otro correo.";
        } else if (e.message.contains('Password should be at least 6 characters')) {
          friendlyMessage = "La contraseña debe tener al menos 6 caracteres.";
        } else if (e.message.contains('invalid format') || e.message.contains('invalid email')) {
          friendlyMessage = "El formato del correo electrónico no es válido.";
        } else if (e.message.contains('Signup is disabled')) {
          friendlyMessage = "El registro de nuevos usuarios está deshabilitado temporalmente.";
        }

        VitaliDialog.show(
          context,
          title: "Error de Registro",
          message: friendlyMessage,
        );
      }
    } catch (e) {
      if (mounted) {
        VitaliDialog.show(
          context,
          title: "Error Inesperado",
          message: "Ocurrió un error inesperado al intentar registrarte: $e",
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.surfaceDark 
            : Colors.white,
        title: Text(
          "Términos, Condiciones y\nUso de Datos",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _termItem(
                "Naturaleza del Proyecto",
                "Vitali es una aplicación desarrollada por el Semillero de Investigación de la Universidad Nacional Jorge Basadre Grohmann (UNJBG), con fines exclusivamente educativos y de investigación académica. No tiene fines comerciales ni monetarios.",
              ),
              _termItem(
                "Datos Recopilados",
                "La aplicación recopila: nombre, correo institucional, respuestas a cuestionarios de bienestar, registros del calendario emocional y progreso en los módulos educativos.",
              ),
              _termItem(
                "Tratamiento de Datos Sensibles",
                "Los datos relacionados con tu bienestar emocional y respuestas a cuestionarios se consideran datos sensibles. Estos son almacenados de forma anónima mediante un identificador interno, sin vincular directamente tu identidad personal en los análisis de investigación.",
              ),
              _termItem(
                "Finalidad",
                "La información recopilada será utilizada únicamente para análisis académico dentro del proyecto de investigación. No se comparte ni vende a terceros bajo ninguna circunstancia.",
              ),
              _termItem(
                "Derecho de Eliminación",
                "Puedes solicitar la eliminación total de tu cuenta y todos los datos asociados en cualquier momento, contactando al equipo de investigación.",
              ),
              _termItem(
                "Carácter Informativo",
                "Vitali es una herramienta de apoyo al bienestar universitario. No sustituye diagnósticos, tratamientos ni el consejo de profesionales de la salud.",
              ),
              _termItem(
                "Consentimiento",
                "Al registrarte y utilizar la aplicación, manifiestas tu consentimiento libre e informado para la recopilación y uso de tus datos conforme a estos términos.",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _termItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
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
                  'assets/images/register_fondo.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  gaplessPlayback: true,
                ),
              );
            },
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

          Positioned(
            top: MediaQuery.of(context).size.height * 0.60,
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
                          enabled: !isLoading,
                        ),
                      ),

                      const SizedBox(height: 6),

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
                          enabled: !isLoading,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 🔒 Pass Input (Lavender)
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _VitaliInput(
                          controller: passCtrl,
                          hint: "Contraseña (Mín. 6 caracteres)",
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

                      const SizedBox(height: 12),

                      // 🚀 Register Button
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _VitaliButton(
                          text: "Crear Cuenta",
                          onPressed: isLoading ? () {} : _register,
                          color: isLoading ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 8),

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
                              onTap: isLoading ? null : () => context.pop(),
                              child: const Text(
                                "Inicia Sesión",
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 📜 Terms & Conditions
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: GestureDetector(
                          onTap: isLoading ? null : _showTermsAndConditions,
                          child: Text(
                            "Al registrarte, aceptas nuestros\nTérminos, Condiciones y Uso de Datos",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
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
