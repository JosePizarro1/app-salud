import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/services/sfx_manager.dart';
import '../../../app/theme/app_colors.dart';
import '../../home/widgets/module_header.dart';
import '../logic/sudoku_engine.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  late SudokuEngine _engine;
  int? _selectedRow;
  int? _selectedCol;
  bool _isFinished = false;
  bool _hasUsedHint = false;
  bool _isShowingHintFeedback = false;

  @override
  void initState() {
    super.initState();
    _engine = SudokuEngine();
    _checkFirstTimeTutorial();
  }

  void _resetGame() {
    _engine.generateNewGame();
    _isFinished = false;
    _selectedRow = null;
    _selectedCol = null;
    _hasUsedHint = false;
    _isShowingHintFeedback = false;
  }

  bool _hasPlacedAnyNumber() {
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (!_engine.isInitial[r][c] && _engine.puzzle[r][c] != 0) {
          return true;
        }
      }
    }
    return false;
  }

  void _onHintTap() {
    if (_hasUsedHint || !_hasPlacedAnyNumber() || _isFinished) return;
    SfxManager().playClick();
    HapticFeedback.mediumImpact();
    setState(() {
      _hasUsedHint = true;
      _isShowingHintFeedback = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFB300)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pista activada: verde (acierto) y rojo (error).',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _checkFirstTimeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool tutorialSeen = prefs.getBool('sudoku_tutorial_seen') ?? false;
    if (!tutorialSeen) {
      await prefs.setBool('sudoku_tutorial_seen', true);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showHelpDialog();
        });
      }
    }
  }

  void _onCellTap(int r, int c) {
    if (_engine.isInitial[r][c] || _isFinished) return;
    SfxManager().playClick();
    setState(() {
      _selectedRow = r;
      _selectedCol = c;
    });
  }

  void _onNumberTap(int num) {
    if (_selectedRow == null || _selectedCol == null || _isFinished) return;
    SfxManager().playClick();
    setState(() {
      _engine.puzzle[_selectedRow!][_selectedCol!] = num;
      _isShowingHintFeedback = false;
      if (_engine.isComplete()) {
        _isFinished = true;
        _showWinDialog();
      }
    });
  }

  void _showWinDialog() {
    SfxManager().playNotiSound();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FadeInUp(
        child: AlertDialog(
          backgroundColor: AppColors.bgLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: Text(
            "¡Increíble!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, size: 80, color: AppColors.warning),
              const SizedBox(height: 20),
              Text(
                "Has completado el Sudoku con éxito.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _resetGame();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text("Jugar de nuevo", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    int activeTab = 0; // 0 = ¿Cómo Jugar? (Reglas y Animaciones), 1 = Código de Colores
    int ruleStep = 0; // 0 = Filas, 1 = Columnas, 2 = Bloques 2x2

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return FadeInUp(
            duration: const Duration(milliseconds: 300),
            child: Dialog(
              backgroundColor: const Color(0xFFFFFDF9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header del Dialog
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.extension_rounded, color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "¿Cómo jugar Sudoku 4x4?",
                                style: GoogleFonts.outfit(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                "Guía paso a paso con animaciones",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Selector de Pestañas (Parte 1 vs Parte 2)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2ECE1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() => activeTab = 0);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: activeTab == 0 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: activeTab == 0
                                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "1. Reglas ➡️",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: activeTab == 0 ? FontWeight.bold : FontWeight.w500,
                                    color: activeTab == 0 ? AppColors.primary : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() => activeTab = 1);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: activeTab == 1 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: activeTab == 1
                                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "2. Colores 🎨",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: activeTab == 1 ? FontWeight.bold : FontWeight.w500,
                                    color: activeTab == 1 ? AppColors.primary : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CONTENIDO PARTE 1: REGLAS CON ANIMACIÓN Y FLECHAS
                    if (activeTab == 0) ...[
                      // Selector de Sub-pasos (Filas, Columnas, Bloque 2x2)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStepChip(
                            label: "Filas ➡️",
                            isSelected: ruleStep == 0,
                            onTap: () => setModalState(() => ruleStep = 0),
                          ),
                          _buildStepChip(
                            label: "Columnas ⬇️",
                            isSelected: ruleStep == 1,
                            onTap: () => setModalState(() => ruleStep = 1),
                          ),
                          _buildStepChip(
                            label: "Bloques 🔲",
                            isSelected: ruleStep == 2,
                            onTap: () => setModalState(() => ruleStep = 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Diagrama de Mini-Sudoku Animado
                      Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                            itemCount: 16,
                            itemBuilder: (context, index) {
                              int r = index ~/ 4;
                              int c = index % 4;

                              // Matriz de demostración
                              final demoMatrix = [
                                [1, 2, 3, 4],
                                [3, 4, 1, 2],
                                [2, 1, 4, 3],
                                [4, 3, 2, 1],
                              ];

                              bool isHighlighted = false;
                              Color highlightColor = Colors.transparent;

                              if (ruleStep == 0 && r == 0) {
                                isHighlighted = true;
                                highlightColor = AppColors.mint.withValues(alpha: 0.4);
                              } else if (ruleStep == 1 && c == 1) {
                                isHighlighted = true;
                                highlightColor = AppColors.secondary.withValues(alpha: 0.25);
                              } else if (ruleStep == 2 && r < 2 && c < 2) {
                                isHighlighted = true;
                                highlightColor = AppColors.warning.withValues(alpha: 0.3);
                              }

                              BorderSide thickBorder = BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 2);
                              BorderSide thinBorder = BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1);

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: isHighlighted ? highlightColor : Colors.white,
                                  border: Border(
                                    top: r % 2 == 0 ? thickBorder : thinBorder,
                                    left: c % 2 == 0 ? thickBorder : thinBorder,
                                    bottom: thinBorder,
                                    right: thinBorder,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  demoMatrix[r][c].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                                    color: isHighlighted ? AppColors.primary : Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Tarjeta explicativa según la regla elegida
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey(ruleStep),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.mint.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.mint.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                ruleStep == 0 ? Icons.arrow_forward_rounded : (ruleStep == 1 ? Icons.arrow_downward_rounded : Icons.grid_view_rounded),
                                color: AppColors.primary,
                                size: 26,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ruleStep == 0
                                      ? "➡️ Filas Horizontales: Debes formar la secuencia 1, 2, 3 y 4 a lo largo de cada línea horizontal sin repetir ninguno."
                                      : (ruleStep == 1
                                          ? "⬇️ Columnas Verticales: Cada línea vertical también debe contener los números 1, 2, 3 y 4 en orden."
                                          : "🔲 Bloques 2x2: Cada cuadrante de 2x2 casillas debe incluir los números del 1 al 4 sin duplicados."),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // CONTENIDO PARTE 2: CÓDIGO DE COLORES Y TECLADO
                    if (activeTab == 1) ...[
                      Text(
                        "Significado de Colores",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildColorGuideItem(
                        sampleCell: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: Text("3", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight)),
                        ),
                        title: "Pista fija inicial",
                        description: "Número predeterminado del juego. No se puede modificar.",
                      ),
                      const SizedBox(height: 8),

                      _buildColorGuideItem(
                        sampleCell: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                        ),
                        title: "Celda seleccionada",
                        description: "Resaltada para indicarte dónde se colocará el número.",
                      ),
                      const SizedBox(height: 8),

                      _buildColorGuideItem(
                        sampleCell: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                          ),
                          alignment: Alignment.center,
                          child: Text("2", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                        ),
                        title: "Tu respuesta",
                        description: "Número ingresado por vos. Podés cambiarlo o borrarlo.",
                      ),
                      const SizedBox(height: 8),

                      _buildColorGuideItem(
                        sampleCell: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                          ),
                          alignment: Alignment.center,
                          child: Text("4", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.error)),
                        ),
                        title: "Conflicto / Duplicado",
                        description: "Aparece en rojo cuando el número se repite en la línea o bloque.",
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Botón de Navegación de Pie
                    Row(
                      children: [
                        if (activeTab == 0)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                setModalState(() => activeTab = 1);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                "Siguiente: Colores 🎨",
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                "¡Entendido, a jugar! 🚀",
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3)),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildColorGuideItem({
    required Widget sampleCell,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEAE2)),
      ),
      child: Row(
        children: [
          sampleCell,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // Responsive sizing to prevent overlap with ModuleHeader and overflow on small screens
    final double gridWidth = screenWidth < 500 ? (screenWidth - 50) : 400.0;
    final double topSpacing = screenHeight < 750 ? 110.0 : 135.0;
    final double bottomSpacing = screenHeight < 750 ? 30.0 : 70.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo_sudoku.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Header
            const ModuleHeader(showHome: true, showBack: true),

            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: topSpacing),
                  FadeInDown(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudoku 4x4",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _showHelpDialog();
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.help_outline_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          tooltip: "¿Cómo jugar?",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      "Completa la grilla con números del 1 al 4",
                      style: GoogleFonts.poppins(
                        fontSize: 15, 
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  
                  // Grilla Sudoku responsive
                  FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: SizedBox(
                      width: gridWidth,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                              ),
                              itemCount: 16,
                              itemBuilder: (context, index) {
                                int r = index ~/ 4;
                                int c = index % 4;
                                return _buildCell(r, c);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Teclado Numérico Responsive
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...List.generate(4, (i) => _buildNumberButton(i + 1, size: screenWidth < 380 ? 40.0 : 44.0)),
                        _buildActionButton(
                          Icons.backspace_rounded, 
                          () {
                            SfxManager().playClick();
                            _onNumberTap(0);
                          },
                          color: AppColors.error.withValues(alpha: 0.1),
                          iconColor: AppColors.error,
                          size: screenWidth < 380 ? 40.0 : 44.0,
                        ),
                        // Botón de Pista (Foquito) - 1 uso por partida
                        _buildActionButton(
                          _hasUsedHint ? Icons.lightbulb_outline_rounded : Icons.lightbulb_rounded,
                          _onHintTap,
                          color: (_hasPlacedAnyNumber() && !_hasUsedHint && !_isFinished)
                              ? const Color(0xFFFFB300).withValues(alpha: 0.18)
                              : Colors.grey.withValues(alpha: 0.08),
                          iconColor: (_hasPlacedAnyNumber() && !_hasUsedHint && !_isFinished)
                              ? const Color(0xFFFFB300)
                              : Colors.grey[400]!,
                          size: screenWidth < 380 ? 40.0 : 44.0,
                        ),
                        _buildActionButton(
                          Icons.refresh_rounded, 
                          () {
                            SfxManager().playClick();
                            setState(() {
                              _resetGame();
                            });
                          },
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          iconColor: AppColors.secondary,
                          size: screenWidth < 380 ? 40.0 : 44.0,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: bottomSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    bool isSelected = _selectedRow == r && _selectedCol == c;
    bool isInitial = _engine.isInitial[r][c];
    int value = _engine.puzzle[r][c];
    bool isPlayerPlaced = !isInitial && value != 0;
    bool isCorrect = isPlayerPlaced && value == _engine.solution[r][c];

    // Fondo de celda
    Color cellBgColor = Colors.transparent;
    if (isSelected) {
      cellBgColor = AppColors.primary.withValues(alpha: 0.15);
    } else if (_isShowingHintFeedback && isPlayerPlaced) {
      cellBgColor = isCorrect
          ? const Color(0xFFE8F5E9) // Verde suave para aciertos
          : const Color(0xFFFFEBEE); // Rojo suave para errores
    } else if (isInitial) {
      cellBgColor = Colors.grey.withValues(alpha: 0.05);
    }

    // Color del texto
    Color textColor = AppColors.secondary;
    if (isInitial) {
      textColor = AppColors.textPrimaryLight;
    } else if (_isShowingHintFeedback && isPlayerPlaced) {
      textColor = isCorrect ? const Color(0xFF2E7D32) : AppColors.error;
    } else {
      // Color uniforme para números colocados por el usuario (sin rojo instantáneo)
      textColor = AppColors.secondary;
    }

    // Bordes para diferenciar los bloques 2x2
    BorderSide thickBorder = BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 2.5);
    BorderSide thinBorder = BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1);

    return GestureDetector(
      onTap: () => _onCellTap(r, c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cellBgColor,
          border: Border(
            top: r == 0 ? BorderSide.none : (r % 2 == 0 ? thickBorder : thinBorder),
            left: c == 0 ? BorderSide.none : (c % 2 == 0 ? thickBorder : thinBorder),
            bottom: thinBorder,
            right: thinBorder,
          ),
        ),
        alignment: Alignment.center,
        child: value == 0 
          ? (isSelected ? FadeIn(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))) : null)
          : Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: isInitial ? FontWeight.w800 : FontWeight.w600,
                color: textColor,
              ),
            ),
      ),
    );
  }

  Widget _buildNumberButton(int num, {double size = 48.0}) {
    return ZoomIn(
      delay: Duration(milliseconds: 100 * num),
      child: GestureDetector(
        onTap: () => _onNumberTap(num),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            num.toString(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {required Color color, required Color iconColor, double size = 48.0}) {
    return ZoomIn(
      delay: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}
