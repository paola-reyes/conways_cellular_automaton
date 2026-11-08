/// Pure-Dart simulation engine — no `dart:io`, no terminal code. This is
/// the part that gets imported unchanged by both the CLI (`bin/`) and,
/// later, the Flutter app.
library;

export 'src/cell.dart';
export 'src/cellular_automaton.dart';
export 'src/grid.dart';
export 'src/rendering.dart';
export 'src/rules.dart';
