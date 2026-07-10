import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';

class WelcomeSplashPage extends StatefulWidget {
  const WelcomeSplashPage({super.key});

  @override
  State<WelcomeSplashPage> createState() => _WelcomeSplashPageState();
}

class _WelcomeSplashPageState extends State<WelcomeSplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _checkSession();
  }

  void _checkSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        if (mounted) {
          context.go('/home');
        }
      } else {
        if (mounted) {
          setState(() {
            _checkingSession = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──
          Image.asset(
            'assets/images/welcome_slash.png',
            fit: BoxFit.cover,
          ),

          if (!_checkingSession) ...[
            // ── Central Text ──
            Positioned(
              top: MediaQuery.of(context).size.height * 0.38,
              left: 40,
              right: 40,
              child: FadeInDown(
                duration: const Duration(milliseconds: 1000),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: const Color(0xFF2E4B7A), // Azul elegante
                    ),
                    children: [
                      const TextSpan(text: 'Tu bienestar,\nguiado por tu\n'),
                      TextSpan(
                        text: 'compañero.',
                        style: const TextStyle(
                          color: Color(0xFF699F91), // Verde claro solicitado
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── "Comenzar" button ──
            Positioned(
              bottom: 50,
              left: 32,
              right: 32,
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Comenzar mi viaje',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
