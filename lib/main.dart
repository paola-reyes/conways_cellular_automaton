import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';

// Extension on [CellularAutomaton] to support interactive editing (cell toggling),
// resetting, and clearing without modifying the base package classes.
extension CellToggle on CellularAutomaton {
  // Toggles the cell between alive and dead.
  void toggleCell(int x, int y) {
    final currentLiving = <Cell>{};
    for (var cy = 0; cy < height; cy++) {
      for (var cx = 0; cx < width; cx++) {
        if (isAliveAt(cx, cy)) {
          currentLiving.add(Cell(x: cx, y: cy));
        }
      }
    }
    final target = Cell(x: x, y: y);
    if (currentLiving.contains(target)) {
      currentLiving.remove(target);
    } else {
      currentLiving.add(target);
    }
    updateState(currentLiving);
  }

  // Resets the grid using a new seed for random initialization and resets the generation count to 0.
  void resetBoard(int newSeed) {
    final tempGrid = Grid(width: width, height: height, seed: newSeed);
    final newLiving = <Cell>{};
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (tempGrid.isAliveAt(x, y)) {
          newLiving.add(Cell(x: x, y: y));
        }
      }
    }
    updateState(newLiving);
    generation = 0;
  }

  // Clears all cells to dead state and resets generation count to 0.
  void clearBoard() {
    updateState({});
    generation = 0;
  }
}

// Concrete implementation of game using standard Conway rules.
class ConwayGame extends CellularAutomaton with AsciiRenderable, ConwayRules {
  ConwayGame({required super.width, required super.height, required super.seed});
}

// Concrete implementation of game using HighLife rules (B36/S23).
class HighLifeGame extends CellularAutomaton with AsciiRenderable, CustomRules {
  HighLifeGame({required super.width, required super.height, required super.seed});
}

enum RuleType { conway, highLife }

void main() {
  runApp(const GameOfLifeApp());
}

class GameOfLifeApp extends StatelessWidget {
  const GameOfLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Conway's Game of Life",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const GameOfLifeScreen(),
    );
  }
}

class GameOfLifeScreen extends StatefulWidget {
  const GameOfLifeScreen({super.key});

  @override
  State<GameOfLifeScreen> createState() => _GameOfLifeScreenState();
}

class _GameOfLifeScreenState extends State<GameOfLifeScreen> {
  static const int gridWidth = 20;
  static const int gridHeight = 20;

  late int _currentSeed;
  late CellularAutomaton _game;
  RuleType _ruleType = RuleType.conway;

  Timer? _timer;
  bool _isPlaying = false;
  double _stepsPerSecond = 4.0; // 1 to 20 steps/sec (left = slow, right = fast)
  int get _speedMs => (1000 / _stepsPerSecond).round();

  @override
  void initState() {
    super.initState();
    _currentSeed = Random().nextInt(100000);
    _initGame();
  }

