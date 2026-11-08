import 'cellular_automaton.dart';

// Implements Conway's Game of Life rules (B3/S23):
// 1) Any live cell with 2 or 3 live neighbors lives on
// 2) Any dead cell with exactly 3 live neighbors becomes alive
// 3) All other cells die or remain dead
mixin ConwayRules on CellularAutomaton {
  @override
  bool nextState(bool currentlyAlive, int liveNeighborCount) {
    if (currentlyAlive) {
      return liveNeighborCount == 2 || liveNeighborCount == 3;
    } else {
      return liveNeighborCount == 3;
    }
  }
}

// Implements custom rules (HighLife B36/S23):
// 1) Any live cell with 2 or 3 live neighbors lives on
// 2) Any dead cell with 3 or 6 live neighbors becomes alive
// 3) All other cells die or remain dead
mixin CustomRules on CellularAutomaton {
  @override
  bool nextState(bool currentlyAlive, int liveNeighborCount) {
    if (currentlyAlive) {
      return liveNeighborCount == 2 || liveNeighborCount == 3;
    } else {
      return liveNeighborCount == 3 || liveNeighborCount == 6;
    }
  }
}
