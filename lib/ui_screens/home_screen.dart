import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added for Riverpod
import 'package:myapp/generated/app_localizations.dart'; // Import generated localizations from new path
import 'package:myapp/state_management/providers/game_providers.dart'; // Added for game providers
import 'package:myapp/state_management/providers/user_providers.dart'; // Added for user providers
import 'package:myapp/state_management/providers/personal_best_score_provider.dart'; // Added for personal best score
import 'package:myapp/core_logic/game_state.dart'; // Added for GameState class
import 'package:intl/intl.dart'; // Added for date formatting

class HomeScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState(); // Changed to ConsumerState
}

class _HomeScreenState extends ConsumerState<HomeScreen> { // Changed to ConsumerState
  // int _highScore = 0; // Removed
  // final LocalStorageService _localStorageService = LocalStorageService(); // Removed

  @override
  void initState() {
    super.initState();
    // _loadHighScore(); // Removed
  }

  // Future<void> _loadHighScore() async { // Removed
  //   final score = await _localStorageService.getHighScore();
  //   if (mounted) {
  //     setState(() {
  //       _highScore = score;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final GameState gameState = ref.watch(gameStateProvider);
    // Corrected logic for canContinueGame:
    // Game is in progress AND (it's past round 1 OR (it's round 1 AND rolls are left < initial rolls OR a score has been made))
    final bool canContinueGame = gameState.isGameInProgress &&
        (gameState.currentRound > 1 ||
            (gameState.currentRound == 1 && gameState.rollsLeft < 2) || // Max rolls is 2 after initial auto-roll (3 total, 1 auto, 2 manual)
            gameState.scores.values.any((score) => score != null));

    final usernameAsyncValue = ref.watch(usernameProvider); // Changed to use usernameProvider
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle), // Use appTitle as homeScreenTitle is not defined
        actions: [
          // Potentially other actions
        ],
      ),
      body: Stack( // Use Stack to overlay username in the top-right corner
        children: [
          // -- Main content of the home screen --
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  localizations.highScoreDisplay,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            // Display Personal Best Score
            Consumer(
              builder: (context, ref, child) {
                final personalBestAsync = ref.watch(personalBestScoreProvider);
                return personalBestAsync.when(
                  data: (scoreEntry) {
                    if (scoreEntry == null) {
                      return Text(localizations.noPersonalBestScore);
                    }
                    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(scoreEntry.timestamp);
                    return Column(
                      children: [
                        Text(localizations.yourPersonalBestScoreLabel, style: Theme.of(context).textTheme.titleMedium),
                        Text('${localizations.scoreLabel}: ${scoreEntry.score}', style: Theme.of(context).textTheme.titleLarge),
                        Text('${localizations.dateTimeLabel}: $formattedDate'),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Error: $err'),
                );
              },
            ),
            const SizedBox(height: 30),
            if (canContinueGame) ...[
              ElevatedButton(
                onPressed: () {
                  context.push('/game');
                },
                child: Text(localizations.continueGame),
              ),
              const SizedBox(height: 10), // Spacing between buttons
            ],
            ElevatedButton(
              onPressed: () {
                // Always reset game if starting a new one, regardless of current game state
                ref.read(gameStateProvider.notifier).resetGame();
                context.push('/game');
              },
              child: Text(localizations.startGame), // Text is now always "Start Game" or "New Game"
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/leaderboard'); // Navigate to leaderboard screen
              },
              child: Text(localizations.leaderboard), // Use existing "leaderboard" localization
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for settings navigation
                context.go('/settings'); // Enabled navigation to settings
              },
              child: Text(AppLocalizations.of(context)!.settings), // Changed from settingsComingSoon to settings
            ),
          ],
        ),
          ),
          // -- Username Display in Top-Right Corner --
          Positioned(
            top: 8.0, // Adjust spacing as needed
            right: 8.0, // Adjust spacing as needed
            child: usernameAsyncValue.when(
              data: (username) {
                if (username != null && username.isNotEmpty) {
                  return Chip( // Using a Chip for a slightly styled display
                    avatar: Icon(Icons.person),
                    label: Text(username),
                  );
                } else {
                  // Handle case where username is null or empty after loading
                  // This might indicate an issue or a state where username is not set
                  return SizedBox.shrink(); // Or a placeholder
                }
              },
              loading: () => Padding( // Optional: Show a small loading indicator
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.0)
                ),
              ),
              error: (error, stackTrace) => Tooltip( // Optional: Show an error icon
                message: 'Error loading username', // Consider localizing this
                child: Icon(Icons.error_outline, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}