import 'cell.dart';
import 'grid.dart';

abstract class CellularAutomaton extends Grid {
  int generation = 0;

  CellularAutomaton({required super.width, required super.height, required super.seed,});

  // Determines whether a cell will be alive in the next generation based on its
  // current state and the number of live neighbors
  bool nextState(bool currentlyAlive, int liveNeighborCount);

  // Renders the board state as a string
  String render();

  // Advances the grid state by one timestep and increments generation number.
  void step() {
    final nextAlive = <Cell>{};

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final cell = Cell(x: x, y: y);
        final currentlyAlive = isAlive(cell);
        final neighbors = countLiveNeighbors(x, y);

        if (nextState(currentlyAlive, neighbors)) {
          nextAlive.add(cell);
        }
      }
    }

    // Update grid w/ next generation of cells
    updateState(nextAlive);
    generation++;
  }
}
