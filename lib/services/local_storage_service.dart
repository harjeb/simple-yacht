import 'dart:convert'; // Required for jsonEncode and jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core_logic/score_entry.dart'; // Import ScoreEntry

class LocalStorageService {
  static const String _leaderboardKey = 'leaderboard';
  static const String _usernameKey = 'username';

  // --- Leaderboard Methods ---

  Future<void> saveLeaderboard(List<ScoreEntry> leaderboard) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> leaderboardJson = leaderboard.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(_leaderboardKey, leaderboardJson);
  }

  Future<List<ScoreEntry>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? leaderboardJson = prefs.getStringList(_leaderboardKey);
    if (leaderboardJson == null || leaderboardJson.isEmpty) {
      return [];
    }
    try {
      return leaderboardJson.map((entryJson) => ScoreEntry.fromJson(jsonDecode(entryJson) as Map<String, dynamic>)).toList();
    } catch (e) {
      // Handle potential errors during deserialization, e.g., corrupted data
      print('Error deserializing leaderboard: $e');
      return [];
    }
  }

  // --- Username Methods ---

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_leaderboardKey);
    // Add any other user-specific keys here if they exist
  }
}