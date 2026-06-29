import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:animate_do/animate_do.dart';

class SleepCareReaderPage extends StatefulWidget {
  final int initialPage;
  const SleepCareReaderPage({super.key, this.initialPage = 0});

  @override
  State<SleepCareReaderPage> createState() => _SleepCareReaderPageState();
}

class _SleepCareReaderPageState extends State<SleepCareReaderPage> {
  late PageController _pageController;
  int _currentPage = 0;
  String? _selectedOption; // 'A', 'B', or 'C'
  bool _quizAnswered = false;

  // Audio player and celebration state
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _celebrationVisible = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    _saveProgress(_currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playFeedbackSound(bool isCorrect) async {
    try {
      final assetPath = isCorrect 
          ? 'audio/completado_sonid.mp3' 
          : 'audio/error_sound.mp3';
      await _audioPlayer.play(
        AssetSource(assetPath),
        volume: 0.7,
      );
    } catch (_) {
      // Silently fail if audio device issues occur
    }
  }

  Future<void> _saveProgress(int pageIndex) async {
    // Only count pages 0 to 6 (the 7 chapters) as progressive chapters
    if (pageIndex > 6) return;
    
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList('sleep_care_progress') ?? [];
    
    if (!list.contains(pageIndex.toString())) {
      list.add(pageIndex.toString());
      await prefs.setStringList('sleep_care_progress', list);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _saveProgress(index);
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Completes all chapters (marks all as read)
  Future<void> _completeAll() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = ['0', '1', '2', '3', '4', '5', '6'];
    await prefs.setStringList('sleep_care_progress', list);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == 7;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF0A0E1A), // Dark navy
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Top navigation / Page Indicator (Hidden on completion page)
                  if (!isLastPage)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                context.go('/sleep_care');
                              }
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.12),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                          
                          // Indicator (e.g. 1 de 7)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            child: Text(
                              // Page 6 and 7 are index 5 and 6, which are parts of Chapter 6 & 7.
                              // Map indices (0-6) to Chapter numbers (1-7).
                              '${_currentPage + 1} de 7',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: _currentPage == 5 && !_quizAnswered
                          ? const NeverScrollableScrollPhysics() // Prevent swipe to page 7 until quiz answered
                          : const BouncingScrollPhysics(),
                      children: [
                        _buildPage1(),
                        _buildPage2(),
                        _buildPage3(),
                        _buildPage4(),
                        _buildPage5(),
                        _buildPage6(),
                        _buildPage7(),
                        _buildCompletionPage(),
                      ],
                    ),
                  ),

                  // Bottom navigation buttons (Hidden on completion page)
                  if (!isLastPage)
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 28),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Anterior
                          if (_currentPage > 0)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () => _navigateToPage(_currentPage - 1),
                                  child: Text(
                                    'Anterior',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Siguiente
                          // If page 6 (index 5) and not answered yet, we hide/disable the "Siguiente" button
                          if (!(_currentPage == 5 && !_quizAnswered))
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: _currentPage > 0 ? 8 : 0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6F5CF2), // Rich purple color
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () {
                                    if (_currentPage == 6) {
                                      // Return directly to SleepCarePage
                                      _completeAll();
                                      context.go('/sleep_care');
                                    } else {
                                      _navigateToPage(_currentPage + 1);
                                    }
                                  },
                                  child: Text(
                                    _currentPage == 6 ? 'Finalizar lectura' : 'Siguiente',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              if (_celebrationVisible)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _celebrationVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Container(
                        color: Colors.transparent,
                        child: DotLottieView(
                          sourceType: 'asset',
                          source: 'assets/lottie/success_celebration.lottie',
                          autoplay: true,
                          loop: false,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // P1: ¿Qué es el cuidado del sueño?
  Widget _buildPage1() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ilustración de la Luna
            Image.asset(
              'assets/images/sleep_care/luna.png',
              width: double.infinity,
              height: screenHeight * 0.26,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            // Título del paso
            Text(
              '1. ¿Qué es el cuidado del sueño?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Es el conjunto de hábitos y condiciones que favorecen un descanso adecuado, permitiendo dormir el tiempo necesario y con buena calidad para mantener la salud física y mental.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Ilustración de persona durmiendo en cama
            Image.asset(
              'assets/images/sleep_care/persona_durmiendo.png',
              width: double.infinity,
              height: screenHeight * 0.38,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // P2: ¿Qué beneficios brinda cuidar nuestro sueño?
  Widget _buildPage2() {
    final screenHeight = MediaQuery.of(context).size.height;
    final benefits = [
      'Consolida la memoria y función cognitiva',
      'Mejora la salud cardiovascular',
      'Mejor control de situaciones de estrés',
      'Fortalece el sistema inmunitario',
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono del Corazón en contenedor circular
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFEF4444),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Título del paso
            Text(
              '2. ¿Qué beneficios brinda cuidar nuestro sueño?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Lista de Beneficios
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: benefits.map((b) => _buildBulletPoint(b, AppColors.secondary)).toList(),
              ),
            ),
            const SizedBox(height: 28),
            // Animación Lottie del Cerebro Divertido (Funny brain)
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.32,
              child: DotLottieView(
                sourceType: 'asset',
                source: 'assets/images/sleep_care/funny_brain.lottie',
                autoplay: true,
                loop: true,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // P3: ¿Qué incluye el cuidado del sueño?
  Widget _buildPage3() {
    final screenHeight = MediaQuery.of(context).size.height;
    final elements = [
      'Mantener un horario regular para acostarse',
      'Realizar actividad física durante el día',
      'Optimizar el entorno a un ambiente tranquilo y oscuro',
      'Evitar estimulantes y dispositivos antes de acostarse',
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono de Reloj en contenedor circular
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/8589/8589425.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Título del paso
            Text(
              '3. ¿Qué incluye el cuidado del sueño?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Lista de Elementos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: elements.map((e) => _buildBulletPoint(e, AppColors.accent)).toList(),
              ),
            ),
            const SizedBox(height: 28),
            // Ilustración inferior (Titi durmiendo)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/titi zzz.png',
                width: double.infinity,
                height: screenHeight * 0.32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // P4: ¿Qué pasa si no cuido mi sueño?
  Widget _buildPage4() {
    final screenHeight = MediaQuery.of(context).size.height;
    final consequences = [
      'Deterioro del rendimiento académico',
      'Riesgo de somnolencia diurna',
      'Irritabilidad',
      'Sensación de cansancio',
      'Síntomas de depresión y ansiedad',
      'Deterioro de la memoria a largo plazo',
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono de Reloj en contenedor circular
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/8589/8589425.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Título del paso
            Text(
              '4. ¿Qué pasa si no cuido mi sueño?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Lista de Consecuencias
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: consequences.map((c) => _buildBulletPoint(c, AppColors.primary)).toList(),
              ),
            ),
            const SizedBox(height: 28),
            // Ilustración inferior (Paso 4)
            Image.asset(
              'assets/images/sleep_care/paso4_v1.png',
              width: double.infinity,
              height: screenHeight * 0.32,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // P5: Entonces... ¿cuánto tiempo debo dormir?
  Widget _buildPage5() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ilustración de la Luna
            Image.asset(
              'assets/images/sleep_care/luna.png',
              width: double.infinity,
              height: screenHeight * 0.26,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            // Título del paso
            Text(
              '5. Entonces... ¿cuánto tiempo debo dormir?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Los adultos jóvenes entre 18 y 25 años necesitan aproximadamente 7 a 9 horas de sueño por noche para mantener un buen funcionamiento cognitivo, emocional y físico.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Ilustración inferior (Mascota durmiendo) con etiqueta de horas
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/titi zzz.png',
                    width: double.infinity,
                    height: screenHeight * 0.32,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E38), // Azul oscuro noche
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '7-9 horas',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // P6: Ayúdame... ¿qué puedo hacer? (Caso de estudio)
  Widget _buildPage6() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título del paso
            Text(
              '6. Ayúdame... ¿qué puedo hacer?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Caso de estudio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Es miércoles, estoy en mi primer ciclo y mañana tengo un examen parcial importante a las 8:00 AM. Todavía me faltan 3 temas por repasar y siento que el sueño me vence.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Animación Lottie del Cerebro Divertido
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.22,
              child: DotLottieView(
                sourceType: 'asset',
                source: 'assets/images/sleep_care/funny_brain.lottie',
                autoplay: true,
                loop: true,
              ),
            ),
            const SizedBox(height: 20),
            // Lista de Opciones
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué opción eliges?',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                // Option A
                _buildOptionRadio(
                  'A',
                  'EL GUERRERO DE LA NOCHE',
                  'Tomo una taza de café cargado, pongo música a todo volumen y me quedo estudiando hasta las 4:00 AM para terminar todo.',
                ),
                const SizedBox(height: 12),
                // Option B
                _buildOptionRadio(
                  'B',
                  'EL ESTRATÉGICO',
                  'Repaso 30 minutos más de forma intensa, me acuesto para dormir al menos 6 horas y me despierto 45 minutos antes para una revisión rápida.',
                ),
                const SizedBox(height: 12),
                // Option C
                _buildOptionRadio(
                  'C',
                  'EL RENDIDO',
                  'Dejo de estudiar ahora mismo, me pongo a ver TikTok para “relajarme” hasta la 1:00 AM y luego intento dormir.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Ver respuesta Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.white.withOpacity(0.05),
                  disabledForegroundColor: Colors.white.withOpacity(0.2),
                ),
                onPressed: _selectedOption != null
                    ? () {
                        final isCorrect = _selectedOption == 'B';
                        _playFeedbackSound(isCorrect);
                        
                        if (isCorrect) {
                          setState(() {
                            _celebrationVisible = true;
                          });
                          Future.delayed(const Duration(milliseconds: 3500), () {
                            if (mounted) {
                              setState(() {
                                _celebrationVisible = false;
                              });
                            }
                          });
                        }
                        
                        setState(() {
                          _quizAnswered = true;
                        });
                        _navigateToPage(6); // Go to Page 7 (Resolution)
                      }
                    : null,
                child: Text(
                  'Ver respuesta',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // P7: Resolución
  Widget _buildPage7() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCorrect = _selectedOption == 'B';
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono circular dinámico
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isCorrect ? AppColors.success : AppColors.primary).withOpacity(0.06),
                border: Border.all(
                  color: (isCorrect ? AppColors.success : AppColors.primary).withOpacity(0.12),
                ),
              ),
              child: Center(
                child: Icon(
                  isCorrect ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                  color: isCorrect ? AppColors.success : AppColors.primary,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Título de la Resolución
            Text(
              isCorrect ? '¡Excelente elección!' : 'Podrías elegir una mejor opción...',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isCorrect ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'La mejor decisión para tu descanso y rendimiento académico es:',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            // Tarjeta de la Opción Correcta
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'B: EL ESTRATÉGICO',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Repaso 30 minutos más de forma intensa, te acuestas para dormir al menos 6 horas y te despiertas 45 minutos antes para una revisión rápida.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Explicación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '¿Por qué? Estudiar de largo reduce significativamente tu concentración durante el examen y tu cerebro no consolida lo aprendido. Dormir al menos 6 horas te mantendrá alerta y enfocado.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Ilustración inferior
            Image.asset(
              'assets/images/sleep_care/persona_durmiendo.png',
              width: double.infinity,
              height: screenHeight * 0.28,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // P8: Completion Page
  Widget _buildCompletionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Moon check icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.12),
              ),
              child: const Icon(
                Icons.nights_stay_rounded,
                color: AppColors.secondary,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
  
            Text(
              '¡Has completado la lectura sobre el cuidado del sueño!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Recuerda que cuidar tu sueño es cuidar tu bienestar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
  
            // Next steps
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sigue aplicando lo aprendido',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
  
            // Step 1: Planifica tu rutina nocturna
            _buildActionItem(
              icon: Icons.calendar_month_rounded,
              title: 'Planifica tu rutina nocturna',
              onTap: () {
                context.go('/module4');
                context.push('/night_routine');
              },
            ),
            const SizedBox(height: 10),
  
            // Step 2: Mantén buenos hábitos
            _buildActionItem(
              icon: Icons.check_circle_outline_rounded,
              title: 'Mantén buenos hábitos',
              onTap: null,
            ),
            const SizedBox(height: 10),
  
            // Step 3: Duerme bien, vive mejor
            _buildActionItem(
              icon: Icons.favorite_border_rounded,
              title: 'Duerme bien, vive mejor',
              onTap: null,
            ),
  
            const SizedBox(height: 40),
  
            // Back to home button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  context.go('/sleep_care'); // Regresa a la pantalla de cuidado del sueño
                },
                child: Text(
                  'Finalizar',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _buildCardWrapper({
    required String title,
    String? imagePath,
    required Widget content,
    String? badgeText,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Illustration
                if (imagePath != null) ...[
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          imagePath,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (badgeText != null)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8A71), // Coral accent
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Title
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                
                // Dynamic Content
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color bulletColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star_rate_rounded, color: bulletColor.withOpacity(0.8), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 15,
                height: 1.4,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRadio(String option, String title, String body) {
    final isSelected = _selectedOption == option;
    
    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: InkWell(
        onTap: () {
          if (!_quizAnswered) {
            setState(() {
              _selectedOption = option;
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.secondary.withOpacity(0.08) 
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? AppColors.secondary 
                  : Colors.white.withOpacity(0.06),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio Indicator
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : Colors.white24,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option == 'B' ? 'B: EL ESTRATÉGICO' : (option == 'A' ? 'A: EL GUERRERO DE LA NOCHE' : 'C: EL RENDIDO'),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.secondary : Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.4), size: 14),
          ],
        ),
      ),
    );
  }
}
