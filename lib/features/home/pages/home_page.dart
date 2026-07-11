import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/module_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/home_tutorial_overlay.dart';
import '../../../app/services/background_music_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado de escalado para cada módulo (0: Mesa/Modulo1, 1: Mod2, 2: Mod3, etc.)
  final List<bool> _moduleScales = List.generate(6, (_) => false);
  bool _showTutorial = false;
  bool _isPlayingTiti = false;
  Timer? _titiTimer;
  bool _isDebugMode = false;
  final AudioPlayer _dragAudioPlayer = AudioPlayer()
    ..setAudioContext(AudioContext(
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
      ),
    ));

  bool _isImagesPrecached = false;
  List<Offset>? _modulePositions;
  int? _activeDragIndex;
  Offset _dragStartOffset = Offset.zero;
  Offset _dragBaseOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
    BackgroundMusicManager().init();
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
    
    // Only run precache once to save CPU cycles on page rebuilds
    if (!_isImagesPrecached) {
      _isImagesPrecached = true;
      precacheImage(const AssetImage('assets/images/fondotiti.webp'), context);
      precacheImage(const AssetImage('assets/images/Video.webp'), context);
      precacheImage(const AssetImage('assets/images/Video_static.webp'), context);
      precacheImage(const AssetImage('assets/images/modulo1.webp'), context);
      precacheImage(const AssetImage('assets/images/modulo2.webp'), context);
      precacheImage(const AssetImage('assets/images/modulo3.webp'), context);
      precacheImage(const AssetImage('assets/images/modulo4.webp'), context);
      precacheImage(const AssetImage('assets/images/modulo5.webp'), context);
      precacheImage(const AssetImage('assets/images/modulo6.webp'), context);
      precacheImage(const AssetImage('assets/images/Home_botones/mod_lecciones.webp'), context);
      precacheImage(const AssetImage('assets/images/Home_botones/mod_suenoydescanso.webp'), context);
      precacheImage(const AssetImage('assets/images/Home_botones/mod_meditacion.webp'), context);
      precacheImage(const AssetImage('assets/images/Home_botones/mod_juegos.webp'), context);
      precacheImage(const AssetImage('assets/images/Home_botones/mod_horario.webp'), context);
      precacheImage(const AssetImage('assets/images/Home_botones/mod_bienestarfisico.webp'), context);
      precacheImage(const AssetImage('assets/images/fondo_modulo1_juegos.webp'), context);
      precacheImage(const AssetImage('assets/images/fondo_modulo2.webp'), context);
      precacheImage(const AssetImage('assets/images/fondo_modulo3.webp'), context);
      precacheImage(const AssetImage('assets/images/fondo_modulo4_sueno_titi.webp'), context);
      precacheImage(const AssetImage('assets/images/fondo_modulo5_calendario.webp'), context);
      precacheImage(const AssetImage('assets/images/fondo_modulo6.webp'), context);
    }
  }

  @override
  void dispose() {
    _titiTimer?.cancel();
    _dragAudioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playDragEndSound() async {
    try {
      await _dragAudioPlayer.play(AssetSource('audio/sonido_cuando dejan de arratrar.wav'));
    } catch (e) {
      debugPrint('Error playing drag end sound: $e');
    }
  }

  void _playTitiAnimation() {
    setState(() {
      _isPlayingTiti = true;
    });
    _titiTimer?.cancel();
    _titiTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isPlayingTiti = false;
        });
      }
    });
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

  Iterable<Widget> _buildModuleWidgets(int index, double screenWidth, double screenHeight) {
    if (_modulePositions == null) return const [];
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
        furnAsset = 'assets/images/modulo1.webp';
        btnAsset = 'assets/images/Home_botones/mod_juegos.webp';
        route = '/module1';
        scaleIndex = 0;
        furnWidth = screenWidth * 0.375;
        furnHeight = screenHeight * 0.25;
        btnLeft = 0.02 * screenWidth;
        btnBottom = 0.11 * screenHeight;
        break;
      case 1: // Modulo 2 (Cama)
        furnAsset = 'assets/images/modulo2.webp';
        btnAsset = 'assets/images/Home_botones/mod_bienestarfisico.webp';
        route = '/module2';
        scaleIndex = 1;
        furnWidth = screenWidth * 0.4134375;
        furnHeight = screenHeight * 0.275625;
        btnLeft = 0.08 * screenWidth;
        btnBottom = 0.14 * screenHeight;
        break;
      case 2: // Modulo 3 (Meditación)
        furnAsset = 'assets/images/modulo3.webp';
        btnAsset = 'assets/images/Home_botones/mod_meditacion.webp';
        route = '/module3';
        scaleIndex = 2;
        furnWidth = screenWidth * 0.45375;
        furnHeight = screenHeight * 0.3025;
        btnLeft = 0.13 * screenWidth;
        btnBottom = 0.15 * screenHeight;
        break;
      case 3: // Modulo 4 (Juegos)
        furnAsset = 'assets/images/modulo4.webp';
        btnAsset = 'assets/images/Home_botones/mod_suenoydescanso.webp';
        route = '/module4';
        scaleIndex = 3;
        furnWidth = screenWidth * 0.4125;
        furnHeight = screenHeight * 0.275;
        btnLeft = 0.02 * screenWidth;
        btnBottom = 0.132 * screenHeight;
        break;
      case 4: // Modulo 5 (Horario)
        furnAsset = 'assets/images/modulo5.webp';
        btnAsset = 'assets/images/Home_botones/mod_horario.webp';
        route = '/module5';
        scaleIndex = 4;
        furnWidth = screenWidth * 0.375;
        furnHeight = screenHeight * 0.25;
        btnLeft = -0.02 * screenWidth;
        btnBottom = 0.13 * screenHeight;
        break;
      case 5: // Modulo 6 (Bienestar Físico)
        furnAsset = 'assets/images/modulo6.webp';
        btnAsset = 'assets/images/Home_botones/mod_lecciones.webp';
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
          _playDragEndSound();
          _playTitiAnimation();
        },
        child: child,
      );
    }

    return [
      // 1. El Mueble
      Positioned(
        key: ValueKey('furn_$index'),
        left: pos.dx + (btnLeft < 0 ? -btnLeft : 0),
        bottom: pos.dy,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDraggingThis ? 0.7 : 1.0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: isDraggingThis ? 1.08 : 1.0,
            child: FadeIn(
              delay: Duration(milliseconds: 500 + index * 100),
              child: SizedBox(
                width: furnWidth,
                height: furnHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Imagen del mueble en su tamaño original completo
                    Image.asset(
                      furnAsset,
                      width: furnWidth,
                      height: furnHeight,
                      fit: BoxFit.contain,
                    ),
                    // Área activa para seleccionar y arrastrar (40% del tamaño visual y de forma ovalada)
                    Positioned(
                      width: furnWidth * 0.40,
                      height: furnHeight * 0.40,
                      child: ClipOval(
                        child: wrapWithDrag(
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              border: _isDebugMode ? Border.all(color: Colors.red, width: 2) : null,
                              color: _isDebugMode ? Colors.red.withOpacity(0.2) : Colors.transparent,
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
        ),
      ),

      // 2. El Botón
      Positioned(
        key: ValueKey('btn_$index'),
        left: pos.dx + (btnLeft < 0 ? 0 : btnLeft),
        bottom: pos.dy + btnBottom,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDraggingThis ? 0.7 : 1.0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: isDraggingThis ? 1.08 : 1.0,
            child: FadeIn(
              delay: Duration(milliseconds: 550 + index * 100),
              child: AnimatedScale(
                scale: _moduleScales[scaleIndex] ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isDraggingThis ? null : () async {
                    debugPrint("Tapped button for Module ${index + 1} ($route) - Pre-scale trigger");
                    await _triggerScale(scaleIndex);
                    debugPrint("Navigating to module route: $route");
                    if (context.mounted) context.push(route);
                  },
                  child: SizedBox(
                    width: btnHeight,
                    height: btnHeight,
                    child: Stack(
                      children: [
                        Image.asset(
                          btnAsset,
                          fit: BoxFit.contain,
                        ),
                        if (_isDebugMode)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 1.5),
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image (100%) ──
          Image.asset(
            'assets/images/fondotiti.webp',
            fit: BoxFit.cover,
          ),

          // ── GIF Character (Responsive %) ──
          Positioned(
            left: screenWidth * 0.28, // 1% más a la izquierda
            top: screenHeight * 0.42, // 4% más arriba
            child: FadeIn(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _playTitiAnimation();
                },
                child: SizedBox(
                  width: screenWidth * 0.45875, // 37.5% * 1.25
                  height: screenHeight * 0.45875, // 37.5% * 1.25
                  child: IndexedStack(
                    index: _isPlayingTiti ? 0 : 1,
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/Video.webp',
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                      Image.asset(
                        'assets/images/Video_static.webp',
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Header (Configuración y Emergencia) ──
          const ModuleHeader(),

          // ── Debug Mode Toggle Button ──
          Positioned(
            left: screenWidth * 0.22,
            top: screenHeight * 0.10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isDebugMode = !_isDebugMode;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isDebugMode ? Colors.redAccent.withOpacity(0.9) : Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isDebugMode ? Icons.bug_report : Icons.bug_report_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isDebugMode ? 'DEBUG: ON' : 'DEBUG',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── ELEMENTOS DE MÓDULOS AGRUPADOS Y MÓVILES ORDENADOS POR PROFUNDIDAD (2.5D) ──
          if (_modulePositions != null)
            ...() {
              final indices = <int>[0, 1, 2, 3, 4, 5];
              // Ordenamos de mayor Y a menor Y (fondo a primer plano)
              indices.sort((a, b) => _modulePositions![b].dy.compareTo(_modulePositions![a].dy));
              return indices.expand((index) => _buildModuleWidgets(
                index,
                screenWidth,
                screenHeight,
              ));
            }(),

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
