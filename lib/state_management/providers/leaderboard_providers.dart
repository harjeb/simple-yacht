import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core_logic/score_entry.dart';
import 'package:myapp/services/leaderboard_service.dart';
// LocalStorageService is no longer used by LeaderboardService directly.
// import 'package:myapp/services/local_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';   // Import FirebaseAuth
import 'package:myapp/services/auth_service.dart';     // For firebaseAuthProvider (provides FirebaseAuth instance)
import 'package:myapp/services/user_service.dart';     // For firestoreProvider (provides FirebaseFirestore instance)


// Provider for LeaderboardService
final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  final firestore = ref.watch(firestoreProvider); // Get Firestore instance from user_service.dart providers
  final firebaseAuth = ref.watch(firebaseAuthProvider); // Get FirebaseAuth instance from auth_service.dart providers
  return LeaderboardService(firestore: firestore, firebaseAuth: firebaseAuth);
});

// Provider to get the leaderboard list
// Using FutureProvider.autoDispose as leaderboard data is fetched asynchronously
// and can be refreshed.
final leaderboardProvider = FutureProvider.autoDispose<List<ScoreEntry>>((ref) async {
  final leaderboardService = ref.watch(leaderboardServiceProvider);
  return leaderboardService.getLeaderboard(); // Default limit is 10
});

// It might also be useful to have a StateNotifierProvider if we want to
// optimistically update the UI or have more complex state around the leaderboard.
// For now, FutureProvider is simpler for just displaying data.

// Example of how to add a score and refresh the leaderboard:
// final user = ref.read(authStateChangesProvider).asData?.value;
// if (user != null && user.displayName != null) { // Assuming username is stored in displayName or fetched separately
//   final leaderboardService = ref.read(leaderboardServiceProvider);
//   await leaderboardService.addScore(user.displayName!, score);
//   ref.refresh(leaderboardProvider);
// }