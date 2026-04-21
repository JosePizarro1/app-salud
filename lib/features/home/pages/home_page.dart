import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../models/module_model.dart';
import '../../../app/widgets/theme_switcher.dart';
import '../../../app/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int? selectedModuleIndex;
  
  @override
  Widget build(BuildContext context) {
    if (healthModules.isEmpty) {
      return const Scaffold(body: Center(child: Text("Cargando módulos...")));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 🎨 Header Decorativo (Estilo Aslam)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeInLeft(
                          child: Text(
                            "Vitali",
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        FadeInRight(
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                                onPressed: () => context.push('/settings'),
                              ),
                              const ThemeSwitcher(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 40),
                    child: FadeInDown(
                      duration: const Duration(seconds: 1),
                      child: const Center(child: _AnimatedMascot()),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text(
                        "MÓDULOS DE SALUD",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondaryLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: _buildModuleCard(healthModules[index], index),
                        );
                      },
                      childCount: healthModules.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),

          // 🔵 Floating Action Button (Start Button)
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final bool isSelected = selectedModuleIndex != null;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      bottom: isSelected ? 30 : -100,
      left: 24,
      right: 24,
      child: ZoomIn(
        animate: isSelected,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            final module = healthModules[selectedModuleIndex!];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Iniciando ${module.title}..."),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            );
          },
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                SizedBox(width: 8),
                Text(
                  "COMENZAR RUTINA",
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white, 
                    letterSpacing: 1.2
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(ModuleModel module, int index) {
    bool isSelected = selectedModuleIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => selectedModuleIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? AppColors.primary.withValues(alpha: 0.2) 
                : Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: _SafeLottie(
                    source: module.lottieUrl,
                    fallbackIcon: module.icon,
                    fallbackColor: module.color,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
              child: Text(
                module.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedMascot extends StatelessWidget {
  const _AnimatedMascot();
  @override
  Widget build(BuildContext context) {
    return Pulse(
      infinite: true,
      duration: const Duration(seconds: 3),
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ],
        ),
        child: const Center(child: Text('💊', style: TextStyle(fontSize: 50))),
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
      fallback: Icon(fallbackIcon, size: 40, color: fallbackColor),
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

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const spacing = 30.0;
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i - size.height, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
