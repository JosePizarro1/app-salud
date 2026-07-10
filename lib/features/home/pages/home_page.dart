import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/module_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/home_tutorial_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado de escalado para cada módulo (0: Mesa/Modulo1, 1: Mod2, 2: Mod3, etc.)
  final List<bool> _moduleScales = List.generate(6, (_) => false);
  bool _showTutorial = false;

  List<Offset>? _modulePositions;
  int? _activeDragIndex;
  Offset _dragStartOffset = Offset.zero;
  Offset _dragBaseOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('home_tutorial_shown') ?? false;
    if (!hasShown && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('home_tutorial_shown', true);
    if (mounted) {
      setState(() => _showTutorial = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_modulePositions == null) {
      final size = MediaQuery.of(context).size;
      _modulePositions = [
        Offset(0.0 * size.width, 0.24 * size.height), // Mod 1
        Offset(0.6 * size.width, 0.35 * size.height), // Mod 2
        Offset(0.02 * size.width, 0.39 * size.height), // Mod 3
        Offset(0.04 * size.width, 0.048 * size.height), // Mod 4
        Offset(0.65 * size.width, 0.23 * size.height), // Mod 5
        Offset(0.55 * size.width, 0.039 * size.height), // Mod 6
      ];
    }
    // Precache heavy images on first build for instant rendering
    precacheImage(const AssetImage('assets/images/fondotiti.jpg'), context);
    precacheImage(const AssetImage('assets/images/Video.gif'), context);
    precacheImage(const AssetImage('assets/images/modulo1.png'), context);
    precacheImage(const AssetImage('assets/images/modulo2.png'), context);
    precacheImage(const AssetImage('assets/images/modulo3.png'), context);
    precacheImage(const AssetImage('assets/images/modulo4.png'), context);
    precacheImage(const AssetImage('assets/images/modulo5.png'), context);
    precacheImage(const AssetImage('assets/images/modulo6.png'), context);
    precacheImage(const AssetImage('assets/images/Home_botones/mod_lecciones.png'), context);
    precacheImage(const AssetImage('assets/images/Home_botones/mod_suenoydescanso.png'), context);
    precacheImage(const AssetImage('assets/images/Home_botones/mod_meditacion.png'), context);
    precacheImage(const AssetImage('assets/images/Home_botones/mod_juegos.png'), context);
    precacheImage(const AssetImage('assets/images/Home_botones/mod_horario.png'), context);
    precacheImage(const AssetImage('assets/images/Home_botones/mod_bienestarfisico.png'), context);
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

  Widget _buildGroupedModule(int index, double screenWidth, double screenHeight) {
    if (_modulePositions == null) return const SizedBox.shrink();
    final pos = _modulePositions![index];

    // Define relative positions
    double btnLeft = 0;
    double btnBottom = 0;
    double furnWidth = 0;
    double furnHeight = 0;
    double btnWidth = screenWidth * 0.34;
    double btnHeight = screenHeight * 0.08;

    String furnAsset = '';
    String btnAsset = '';
    String route = '';
    int scaleIndex = 0;

    switch (index) {
      case 0: // Modulo 1 (Mesa)
        furnAsset = 'assets/images/modulo1.png';
        btnAsset = 'assets/images/Home_botones/mod_juegos.png';
        route = '/module1';
        scaleIndex = 0;
        furnWidth = screenWidth * 0.375;
        furnHeight = screenHeight * 0.25;
        btnLeft = 0.02 * screenWidth;
        btnBottom = 0.11 * screenHeight;
        break;
      case 1: // Modulo 2 (Cama)
        furnAsset = 'assets/images/modulo2.png';
        btnAsset = 'assets/images/Home_botones/mod_bienestarfisico.png';
        route = '/module2';
        scaleIndex = 1;
        furnWidth = screenWidth * 0.4134375;
        furnHeight = screenHeight * 0.275625;
        btnLeft = 0.08 * screenWidth;
        btnBottom = 0.14 * screenHeight;
        break;
      case 2: // Modulo 3 (Meditación)
        furnAsset = 'assets/images/modulo3.png';
        btnAsset = 'assets/images/Home_botones/mod_meditacion.png';
        route = '/module3';
        scaleIndex = 2;
        furnWidth = screenWidth * 0.45375;
        furnHeight = screenHeight * 0.3025;
        btnLeft = 0.13 * screenWidth;
        btnBottom = 0.15 * screenHeight;
        break;
      case 3: // Modulo 4 (Juegos)
        furnAsset = 'assets/images/modulo4.png';
        btnAsset = 'assets/images/Home_botones/mod_suenoydescanso.png';
        route = '/module4';
        scaleIndex = 3;
        furnWidth = screenWidth * 0.4125;
        furnHeight = screenHeight * 0.275;
        btnLeft = 0.02 * screenWidth;
        btnBottom = 0.132 * screenHeight;
        break;
      case 4: // Modulo 5 (Horario)
        furnAsset = 'assets/images/modulo5.png';
        btnAsset = 'assets/images/Home_botones/mod_horario.png';
        route = '/module5';
        scaleIndex = 4;
        furnWidth = screenWidth * 0.375;
        furnHeight = screenHeight * 0.25;
        btnLeft = -0.02 * screenWidth;
        btnBottom = 0.13 * screenHeight;
        break;
      case 5: // Modulo 6 (Bienestar Físico)
        furnAsset = 'assets/images/modulo6.png';
        btnAsset = 'assets/images/Home_botones/mod_lecciones.png';
        route = '/module6';
        scaleIndex = 5;
        furnWidth = screenWidth * 0.4125;
        furnHeight = screenHeight * 0.275;
        btnLeft = 0.06 * screenWidth;
        btnBottom = 0.141 * screenHeight;
        break;
    }

    final isDraggingThis = _activeDragIndex == index;

    Widget wrapWithDrag(Widget child) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (details) {
          setState(() {
            _activeDragIndex = index;
            _dragStartOffset = details.globalPosition;
            _dragBaseOffset = pos;
          });
          HapticFeedback.heavyImpact();
        },
        onLongPressMoveUpdate: (details) {
          if (_activeDragIndex == index) {
            final diff = details.globalPosition - _dragStartOffset;
            setState(() {
              _modulePositions![index] = Offset(
                _dragBaseOffset.dx + diff.dx,
                _dragBaseOffset.dy - diff.dy,
              );
            });
          }
        },
        onLongPressEnd: (details) {
          setState(() {
            _activeDragIndex = null;
          });
          HapticFeedback.mediumImpact();
        },
        child: child,
      );
    }

    return Positioned(
      left: pos.dx,
      bottom: pos.dy,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDraggingThis ? 0.7 : 1.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: isDraggingThis ? 1.08 : 1.0,
          child: Container(
            width: furnWidth + (btnLeft > 0 ? btnLeft : -btnLeft) + 50,
            height: furnHeight + btnBottom + 50,
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: btnLeft < 0 ? -btnLeft : 0,
                  bottom: 0,
                  child: wrapWithDrag(
                    FadeIn(
                      delay: Duration(milliseconds: 500 + index * 100),
                      child: Container(
                        width: furnWidth,
                        height: furnHeight,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(furnAsset),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: btnLeft < 0 ? 0 : btnLeft,
                  bottom: btnBottom,
                  child: wrapWithDrag(
                    FadeIn(
                      delay: Duration(milliseconds: 550 + index * 100),
                      child: AnimatedScale(
                        scale: _moduleScales[scaleIndex] ? 1.4 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: InkWell(
                          onTap: isDraggingThis ? null : () async {
                            await _triggerScale(scaleIndex);
                            if (context.mounted) context.push(route);
                          },
                          child: SizedBox(
                            width: btnWidth,
                            height: btnHeight,
                            child: Image.asset(
                              btnAsset,
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
          ),
        ),
      ),
    );
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

          // ── ELEMENTOS DE MÓDULOS AGRUPADOS Y MÓVILES (MUEBLES + BOTONES DE ARRIBITA) ──
          if (_modulePositions != null)
            ...List.generate(
              6,
              (index) => _buildGroupedModule(
                index,
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
            ),



          // ── Tutorial Overlay (First run only) ──
          if (_showTutorial)
            HomeTutorialOverlay(
              onFinish: _completeTutorial,
            ),
        ],
      ),
    );
  }
}
