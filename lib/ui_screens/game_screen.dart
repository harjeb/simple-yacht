import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:myapp/widgets/dice_widget.dart';
import 'package:myapp/widgets/scoreboard_widget.dart';
import 'package:myapp/state_management/providers/game_providers.dart';
import 'package:myapp/generated/app_localizations.dart'; // Import generated localizations from new path

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final diceValues = ref.watch(diceValuesProvider); // No longer needed here as DiceWidget handles it
    // final heldDice = ref.watch(heldDiceProvider); // No longer needed here
    final rollsLeft = ref.watch(rollsLeftProvider);
    final currentRound = ref.watch(currentRoundProvider);
    final isGameOver = ref.watch(isGameOverProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.close), // Changed icon to X
            tooltip: AppLocalizations.of(context)!.exitToHome,
            onPressed: () async { // Added async
              final bool? shouldExit = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.exitToHome),
                    content: Text(AppLocalizations.of(context)!.exitGameConfirmation),
                    actions: <Widget>[
                      TextButton(
                        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false); // Dismiss dialog and return false
                        },
                      ),
                      TextButton(
                        child: Text(MaterialLocalizations.of(context).okButtonLabel),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true); // Dismiss dialog and return true
                        },
                      ),
                    ],
                  );
                },
              );

              if (shouldExit == true) {
                // User confirmed exit
                ref.read(gameStateProvider.notifier).setToInitialState(); // Changed to setToInitialState
                if (context.mounted) context.go('/');
              }
            },
          ),
        ],
      ),
      body: SafeArea( // Added SafeArea to prevent overlap with system UI
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Placeholder for Game Info (Current Player, Round, Rolls Left)
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.player("Player 1"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Mock player
                  Text(AppLocalizations.of(context)!.round(currentRound, 13), style: const TextStyle(fontSize: 16)),
                  Text(AppLocalizations.of(context)!.rollsLeft(rollsLeft), style: const TextStyle(fontSize: 16)),
                  if (isGameOver)
                    Text(AppLocalizations.of(context)!.gameOver, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dice Area
            Text(AppLocalizations.of(context)!.dice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const DiceWidget(), // Removed parameters as DiceWidget now uses providers
            const SizedBox(height: 20),

            // Roll Dice Button
            ElevatedButton(
              onPressed: rollsLeft > 0 && !isGameOver
                  ? () {
                      ref.read(gameStateProvider.notifier).rollDice();
                    }
                  : null, // Disable if no rolls left or game over
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(AppLocalizations.of(context)!.rollDice, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Scoreboard Area
            Text(AppLocalizations.of(context)!.scoreboard, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const ScoreboardWidget(), // Will be updated to use providers
            const SizedBox(height: 20),

            // Reset Game Button (for testing)
            if (isGameOver)
              ElevatedButton(
                onPressed: () {
                  ref.read(gameStateProvider.notifier).resetGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(context)!.resetGame, style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            // Placeholder for "Next Turn" or "Submit Score" button
            // This will be more complex depending on game flow (e.g., after 3 rolls or score selection)
            // For now, if rolls are 0 and game not over, show a "Next Turn" button if no category selected yet
            if (rollsLeft == 0 && !isGameOver)
              ElevatedButton(
                onPressed: () {
                  // This button should ideally only appear after a score category is selected.
                  // For now, it just advances the turn.
                  // A more robust implementation would involve checking if a score was selected for the current turn.
                  ref.read(gameStateProvider.notifier).nextTurn();
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.selectScoreCategoryPrompt)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(context)!.nextTurn, style: const TextStyle(fontSize: 18, color: Colors.white)),
              )
          ],
          ),
        ),
      ),
    );
  }
}