import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:myapp/widgets/dice_widget.dart';
import 'package:myapp/widgets/scoreboard_widget.dart';
import 'package:myapp/state_management/providers/game_providers.dart';
import 'package:myapp/generated/app_localizations.dart'; // Import generated localizations from new path
import 'package:myapp/widgets/game_over_dialog.dart'; // Import the GameOverDialog
import 'package:myapp/state_management/providers/leaderboard_providers.dart';
import 'package:myapp/state_management/providers/user_providers.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollsLeft = ref.watch(rollsLeftProvider);
    final currentRound = ref.watch(currentRoundProvider);
    // final grandTotal = ref.watch(grandTotalProvider); // grandTotal will be read inside the listener

    // Listen to game over state to show the dialog
    ref.listen<bool>(isGameOverProvider, (previous, isGameOver) {
      final isGameInProgress = ref.read(isGameInProgressProvider); // Read current state
      if (isGameOver && !isGameInProgress) { // Check if game just ended
        // Ensure dialog is shown only once and after build phase
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Check if the screen is still active before showing dialog or performing async operations
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            final String? actualUsername = await ref.read(usernameProvider.future);
            final leaderboardService = ref.read(leaderboardServiceProvider);
            final grandTotalValue = ref.read(grandTotalProvider); // Read latest grandTotal

            if (actualUsername != null && actualUsername.isNotEmpty) {
              try {
                await leaderboardService.addScore(actualUsername, grandTotalValue);
                ref.refresh(leaderboardProvider);
                // Optional: Show a success message (e.g., SnackBar)
                // if (context.mounted) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text(AppLocalizations.of(context)!.scoreSavedToLeaderboard)),
                //   );
                // }
              } catch (e) {
                print('Error saving score to leaderboard: $e');
                // Optional: Handle error during score saving (e.g., log or show error message)
                // if (context.mounted) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text('${AppLocalizations.of(context)!.failedToSaveScore}: $e')),
                //   );
                // }
              }
            } else {
              print('Username not available, score not saved.');
              // Optional: Handle case where username is somehow null or empty
              // if (context.mounted) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text(AppLocalizations.of(context)!.usernameNotFoundScoreNotSaved)),
              //   );
              // }
            }
            // Show the game over dialog (existing logic)
            if (context.mounted) { // Check mounted again before showing dialog
              showGameOverDialog(context, grandTotalValue);
            }
          }
        });
      }
    });

    // Watch isGameOver for UI elements that depend on it directly
    final bool isGameOverForUI = ref.watch(isGameOverProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.close), // Changed icon to X
            tooltip: AppLocalizations.of(context)!.exitToHome,
            onPressed: () async {
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
                          Navigator.of(dialogContext).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text(MaterialLocalizations.of(context).okButtonLabel),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (shouldExit == true) {
                ref.read(gameStateProvider.notifier).setToInitialState();
                if (context.mounted) context.go('/');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.player("Player 1"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(AppLocalizations.of(context)!.round(currentRound, 13), style: const TextStyle(fontSize: 16)),
                  Text(AppLocalizations.of(context)!.rollsLeft(rollsLeft), style: const TextStyle(fontSize: 16)),
                  if (isGameOverForUI)
                    Text(AppLocalizations.of(context)!.gameOver, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(AppLocalizations.of(context)!.dice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const DiceWidget(),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: rollsLeft > 0 && !isGameOverForUI
                  ? () {
                      ref.read(gameStateProvider.notifier).rollDice();
                    }
                  : null,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(AppLocalizations.of(context)!.rollDice, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            Text(AppLocalizations.of(context)!.scoreboard, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const ScoreboardWidget(),
            const SizedBox(height: 20),

            if (rollsLeft == 0 && !isGameOverForUI)
              ElevatedButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.selectScoreCategoryPrompt)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(context)!.selectScoreCategoryPrompt, style: const TextStyle(fontSize: 18, color: Colors.white)),
              )
          ],
          ),
        ),
      ),
    );
  }
}