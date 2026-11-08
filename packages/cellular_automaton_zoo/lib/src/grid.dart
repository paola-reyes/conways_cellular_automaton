import 'dart:math';
import 'cell.dart';

class Grid {
  final int width;
  final int height;
  final int seed;

  final Set<Cell> _liveCells = {};

  Grid({required this.width, required this.height, required this.seed})
      : assert(width > 0, 'Width must be greater than 0.'),
        assert(height > 0, 'Height must be greater than 0.') {
    _createGrid();
  }

  // Add living cells to new grid
  void _createGrid() {
    final random = Random(seed);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        // Randomly initialize ~35% of cells as alive
        if (random.nextInt(100) < 35) {
          _liveCells.add(Cell(x: x, y: y));
        }
      }
    }

    // Ensure at least one living cell exists
    if (_liveCells.isEmpty) {
      _liveCells.add(Cell(x: width ~/ 2, y: height ~/ 2));
    }
  }

  // Returns whether a given cell is alive
  bool isAlive(Cell cell) {
    // Check for out of bounds
    if (cell.x < 0 || cell.x >= width || cell.y < 0 || cell.y >= height) {
      throw ArgumentError(
        'Cell position (${cell.x}, ${cell.y}) is out of bounds for Grid of size ($width x $height).',
      );
    }

    return _liveCells.contains(cell);
  }

  // Returns whether the cell at given Grid position is alive
  bool isAliveAt(int x, int y) => isAlive(Cell(x: x, y: y));

  // Counts the number of living neighbors surrounding cell at given (x, y)
  int countLiveNeighbors(int x, int y) {
    var count = 0;

    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;

        final nx = x + dx;
        final ny = y + dy;

        if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
          if (_liveCells.contains(Cell(x: nx, y: ny))) {
            count++;
          }
        }
      } // end of inner for{}
    } // end of outer for{}

    return count;
  }

  // Updates the grid with the next generation of living cells
  void updateState(Set<Cell> nextLivingCells) {
    _liveCells.clear();
    _liveCells.addAll(nextLivingCells);
  }

  // Get current live cell population
  int get population => _liveCells.length;
}
