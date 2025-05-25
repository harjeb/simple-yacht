import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core_logic/score_entry.dart';
// LocalStorageService is no longer a direct dependency for core leaderboard functions.

class LeaderboardService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  // Define a constant for the leaderboard collection path for clarity
  static const String _leaderboardCollectionPath = 'leaderboards';
  static const String _globalLeaderboardDocId = 'global'; // Example ID for a single global leaderboard
  static const String _scoresSubcollectionPath = 'scores';
  static const String _usersCollectionPath = 'users';


  LeaderboardService({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

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

  /// Fetches the personal best score for the given username from their user document.
  /// Note: This assumes the username corresponds to the currently authenticated user's profile
  /// or that UserAccountService handles updating this field correctly.
  /// For a more direct approach, this method could take a userId.
  Future<ScoreEntry?> getPersonalBestScore(String username) async {
    // This implementation now relies on the personal best being stored in the user's document.
    // The `username` parameter is a bit indirect here if we fetch by current user's UID.
    // If the intent is to fetch for *any* username, this needs a query on the `users` collection by username,
    // which requires an index and might not be unique if usernames aren't enforced as unique.
    // For simplicity and alignment with how `personal_best_score_provider` uses it,
    // we'll assume it's for the *currently authenticated user* if their profile username matches.
    
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final userDoc = await _usersCollection.doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final profileUsername = data?['username'] as String?;
        
        // Ensure the username matches if we are strictly using the passed 'username' parameter
        // or simply fetch the current user's best score.
        // For now, let's assume the provider passes the correct username for the current auth user.
        if (profileUsername == username) {
          final bestScore = data?['gameData']?['personalBestScore'] as int?;
          final timestamp = data?['gameData']?['personalBestScoreTimestamp'] as Timestamp?;
          if (bestScore != null && timestamp != null) {
            return ScoreEntry(
              username: username,
              score: bestScore,
              timestamp: timestamp.toDate(),
            );
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting personal best score from Firestore user document: $e');
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