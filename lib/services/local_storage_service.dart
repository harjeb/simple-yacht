import 'dart:convert'; // Required for jsonEncode and jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core_logic/score_entry.dart'; // Import ScoreEntry

class LocalStorageService {
  static const String _leaderboardKey = 'leaderboard';
  static const String _usernameKey = 'username';
  static const String _transferCodeKey = 'transfer_code';
  static const String _uidKey = 'user_uid';
  static const String _gameSettingsKey = 'game_settings';
  static const String _cachedGameStatesKey = 'cached_game_states';
  static const String _eloRatingKey = 'elo_rating'; // ELO rating from productContext

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

  // --- User Specific Personal Best Score Methods ---

  String _getPersonalBestScoreKey(String username) {
    return 'personal_best_score_$username';
  }

  Future<void> saveSpecificUserPersonalBest(String username, ScoreEntry personalBest) async {
    print('LocalStorageService: Attempting to save personal best for username: $username, scoreEntry: ${personalBest.toJson()}');
    final prefs = await SharedPreferences.getInstance();
    final key = _getPersonalBestScoreKey(username);
    final String valueToSave = jsonEncode(personalBest.toJson());
    print('LocalStorageService: Generated key: $key, Value to save: $valueToSave');
    await prefs.setString(key, valueToSave);
    print('LocalStorageService: Successfully saved personal best for $username with key $key.');
  }

  Future<ScoreEntry?> getSpecificUserPersonalBest(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPersonalBestScoreKey(username);
    final String? scoreJson = prefs.getString(key);
    if (scoreJson != null) {
      try {
        return ScoreEntry.fromJson(jsonDecode(scoreJson) as Map<String, dynamic>);
      } catch (e) {
        print('Error deserializing personal best for $username: $e');
        await prefs.remove(key); // Clear corrupted data
        return null;
      }
    }
    return null;
  }

  Future<void> clearSpecificUserPersonalBest(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPersonalBestScoreKey(username);
    await prefs.remove(key);
    print('LocalStorageService: Cleared personal best for $username.');
  }

  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    print('LocalStorageService: Clearing all user-specific data.'); // Log as per pseudocode
    await prefs.remove(_usernameKey);
    await prefs.remove(_leaderboardKey); // This stores a list of general leaderboard, not user-specific bests
    await prefs.remove(_transferCodeKey);
    await prefs.remove(_uidKey);
    await prefs.remove(_gameSettingsKey);
    await prefs.remove(_cachedGameStatesKey);
    await prefs.remove(_eloRatingKey);

    // It's tricky to remove all user-specific personal bests without knowing all usernames
    // If a comprehensive clear is needed, a list of all users who ever logged in would be required,
    // or a different storage strategy for these scores.
    // For now, this method clears general data and known specific keys.
    // If a username is available at the point of calling clearAllUserData,
    // clearSpecificUserPersonalBest(username) should also be called.

    // Add any other user-specific keys here if they are introduced later
    print('LocalStorageService: All user-specific data cleared (excluding dynamically keyed personal bests without username context).');
  }
}