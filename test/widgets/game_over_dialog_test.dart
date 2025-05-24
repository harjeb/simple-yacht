import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/state_management/providers/game_providers.dart';
import 'package:myapp/widgets/game_over_dialog.dart';

// Mock GameStateNotifier for testing
class MockGameStateNotifier extends Mock implements GameStateNotifier {}

@GenerateMocks([MockGameStateNotifier])
void main() {
  late MockGameStateNotifier mockGameStateNotifier;

  setUp(() {
    mockGameStateNotifier = MockGameStateNotifier();
  });

  // Helper function to pump the widget with necessary providers
  Future<void> pumpGameOverDialog(WidgetTester tester, int score) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateProvider.overrideWith((ref) => mockGameStateNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                // Using a Builder to get a context with a Navigator
                return ElevatedButton(
                  onPressed: () {
                    showGameOverDialog(context, score);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle(); // Wait for dialog to appear and animations to finish
  }

  testWidgets('GameOverDialog displays correct score and texts', (WidgetTester tester) async {
    const testScore = 100;
    await pumpGameOverDialog(tester, testScore);

    // Verify title
    expect(find.text('游戏结束!'), findsOneWidget);

    // Verify congratulatory message
    expect(find.text('🎉 恭喜你完成了游戏! 🎉'), findsOneWidget);

    // Verify score message
    expect(find.text('你的最终得分是:'), findsOneWidget);
    expect(find.text('$testScore'), findsOneWidget);

    // Verify reset button text
    expect(find.text('重新开始'), findsOneWidget);
  });

  testWidgets('GameOverDialog calls resetGame and pops when "重新开始" is tapped', (WidgetTester tester) async {
    const testScore = 150;
    await pumpGameOverDialog(tester, testScore);

    // Verify the dialog is present
    expect(find.byType(AlertDialog), findsOneWidget);

    // Tap the reset button
    await tester.tap(find.text('重新开始'));
    await tester.pumpAndSettle(); // Wait for pop animation

    // Verify resetGame was called on the notifier
    verify(mockGameStateNotifier.resetGame()).called(1);

    // Verify the dialog is dismissed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('GameOverDialog is displayed by showGameOverDialog helper', (WidgetTester tester) async {
    const testScore = 75;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateProvider.overrideWith((ref) => mockGameStateNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showGameOverDialog(context, testScore),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('游戏结束!'), findsOneWidget);
    expect(find.text('$testScore'), findsOneWidget);
    expect(find.text('重新开始'), findsOneWidget);
  });
}