import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/theme_switcher.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    if (codeCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código debe tener al menos 6 caracteres')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: emailCtrl.text.trim(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 🎨 Header con gradiente
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: _PatternPainter()),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeInLeft(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        const ThemeSwitcher(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  FadeInDown(
                    child: Text(
                      "Únete a Vitali",
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: const Text(
                      "Comienza tu viaje hacia el bienestar",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 💎 Form Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeInUp(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _inputField(
                              label: "Nombre completo",
                              controller: nameCtrl,
                              icon: Icons.person_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 20),
                            _inputField(
                              label: "Correo institucional",
                              controller: emailCtrl,
                              icon: Icons.alternate_email_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 20),
                            _buildPasswordField(
                              label: "Código (Contraseña)",
                              controller: codeCtrl,
                              icon: Icons.lock_outline_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 40),
                            isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : _buildRegisterButton(),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("¿Ya tienes cuenta? ",
                                    style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: const Text(
                                    "Entra aquí",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _register,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          "CREAR CUENTA",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _inputField({required String label, required TextEditingController controller, required IconData icon, bool obscure = false, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            hintText: label,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({required String label, required TextEditingController controller, required IconData icon, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: _obscureCode,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isDark ? Colors.white38 : Colors.black38),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCode ? Icons.visibility_off : Icons.visibility,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              onPressed: () => setState(() => _obscureCode = !_obscureCode),
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            hintText: label,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
          ),
        ),
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const spacing = 40.0;
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i - size.height, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