  void _initGame() {
    switch (_ruleType) {
      case RuleType.conway:
        _game = ConwayGame(width: gridWidth, height: gridHeight, seed: _currentSeed);
        break;
      case RuleType.highLife:
        _game = HighLifeGame(width: gridWidth, height: gridHeight, seed: _currentSeed);
        break;
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _play() {
    _timer?.cancel();
    setState(() {
      _isPlaying = true;
    });
    _timer = Timer.periodic(
      Duration(milliseconds: _speedMs),
      (_) {
        setState(() {
          _game.step();
        });
      },
    );
  }

  void _pause() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

  void _reset() {
    setState(() {
      _currentSeed = Random().nextInt(100000);
      _game.resetBoard(_currentSeed);
    });
  }

  void _clear() {
    setState(() {
      _game.clearBoard();
    });
  }

  void _stepOnce() {
    setState(() {
      _game.step();
    });
  }

  void _toggleCell(int x, int y) {
    setState(() {
      _game.toggleCell(x, y);
    });
  }

  void _changeRule(RuleType newRule) {
    if (_ruleType == newRule) return;
    final isRunning = _isPlaying;
    _pause();

    // Preserve living cells across rule changes
    final currentLiving = <Cell>{};
    for (var y = 0; y < gridHeight; y++) {
      for (var x = 0; x < gridWidth; x++) {
        if (_game.isAliveAt(x, y)) {
          currentLiving.add(Cell(x: x, y: y));
        }
      }
    }
    final gen = _game.generation;

    setState(() {
      _ruleType = newRule;
      _initGame();
      _game.updateState(currentLiving);
      _game.generation = gen;
    });

    if (isRunning) {
      _play();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conway's Game of Life"),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Game of Life',
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status & info header
                  _buildInfoHeader(colorScheme),
                  const SizedBox(height: 8),

                  // Rule selection & speed controls
                  _buildControlsHeader(colorScheme),
                  const SizedBox(height: 8),

                  // 20x20 game board grid
                  _buildGameBoard(colorScheme),
                  const SizedBox(height: 12),

                  // Primary control buttons (Play, Pause, Reset, Step, Clear)
                  _buildActionButtons(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Game stats header with population, generation, and game status
  Widget _buildInfoHeader(ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatChip(
              icon: Icons.numbers,
              label: 'Gen',
              value: '${_game.generation}',
              colorScheme: colorScheme,
            ),
            _buildStatChip(
              icon: Icons.people_outline,
              label: 'Population',
              value: '${_game.population} / ${gridWidth * gridHeight}',
              colorScheme: colorScheme,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isPlaying
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPlaying ? Colors.green : Colors.amber,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPlaying ? Icons.play_arrow : Icons.pause,
                    size: 14,
                    color: _isPlaying ? Colors.green : Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isPlaying ? 'RUNNING' : 'PAUSED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isPlaying ? Colors.green : Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  // Controls for game selection and speed
  Widget _buildControlsHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        // Rule selector
        Row(
          children: [
            const Text(
              'Rules: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SegmentedButton<RuleType>(
                segments: const [
                  ButtonSegment<RuleType>(
                    value: RuleType.conway,
                    label: Text('Conway (B3/S23)'),
                  ),
                  ButtonSegment<RuleType>(
                    value: RuleType.highLife,
                    label: Text('HighLife (B36/S23)'),
                  ),
                ],
                selected: {_ruleType},
                onSelectionChanged: (Set<RuleType> newSelection) {
                  _changeRule(newSelection.first);
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Speed Slider (1 step/sec on left = Slow, 20 steps/sec on right = Fast)
        Row(
          children: [
            const Icon(Icons.speed, size: 16),
            const SizedBox(width: 6),
            const Text('Speed:', style: TextStyle(fontSize: 12)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: _stepsPerSecond,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  label: '${_stepsPerSecond.round()} steps/s (${_speedMs}ms delay)',
                  onChanged: (value) {
                    setState(() {
                      _stepsPerSecond = value;
                    });
                    if (_isPlaying) {
                      _play(); // restart timer with new speed
                    }
                  },
                ),
              ),
            ),
            Text(
              '${_stepsPerSecond.round()} step/s',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameBoard(ColorScheme colorScheme) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridWidth,
            crossAxisSpacing: 2.0,
            mainAxisSpacing: 2.0,
          ),
          itemCount: gridWidth * gridHeight,
          itemBuilder: (context, index) {
            final x = index % gridWidth;
            final y = index ~/ gridWidth;
            final isAlive = _game.isAliveAt(x, y);

            return GestureDetector(
              key: Key('cell_${x}_$y'),
              onTap: () => _toggleCell(x, y),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isAlive
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(isAlive ? 4.0 : 2.0),
                  boxShadow: isAlive
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: isAlive
                    ? Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  // Game action buttons
  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        // Play / Pause Button
        ElevatedButton.icon(
          key: const Key('play_pause_button'),
          onPressed: _togglePlayPause,
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          label: Text(_isPlaying ? 'Pause' : 'Play'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPlaying ? colorScheme.tertiaryContainer : colorScheme.primaryContainer,
            foregroundColor: _isPlaying ? colorScheme.onTertiaryContainer : colorScheme.onPrimaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),

        // Single Step Button (active when paused)
        OutlinedButton.icon(
          key: const Key('step_button'),
          onPressed: _isPlaying ? null : _stepOnce,
          icon: const Icon(Icons.skip_next),
          label: const Text('Step'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),

        // Reset Button
        OutlinedButton.icon(
          key: const Key('reset_button'),
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),

        // Clear Button
        IconButton.outlined(
          key: const Key('clear_button'),
          onPressed: _clear,
          icon: const Icon(Icons.clear_all),
          tooltip: 'Clear Board',
        ),
      ],
    );
  }

  // Information on how to use the app
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conway's Game of Life"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A cellular automaton simulation created by mathematician John Conway.\n',
            ),
            Text(
              '• Tap any cell to toggle it between alive and dead.\n'
              '• Play / Pause starts and stops auto-advancing generation steps.\n'
              '• Reset generates a new random 20x20 board.\n'
              '• Clear empties the board so you can draw custom patterns.\n'
              '• Switch rules between Conway (B3/S23) and HighLife (B36/S23).',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
