import 'dart:math';

class SudokuEngine {
  final int size = 4;
  final int boxSize = 2;
  
  late List<List<int>> solution;
  late List<List<int>> puzzle;
  late List<List<bool>> isInitial;

  SudokuEngine() {
    generateNewGame();
  }

  void generateNewGame() {
    // 1. Inicializar solución con ceros
    solution = List.generate(size, (_) => List.filled(size, 0));
    
    // 2. Llenar el tablero (solución completa)
    _solve(0, 0);
    
    // 3. Crear el puzzle (inicialmente todo vacío)
    puzzle = List.generate(size, (_) => List.filled(size, 0));
    isInitial = List.generate(size, (_) => List.filled(size, false));
    
    // 4. Llenar exactamente 1 celda por cada cuadrante 2x2 (Total 4)
    final random = Random();
    for (int boxRow = 0; boxRow < 2; boxRow++) {
      for (int boxCol = 0; boxCol < 2; boxCol++) {
        // Elegir una celda aleatoria dentro del cuadrante 2x2
        int r = boxRow * 2 + random.nextInt(2);
        int c = boxCol * 2 + random.nextInt(2);
        
        puzzle[r][c] = solution[r][c];
        isInitial[r][c] = true;
      }
    }
  }

  // Algoritmo de Backtracking para generar el tablero completo
  bool _solve(int row, int col) {
    if (col == size) {
      row++;
      col = 0;
    }
    if (row == size) return true;

    List<int> nums = [1, 2, 3, 4]..shuffle();
    for (int num in nums) {
      if (_isSafe(row, col, num)) {
        solution[row][col] = num;
        if (_solve(row, col + 1)) return true;
        solution[row][col] = 0;
      }
    }
    return false;
  }

  bool _isSafe(int row, int col, int num) {
    // Fila
    for (int x = 0; x < size; x++) {
      if (solution[row][x] == num) return false;
    }
    // Columna
    for (int x = 0; x < size; x++) {
      if (solution[x][col] == num) return false;
    }
    // Caja 2x2
    int startRow = row - row % boxSize;
    int startCol = col - col % boxSize;
    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        if (solution[i + startRow][j + startCol] == num) return false;
      }
    }
    return true;
  }

  bool isComplete() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        // Si hay una celda vacía o incorrecta, no está completo
        if (puzzle[i][j] == 0 || puzzle[i][j] != solution[i][j]) {
          return false;
        }
      }
    }
    return true;
  }
}
