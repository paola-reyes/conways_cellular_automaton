import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cellular_automaton_ui/main.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Game of Life UI elements render correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const GameOfLifeApp());

    // Verify title is present
    expect(find.text("Conway's Game of Life"), findsWidgets);

    // Verify GridView with 400 cells (20x20) is rendered
    expect(find.byType(GridView), findsOneWidget);

    // Verify Play and Reset buttons are present
    expect(find.byKey(const Key('play_pause_button')), findsOneWidget);
    expect(find.byKey(const Key('reset_button')), findsOneWidget);
    expect(find.byKey(const Key('step_button')), findsOneWidget);

    // Initially says "Play"
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('Tapping Play toggles to Pause', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const GameOfLifeApp());

    // Tap Play button
    await tester.tap(find.byKey(const Key('play_pause_button')));
    await tester.pump();

    // Button text should now be Pause
    expect(find.text('Pause'), findsOneWidget);

    // Tap Pause button
    await tester.tap(find.byKey(const Key('play_pause_button')));
    await tester.pump();

    // Button text should be Play again
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('Tapping Reset button resets generation to 0', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const GameOfLifeApp());

    // Tap Step button to advance generation
    await tester.tap(find.byKey(const Key('step_button')));
    await tester.pump();

    // Tap Reset button
    await tester.tap(find.byKey(const Key('reset_button')));
    await tester.pump();

    // Generation count should be 0
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('Tapping cell toggles state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const GameOfLifeApp());

    // Clear board first to get a known state (0 population)
    await tester.tap(find.byKey(const Key('clear_button')));
    await tester.pump();

    expect(find.text('Population'), findsOneWidget);
    expect(find.text('0 / 400'), findsOneWidget);

    // Tap the first cell in grid (0,0)
    final cell0 = find.byKey(const Key('cell_0_0'));
    await tester.tap(cell0);
    await tester.pump();

    // Population should now be 1
    expect(find.text('1 / 400'), findsOneWidget);

    // Tap again to toggle back
    await tester.tap(cell0);
    await tester.pump();

    // Population should now be 0 again
    expect(find.text('0 / 400'), findsOneWidget);
  });
}
