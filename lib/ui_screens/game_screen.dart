import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:myapp/widgets/dice_widget.dart';
import 'package:myapp/widgets/scoreboard_widget.dart';
import 'package:myapp/state_management/providers/game_providers.dart';
import 'package:myapp/generated/app_localizations.dart'; // Import generated localizations from new path
import 'package:myapp/widgets/game_over_dialog.dart'; // Import the GameOverDialog
// ADD: import 'package:myapp/state_management/providers/leaderboard_providers.dart';
// ADD: import 'package:myapp/state_management/providers/user_providers.dart';
import 'package:myapp/state_management/providers/leaderboard_providers.dart';
import 'package:myapp/state_management/providers/user_providers.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollsLeft = ref.watch(rollsLeftProvider);
    final currentRound = ref.watch(currentRoundProvider);
    final grandTotal = ref.watch(grandTotalProvider); // Get grand total for the dialog

    // Listen to game over state to show the dialog
    ref.listen<bool>(isGameOverProvider, (previous, isGameOver) {
      final isGameInProgress = ref.read(isGameInProgressProvider);
      if (isGameOver && !isGameInProgress) {
        // Ensure dialog is shown only once and after build phase
        WidgetsBinding.instance.addPostFrameCallback((_) async { // ADD async
          if (ModalRoute.of(context)?.isCurrent ?? false) { // Check if the screen is still active
            // --- BEGIN MODIFICATION ---
            // 1. Get current username
            final username = ref.read(usernameProvider); // From user_providers.dart
            
            // 2. Get LeaderboardService instance
            final leaderboardService = ref.read(leaderboardServiceProvider); // From leaderboard_providers.dart

            // 3. Check if username is available (it should be, due to mandatory setup)
            if (username != null && username.isNotEmpty) {
              // 4. Add score to leaderboard
              //    grandTotal is already available in this scope
              try {
                await leaderboardService.addScore(username, grandTotal);
                // 5. Refresh leaderboard data so UI updates if user navigates there
                ref.refresh(leaderboardProvider);
                // Optional: Show a success message (e.g., SnackBar)
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Score saved to leaderboard!')),
                // );
              } catch (e) {
                // Optional: Handle error during score saving (e.g., log or show error message)
                print('Error saving score to leaderboard: $e');
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Failed to save score: $e')),
                // );
              }
            } else {
              // Optional: Handle case where username is somehow null or empty
              // This shouldn't happen if username setup is enforced correctly.
              print('Username not available, score not saved.');
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Username not found. Score not saved.')),
              // );
            }
            // --- END MODIFICATION ---

            // Show the game over dialog (existing logic)
            showGameOverDialog(context, grandTotal);
          }
        });
      }
    });

    // Watch isGameOver for UI elements that depend on it directly
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

            // Reset Game Button (for testing) - REMOVED as GameOverDialog handles reset
            // Placeholder for "Next Turn" or "Submit Score" button
            // This will be more complex depending on game flow (e.g., after 3 rolls or score selection)
            // For now, if rolls are 0 and game not over, show a "Next Turn" button if no category selected yet
            if (rollsLeft == 0 && !isGameOver)
              ElevatedButton(
                onPressed: () {
                  // This button should ideally only appear after a score category is selected.
                  // For now, it just advances the turn.
                  // A more robust implementation would involve checking if a score was selected for the current turn.
                  // Consider if nextTurn() is still the right action or if it should be tied to score selection.
                  // For now, we assume a score must be selected to advance.
                  // If no score is selected, this button might be confusing.
                  // The ScoreboardWidget handles advancing the turn upon score selection.
                  // This button might be redundant if the user MUST select a score.
                  // Let's keep it for now but add a prompt if it's clicked without a score being ready.
                  // Actually, the ScoreboardWidget's onTap for a category calls assignScore,
                  // which then calls nextTurn or handles game over. So this button is likely not needed
                  // if the user understands they must click a score category.
                  // Removing this button to simplify flow, user must select a score.
                  // If they don't, they can re-roll (if rolls left) or are stuck.
                  // This matches Yahtzee flow better.
                  // ref.read(gameStateProvider.notifier).nextTurn();
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.selectScoreCategoryPrompt)), // Use existing prompt
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(context)!.selectScoreCategoryPrompt, style: const TextStyle(fontSize: 18, color: Colors.white)), // Use existing prompt
              )
          ],
          ),
        ),
      ),
    );
  }
}