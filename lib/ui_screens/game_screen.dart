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
// import 'package:myapp/services/local_storage_service.dart'; // No longer needed, provider is central
import 'package:myapp/services/leaderboard_service.dart'; // Ensure this is imported
import 'package:myapp/state_management/providers/service_providers.dart'; // Import new service providers


class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollsLeft = ref.watch(rollsLeftProvider);
    final currentRound = ref.watch(currentRoundProvider);
    final bool isGameOverForUI = ref.watch(isGameOverProvider); // Watch the game over state for UI updates
    final bool isGameInProgress = ref.watch(isGameInProgressProvider);

    // Robustness check: If game is not in progress and not game over, redirect.
    if (!isGameInProgress && !isGameOverForUI) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invalidGameStateRedirecting), // Assuming this key exists
              backgroundColor: Colors.orange,
            ),
          );
          context.go('/');
        }
      });
      // Return a loading indicator or an empty container while redirecting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Listen to game over state to show the dialog and save score
    ref.listen<bool>(isGameOverProvider, (previous, isGameOver) {
      // Use the already watched isGameInProgress state
      if (isGameOver && !ref.read(isGameInProgressProvider)) { // Check if game just ended
        // Ensure dialog is shown only once and after build phase
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Check if the screen is still active before showing dialog or performing async operations
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            final grandTotalValue = ref.read(grandTotalProvider); // Read latest grandTotal
            final leaderboardService = ref.read(leaderboardServiceProvider);
            final localStorageService = ref.read(localStorageServiceProvider);

            try {
              final String? actualUsername = await ref.read(usernameProvider.future);
              
              if (actualUsername != null && actualUsername.isNotEmpty) {
                try {
                  // Try to save score to leaderboard
                  await leaderboardService.addScore(actualUsername, grandTotalValue);
                  ref.refresh(leaderboardProvider);
                  
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.scoreSavedToLeaderboard),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print('Error saving score to leaderboard: $e');
                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.genericErrorWithDetails(AppLocalizations.of(context)!.failedToSaveScore)),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context)!.fix,
                          onPressed: () {
                            // Potentially navigate to settings or show a dialog to fix username
                            if (context.mounted) context.go('/settings');
                          },
                        ),
                      ),
                    );
                  }
                }
              } else {
                // Username is null or empty, try to use local storage
                try {
                  final localUsername = await localStorageService.getUsername();
                  if (localUsername != null && localUsername.isNotEmpty) {
                    await leaderboardService.addScore(localUsername, grandTotalValue);
                    ref.refresh(leaderboardProvider);
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.scoreSavedUsingLocallyStoredUsername),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text(AppLocalizations.of(context)!.usernameNotFoundScoreNotSaved),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print('Error retrieving or saving score with local username: $e');
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                        content: Text(AppLocalizations.of(context)!.genericErrorWithDetails(AppLocalizations.of(context)!.errorRetrievingUsername('$e'))),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            } catch (e) {
              // This catch block handles errors from ref.read(usernameProvider.future)
              print('Error fetching username: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.genericErrorWithDetails(AppLocalizations.of(context)!.errorFetchingUsername)),
                    backgroundColor: Colors.red,
                     action: SnackBarAction(
                        label: AppLocalizations.of(context)!.fix,
                        onPressed: () {
                          if (context.mounted) context.go('/settings');
                        },
                      ),
                  ),
                );
              }
            }

            // Show game over dialog regardless of score saving outcome
            if (context.mounted) { // Check mounted again before showing dialog
              showGameOverDialog(context, grandTotalValue);
            }
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: AppLocalizations.of(context)!.exitToHome,
            onPressed: () async {
              final bool? shouldExit = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.exitToHome),
                  content: Text(AppLocalizations.of(context)!.exitGameConfirmation),
                  actions: <Widget>[
                    TextButton(
                      child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text(MaterialLocalizations.of(dialogContext).okButtonLabel),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                    ),
                  ],
                ),
              );
              if (shouldExit == true) {
                ref.read(gameStateProvider.notifier).setToInitialState();
                if (context.mounted) context.go('/');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Game info section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.round(currentRound, 13),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.rollsLeft(rollsLeft),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Dice section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dice,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    const DiceWidget(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: rollsLeft > 0 && !isGameOverForUI
                          ? () {
                              ref.read(gameStateProvider.notifier).rollDice();
                            }
                          : null,
                      child: Text(AppLocalizations.of(context)!.rollDice),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Scoreboard section
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        AppLocalizations.of(context)!.scoreboard,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Expanded(
                      child: ScoreboardWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}