import 'cellular_automaton.dart';
import 'grid.dart';

// Render the grid cells as ASCII characters ("#" for alive and "." for dead)
mixin AsciiRenderable on Grid {
  String render() {
    final buffer = StringBuffer();

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        buffer.write(isAliveAt(x, y) ? '#' : '.');
      }

      buffer.writeln();
    }

    return buffer.toString();
  }
}

// Decorates the rendered board string with a border
mixin DecoratedRenderable on CellularAutomaton {
  @override
  String render() {
    final raw = super.render();
    final lines = raw.split('\n');  // Get rows

    if (lines.isNotEmpty && lines.last.isEmpty) {
      lines.removeLast(); // Remove \n
    }

    final buffer = StringBuffer();

    // Add "+-------+" that stretches over the top and bottom of grid
    final borderHorizontal = '+${'-' * width}+';
    buffer.writeln(borderHorizontal);

    // Add | | to left and right of row content
    for (final line in lines) {
      buffer.writeln('|$line|');
    }

    buffer.writeln(borderHorizontal); // Add bottom border

    return buffer.toString();
  }
}
