import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core_logic/score_entry.dart';
import 'package:myapp/services/leaderboard_service.dart';
import 'package:myapp/state_management/providers/leaderboard_providers.dart';
import 'package:myapp/state_management/providers/user_providers.dart';

final personalBestScoreProvider = FutureProvider<ScoreEntry?>((ref) async {
  final username = ref.watch(usernameProvider);
  final leaderboardService = ref.watch(leaderboardServiceProvider);

  // Watch leaderboardProvider to re-fetch when leaderboard changes
  ref.watch(leaderboardProvider);

  if (username == null || username.isEmpty) {
    return null;
  }

  return await leaderboardService.getPersonalBestScore(username);
});