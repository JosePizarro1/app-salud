import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/widgets/theme_switcher.dart';
import '../../../app/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado de escalado para cada módulo (0: Mesa/Modulo1, 1: Mod2, 2: Mod3, etc.)
  final List<bool> _moduleScales = List.generate(7, (_) => false);

  void _triggerScale(int index) async {
    print("Modulo ${index + 1} presionado");
    setState(() => _moduleScales[index] = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _moduleScales[index] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image (100%) ──
          Image.asset(
            'assets/images/fondo_home.jpg',
            fit: BoxFit.cover,
          ),

          // ── GIF Character (Responsive %) ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.21, // 1% más a la izquierda
            top: MediaQuery.of(context).size.height * 0.32, // 4% más arriba
            child: FadeIn(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.56875, // 37.5% * 1.25
                height: MediaQuery.of(context).size.height * 0.56875, // 37.5% * 1.25
                child: Image.asset(
                  'assets/images/Video.GIF',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ── Modulo 1 (Mesa) ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            bottom: MediaQuery.of(context).size.height * 0.34,
            child: FadeIn(
              delay: const Duration(milliseconds: 500),
              child: AnimatedScale(
                scale: _moduleScales[0] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () => _triggerScale(0),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.30,
                    height: MediaQuery.of(context).size.height * 0.20,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/mesa.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Modulo 2 ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.65,
            bottom: MediaQuery.of(context).size.height * 0.35,
            child: FadeIn(
              delay: const Duration(milliseconds: 600),
              child: AnimatedScale(
                scale: _moduleScales[1] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () => _triggerScale(1),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.375,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo2.PNG'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Modulo 3 ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            bottom: MediaQuery.of(context).size.height * 0.44,
            child: FadeIn(
              delay: const Duration(milliseconds: 700),
              child: AnimatedScale(
                scale: _moduleScales[2] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () => _triggerScale(2),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.375,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo3.PNG'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Modulo 4 ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.04,
            bottom: MediaQuery.of(context).size.height * 0.10,
            child: FadeIn(
              delay: const Duration(milliseconds: 800),
              child: AnimatedScale(
                scale: _moduleScales[3] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () => _triggerScale(3),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.375,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo4.PNG'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Modulo 5 ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.65,
            bottom: MediaQuery.of(context).size.height * 0.2,
            child: FadeIn(
              delay: const Duration(milliseconds: 900),
              child: AnimatedScale(
                scale: _moduleScales[4] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () => _triggerScale(4),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.375,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo5.PNG'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Modulo 6 ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.45,
            bottom: MediaQuery.of(context).size.height * 0.07,
            child: FadeIn(
              delay: const Duration(milliseconds: 1000),
              child: AnimatedScale(
                scale: _moduleScales[5] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () => _triggerScale(5),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.375,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo6.PNG'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Top Header ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FadeInRight(
                        child: IconButton(
                          icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 28),
                          onPressed: () => context.push('/settings'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
