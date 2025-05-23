import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added for Riverpod
import 'package:myapp/services/local_storage_service.dart'; // Added for high score
import 'package:myapp/generated/app_localizations.dart'; // Import generated localizations from new path
import 'package:myapp/state_management/providers/game_providers.dart'; // Added for game providers

class HomeScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState(); // Changed to ConsumerState
}

class _HomeScreenState extends ConsumerState<HomeScreen> { // Changed to ConsumerState
  int _highScore = 0;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final score = await _localStorageService.getHighScore();
    if (mounted) {
      setState(() {
        _highScore = score;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGameInProgress = ref.watch(isGameInProgressProvider); // Watch the provider
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              localizations.personalBest(_highScore),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (!isGameInProgress) {
                  // If no game is in progress, reset the game state before navigating
                  ref.read(gameStateProvider.notifier).resetGame();
                }
                context.push('/game').then((_) => _loadHighScore());
              },
              child: Text(isGameInProgress ? localizations.continueGame : localizations.startGame),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for leaderboard navigation
                // context.go('/leaderboard');
              },
              child: Text(AppLocalizations.of(context)!.leaderboardComingSoon),
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
    );
  }
}