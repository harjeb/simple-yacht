import 'package:myapp/core_logic/score_entry.dart';
import 'package:myapp/services/local_storage_service.dart';

class LeaderboardService {
  final LocalStorageService _localStorageService;

  LeaderboardService({LocalStorageService? localStorageService})
      : _localStorageService = localStorageService ?? LocalStorageService();

  Future<List<ScoreEntry>> getLeaderboard() async {
    return await _localStorageService.getLeaderboard();
  }

  Future<void> addScore(String username, int score) async {
    if (username.isEmpty) {
      // Optionally handle empty username, e.g., assign a default or skip
      print("Username is empty, score not added to leaderboard.");
      return;
    }

    final newEntry = ScoreEntry(
      username: username,
      score: score,
      timestamp: DateTime.now(),
    );

    List<ScoreEntry> leaderboard = await getLeaderboard();
    leaderboard.add(newEntry);

    // Sort by score descending, then by timestamp ascending (for tie-breaking)
    leaderboard.sort((a, b) {
      int scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return a.timestamp.compareTo(b.timestamp); // Older scores first in case of tie
    });

    // Keep only top 10
    if (leaderboard.length > 10) {
      leaderboard = leaderboard.sublist(0, 10);
    }

    await _localStorageService.saveLeaderboard(leaderboard);
  }

  Future<ScoreEntry?> getPersonalBestScore(String username) async {
    if (username.isEmpty) {
      return null;
    }
    final leaderboard = await getLeaderboard();
    ScoreEntry? personalBest;
    for (final entry in leaderboard) {
      if (entry.username == username) {
        if (personalBest == null || entry.score > personalBest.score) {
          personalBest = entry;
        } else if (entry.score == personalBest.score && entry.timestamp.isBefore(personalBest.timestamp)) {
          // If scores are tied, prefer the older entry
          personalBest = entry;
        }
      }
    }
    return personalBest;
  }

  // Optional: Method to clear the leaderboard for testing or reset
  Future<void> clearLeaderboard() async {
    await _localStorageService.saveLeaderboard([]);
  }
}