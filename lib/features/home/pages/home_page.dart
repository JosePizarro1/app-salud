import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import '../models/module_model.dart';

import '../../../app/widgets/theme_switcher.dart';
import '../../../app/widgets/staggered_entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int? selectedModuleIndex;

  // Animaciones
  late AnimationController _entryController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entryController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startRoutine() {
    if (selectedModuleIndex == null) {
      _showAlert();
    } else {
      if (selectedModuleIndex! >= 0 && selectedModuleIndex! < healthModules.length) {
        final module = healthModules[selectedModuleIndex!];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text("Redireccionando a la sesión de ${module.title}...")),
              ],
            ),
            backgroundColor: const Color(0xFF6366F1),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        );
      }
    }
  }

  void _showAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text("Paso faltante", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Para continuar, por favor selecciona un módulo de salud.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido", style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (healthModules.isEmpty) {
      return const Scaffold(body: Center(child: Text("Cargando módulos...")));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSelectedModule = selectedModuleIndex != null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          // Fondo decorativo
          Positioned(
            top: -50,
            left: -50,
            child: _AnimatedBackgroundBubble(color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFE0E7FF).withValues(alpha: 0.5), size: 200),
          ),
          Positioned(
            bottom: 200,
            right: -100,
            child: _AnimatedBackgroundBubble(color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.2) : const Color(0xFFF5F3FF).withValues(alpha: 0.8), size: 250),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header (Staggered Delay: 0ms)
                SliverToBoxAdapter(
                  child: StaggeredEntry(
                    controller: _entryController,
                    index: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Vitali App",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : Colors.black54),
                                onPressed: () {
                                  context.push('/settings');
                                },
                              ),
                              const SizedBox(width: 8),
                              const ThemeSwitcher(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Hero Section (Staggered Delay: 200ms)
                SliverToBoxAdapter(
                  child: StaggeredEntry(
                    controller: _entryController,
                    index: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: isSelectedModule 
                                ? healthModules[selectedModuleIndex!].color.withValues(alpha: 0.1)
                                : (isDark ? const Color(0xFF1E293B) : Colors.white), 
                              boxShadow: [
                                BoxShadow(
                                  color: isSelectedModule
                                    ? healthModules[selectedModuleIndex!].color.withValues(alpha: 0.2)
                                    : (isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF6366F1).withValues(alpha: 0.1)),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: DotLottieView(
                                  key: ValueKey(isSelectedModule ? healthModules[selectedModuleIndex!].lottieUrl : "default"),
                                  source: isSelectedModule 
                                    ? healthModules[selectedModuleIndex!].lottieUrl 
                                    : "https://lottie.host/8553788b-5a8c-4498-9ce9-45cd893858f4/mr2ro2xqSV.lottie",
                                  sourceType: 'url',
                                  autoplay: true,
                                  loop: true,
                                  speed: isSelectedModule ? healthModules[selectedModuleIndex!].lottieSpeed : 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                // 3. Módulos Header
                SliverToBoxAdapter(
                  child: StaggeredEntry(
                    controller: _entryController,
                    index: 2,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 12),
                      child: Text(
                        "MÓDULOS RECOMENDADOS",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),

                // 4. Módulos Grid
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
                        final module = healthModules[index];
                        return _buildModuleCard(module, index);
                      },
                      childCount: healthModules.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            bottom: selectedModuleIndex != null ? 30 : -100,
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: selectedModuleIndex != null ? 1.0 : 0.0,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                  CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                ),
                child: GestureDetector(
                  onTap: _startRoutine,
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: DotLottieView(
                      source: "assets/lottie/start_button_hovering.lottie",
                      sourceType: 'asset',
                      autoplay: true,
                      loop: true,
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


  Widget _buildModuleCard(ModuleModel module, int index) {
    bool isSelected = selectedModuleIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => selectedModuleIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? Border.all(color: module.color.withValues(alpha: 0.5), width: 2) : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: isSelected ? module.color.withValues(alpha: 0.2) : (isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03)),
              blurRadius: isSelected ? 20 : 15,
              offset: isSelected ? const Offset(0, 8) : const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: module.color.withValues(alpha: 0.1)),
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(module.icon, size: isSelected ? 50 : 40, color: module.color),
                  )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: Text(
                  module.title, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13, 
                    color: isDark ? Colors.white : Colors.black87
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Otros sub-widgets (Burbujas y Botón)
class _AnimatedBackgroundBubble extends StatefulWidget {
  final Color color;
  final double size;
  const _AnimatedBackgroundBubble({required this.color, required this.size});

  @override
  State<_AnimatedBackgroundBubble> createState() => _AnimatedBackgroundBubbleState();
}

class _AnimatedBackgroundBubbleState extends State<_AnimatedBackgroundBubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 15 * _ctrl.value),
        child: Container(
          width: widget.size,
          height: widget.size * (1 + 0.1 * _ctrl.value),
          decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
        ),
      ),
    );
  }
}

