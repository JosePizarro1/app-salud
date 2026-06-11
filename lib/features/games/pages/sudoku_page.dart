import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
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

  @override
  void initState() {
    super.initState();
    _engine = SudokuEngine();
  }

  void _onCellTap(int r, int c) {
    if (_engine.isInitial[r][c] || _isFinished) return;
    setState(() {
      _selectedRow = r;
      _selectedCol = c;
    });
  }

  void _onNumberTap(int num) {
    if (_selectedRow == null || _selectedCol == null || _isFinished) return;
    
    setState(() {
      _engine.puzzle[_selectedRow!][_selectedCol!] = num;
      if (_engine.isComplete()) {
        _isFinished = true;
        _showWinDialog();
      }
    });
  }

  void _showWinDialog() {
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
                  _engine.generateNewGame();
                  _isFinished = false;
                  _selectedRow = null;
                  _selectedCol = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgLight,
              AppColors.surfaceLight,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Header
            const ModuleHeader(showHome: true),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 100), // Bajado un poco más como pidió el usuario
                  FadeInDown(
                    child: Text(
                      "Sudoku 4x4",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15), // Spacing aumentado
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
                  
                  // Grilla Sudoku
                  FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25),
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

                  const Spacer(),

                  // Teclado Numérico
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...List.generate(4, (i) => _buildNumberButton(i + 1)),
                        _buildActionButton(
                          Icons.backspace_rounded, 
                          () => _onNumberTap(0),
                          color: AppColors.error.withValues(alpha: 0.1),
                          iconColor: AppColors.error,
                        ),
                        _buildActionButton(
                          Icons.refresh_rounded, 
                          () {
                            setState(() {
                              _engine.generateNewGame();
                              _selectedRow = null;
                              _selectedCol = null;
                            });
                          },
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          iconColor: AppColors.secondary,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 120), // Subido aún más como pidió el usuario
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
    bool isError = value != 0 && !isInitial && value != _engine.solution[r][c];

    // Bordes para diferenciar los bloques 2x2
    BorderSide thickBorder = BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 2.5);
    BorderSide thinBorder = BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1);

    return GestureDetector(
      onTap: () => _onCellTap(r, c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withValues(alpha: 0.15) 
              : (isInitial ? Colors.grey.withValues(alpha: 0.05) : Colors.transparent),
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
                color: isInitial 
                    ? AppColors.textPrimaryLight 
                    : (isError ? AppColors.error : AppColors.secondary),
              ),
            ),
      ),
    );
  }

  Widget _buildNumberButton(int num) {
    return ZoomIn(
      delay: Duration(milliseconds: 100 * num),
      child: GestureDetector(
        onTap: () => _onNumberTap(num),
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            num.toString(),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {required Color color, required Color iconColor}) {
    return ZoomIn(
      delay: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 26),
        ),
      ),
    );
  }
}
