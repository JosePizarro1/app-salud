import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/widgets/theme_switcher.dart';
import '../../../app/theme/app_colors.dart';
import '../widgets/module_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado de escalado para cada módulo (0: Mesa/Modulo1, 1: Mod2, 2: Mod3, etc.)
  final List<bool> _moduleScales = List.generate(6, (_) => false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache heavy images on first build for instant rendering
    precacheImage(const AssetImage('assets/images/fondotiti.jpg'), context);
    precacheImage(const AssetImage('assets/images/Video.gif'), context);
    precacheImage(const AssetImage('assets/images/modulo1.png'), context);
    precacheImage(const AssetImage('assets/images/modulo2.png'), context);
    precacheImage(const AssetImage('assets/images/modulo3.png'), context);
    precacheImage(const AssetImage('assets/images/modulo4.png'), context);
    precacheImage(const AssetImage('assets/images/modulo5.png'), context);
    precacheImage(const AssetImage('assets/images/modulo6.png'), context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _triggerScale(int index) async {
    debugPrint("Modulo ${index + 1} presionado");
    setState(() => _moduleScales[index] = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _moduleScales[index] = false);
    }
    // Esperamos a que la escala regrese a su tamaño original antes de continuar
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image (100%) ──
          Image.asset(
            'assets/images/fondotiti.jpg',
            fit: BoxFit.cover,
          ),

          // ── GIF Character (Responsive %) ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.28, // 1% más a la izquierda
            top: MediaQuery.of(context).size.height * 0.42, // 4% más arriba
            child: FadeIn(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.45875, // 37.5% * 1.25
                height: MediaQuery.of(context).size.height * 0.45875, // 37.5% * 1.25
                child: Image.asset(
                  'assets/images/Video.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ── Header (Configuración y Emergencia) ──
          const ModuleHeader(),

          // ── Modulo 1 (Mesa) ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0,
            bottom: MediaQuery.of(context).size.height * 0.24,
            child: FadeIn(
              delay: const Duration(milliseconds: 500),
              child: AnimatedScale(
                scale: _moduleScales[0] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () async {
                    await _triggerScale(0);
                    if (mounted) context.push('/module1');
                  },
                 borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.375,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo1.png'),
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
            left: MediaQuery.of(context).size.width * 0.6,
            bottom: MediaQuery.of(context).size.height * 0.35,
            child: FadeIn(
              delay: const Duration(milliseconds: 600),
              child: AnimatedScale(
                scale: _moduleScales[1] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () async {
                    await _triggerScale(1);
                    if (mounted) context.push('/module2');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4134375,
                    height: MediaQuery.of(context).size.height * 0.275625,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo2.png'),
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
            left: MediaQuery.of(context).size.width * 0.02,
            bottom: MediaQuery.of(context).size.height * 0.39,
            child: FadeIn(
              delay: const Duration(milliseconds: 700),
              child: AnimatedScale(
                scale: _moduleScales[2] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () async {
                    await _triggerScale(2);
                    if (mounted) context.push('/module3');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.45375,
                    height: MediaQuery.of(context).size.height * 0.3025,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo3.png'),
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
            bottom: MediaQuery.of(context).size.height * 0.048,
            child: FadeIn(
              delay: const Duration(milliseconds: 800),
              child: AnimatedScale(
                scale: _moduleScales[3] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut, 
                child: InkWell(
                  onTap: () async {
                    await _triggerScale(3);
                    if (mounted) context.push('/module4');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4125,
                    height: MediaQuery.of(context).size.height * 0.275,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo4.png'),
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
            bottom: MediaQuery.of(context).size.height * 0.23,
            child: FadeIn(
              delay: const Duration(milliseconds: 900),
              child: AnimatedScale(
                scale: _moduleScales[4] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () async {
                    await _triggerScale(4);
                    if (mounted) context.push('/module5');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.375,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo5.png'),
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
            left: MediaQuery.of(context).size.width * 0.55,
            bottom: MediaQuery.of(context).size.height * 0.039,
            child: FadeIn(
              delay: const Duration(milliseconds: 1000),
              child: AnimatedScale(
                scale: _moduleScales[5] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () => _triggerScale(5),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4125,
                    height: MediaQuery.of(context).size.height * 0.275,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/modulo6.png'),
                        fit: BoxFit.contain,
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
