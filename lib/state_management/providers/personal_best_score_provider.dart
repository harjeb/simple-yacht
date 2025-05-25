import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core_logic/score_entry.dart';
import 'package:myapp/services/leaderboard_service.dart';
import 'package:myapp/state_management/providers/leaderboard_providers.dart';
import 'package:myapp/state_management/providers/user_providers.dart';

final personalBestScoreProvider = FutureProvider<ScoreEntry?>((ref) async {
  // Await the actual username string from the usernameProvider future
  final String? actualUsername = await ref.watch(usernameProvider.future);
  final leaderboardService = ref.watch(leaderboardServiceProvider);

  // Watch leaderboardProvider to re-fetch when leaderboard changes.
  // This ensures that if the leaderboard updates (e.g., new score added),
  // this provider will re-evaluate and potentially fetch an updated personal best.
  ref.watch(leaderboardProvider);

  if (actualUsername == null || actualUsername.isEmpty) {
    return null; // No username, so no personal best score to fetch
  }

  // Now actualUsername is a String, so it can be used directly.
  return await leaderboardService.getPersonalBestScore(actualUsername);
});