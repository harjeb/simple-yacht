import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core_logic/score_entry.dart';
import 'package:myapp/services/leaderboard_service.dart';
import 'package:myapp/services/local_storage_service.dart'; // For potential direct use or for UserService

// Provider for LeaderboardService
final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  // If LocalStorageService itself was a provider, we could watch it here.
  // For now, LeaderboardService instantiates its own or takes one.
  return LeaderboardService(localStorageService: LocalStorageService());
});

// Provider to get the leaderboard list
// Using FutureProvider.autoDispose as leaderboard data is fetched asynchronously
// and can be refreshed.
final leaderboardProvider = FutureProvider.autoDispose<List<ScoreEntry>>((ref) async {
  final leaderboardService = ref.watch(leaderboardServiceProvider);
  return leaderboardService.getLeaderboard();
});

// It might also be useful to have a StateNotifierProvider if we want to
// optimistically update the UI or have more complex state around the leaderboard.
// For now, FutureProvider is simpler for just displaying data.

// Example of how to add a score and refresh the leaderboard:
// final leaderboardService = ref.read(leaderboardServiceProvider);
// await leaderboardService.addScore(username, score);
// ref.refresh(leaderboardProvider);