import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_yacht/core_logic/score_entry.dart';
import 'package:simple_yacht/services/local_storage_service.dart'; // Import LocalStorageService

class LeaderboardService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final LocalStorageService _localStorageService; // Add LocalStorageService

  // Define a constant for the leaderboard collection path for clarity
  static const String _leaderboardCollectionPath = 'leaderboards';
  static const String _globalLeaderboardDocId = 'global'; // Example ID for a single global leaderboard
  static const String _scoresSubcollectionPath = 'scores';
  static const String _usersCollectionPath = 'users';


  LeaderboardService({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
    required LocalStorageService localStorageService, // Add to constructor
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth,
        _localStorageService = localStorageService; // Initialize LocalStorageService

  CollectionReference<Map<String, dynamic>> get _globalScoresCollection =>
      _firestore
          .collection(_leaderboardCollectionPath)
          .doc(_globalLeaderboardDocId)
          .collection(_scoresSubcollectionPath);
  
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(_usersCollectionPath);


  Future<List<ScoreEntry>> getLeaderboard({int limit = 10}) async {
    try {
      final querySnapshot = await _globalScoresCollection
          .orderBy('score', descending: true)
          .orderBy('timestamp', descending: false) // Tie-breaking: older score first (ascending)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ScoreEntry(
          // docId: doc.id, // Optional: if ScoreEntry model is updated
          username: data['username'] as String,
          score: data['score'] as int,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          // userId: data['userId'] as String?, // Optional: if ScoreEntry model is updated
        );
      }).toList();
    } catch (e) {
      print('Error getting leaderboard from Firestore: $e');
      return []; // Return empty list on error
    }
  }

  Future<void> addScore(String username, int score) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      print("User not authenticated. Score not added.");
      // Optionally, you could allow adding scores without a UID if the design permits,
      // but linking to a UID is generally better for user-specific features.
      return;
    }

    if (username.isEmpty) {
      print("Username is empty, score not added to leaderboard.");
      return;
    }

    try {
      await _globalScoresCollection.add({
        'userId': user.uid,
        'username': username,
        'score': score,
        'timestamp': Timestamp.now(),
      });

      // Also update the user's personal best score in their user document
      final userDocRef = _usersCollection.doc(user.uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final currentPersonalBest = userData?['gameData']?['personalBestScore'] as int? ?? 0;
        if (score > currentPersonalBest) {
          await userDocRef.set({
            'gameData': {
              'personalBestScore': score,
              'personalBestScoreTimestamp': Timestamp.now(),
            }
          }, SetOptions(merge: true)); // Merge to not overwrite other gameData or user fields
        }
      } else {
        // This case might happen if the user document wasn't created yet,
        // though typically it should be created upon username setup.
        // For robustness, create it or log an error.
        print("User document for ${user.uid} not found when trying to update personal best.");
      }

    } catch (e) {
      print('Error adding score to Firestore: $e');
    }
  }

  /// Fetches the personal best score for the given username from local storage.
  Future<ScoreEntry?> getPersonalBestScore(String username) async {
    if (username.isEmpty) {
      print('LeaderboardService: Username is empty, cannot fetch personal best score.');
      return null;
    }
    try {
      // Primary source for personal best score is now local storage after account recovery
      final localBestScore = await _localStorageService.getSpecificUserPersonalBest(username);
      if (localBestScore != null) {
        print('LeaderboardService: Fetched personal best for $username from local storage: ${localBestScore.score}');
        return localBestScore;
      } else {
        print('LeaderboardService: No personal best found in local storage for $username. Falling back to Firestore (if implemented).');
        // Fallback: Optionally, try fetching from Firestore if not found locally.
        // This part can be added if a sync mechanism is desired.
        // For now, strictly adhere to reading what was saved locally during recovery.
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          final userDoc = await _usersCollection.doc(user.uid).get();
          if (userDoc.exists) {
            final data = userDoc.data();
            final profileUsername = data?['username'] as String?;
            if (profileUsername == username) { // Ensure it's the correct user
              final gameData = data?['gameData'] as Map<String, dynamic>?;
              final bestScoreData = gameData?['personalBestScore']; // This could be a map or a direct value
              
              if (bestScoreData is Map) { // If personalBestScore is a ScoreEntry like structure
                final scoreValue = bestScoreData['score'] as int?;
                final timestampValue = bestScoreData['timestamp'] as Timestamp?;
                 if (scoreValue != null && timestampValue != null) {
                  print('LeaderboardService: Fetched personal best for $username from Firestore: $scoreValue');
                  return ScoreEntry(
                    username: username,
                    score: scoreValue,
                    timestamp: timestampValue.toDate(),
                  );
                }
              } else if (bestScoreData is int) { // If it's just an int (old format perhaps)
                 final timestampValue = gameData?['personalBestScoreTimestamp'] as Timestamp?;
                 if (timestampValue != null) {
                    print('LeaderboardService: Fetched personal best (int) for $username from Firestore: $bestScoreData');
                    return ScoreEntry(
                      username: username,
                      score: bestScoreData,
                      timestamp: timestampValue.toDate(),
                    );
                 }
              }
            }
          }
        }
        return null; // Not found in local storage or Firestore fallback
      }
    } catch (e) {
      print('LeaderboardService: Error getting personal best score for $username: $e');
      return null;
    }
  }

  // Optional: Method to clear the leaderboard for testing or reset
  // This would require more complex logic to delete all documents in the subcollection.
  // Future<void> clearLeaderboard() async {
  //   final snapshot = await _globalScoresCollection.get();
  //   final WriteBatch batch = _firestore.batch();
  //   for (DocumentSnapshot ds in snapshot.docs){
  //     batch.delete(ds.reference);
  //   }
  //   await batch.commit();
  // }
}