import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/services/auth_service.dart'; // For authStateChangesProvider
import 'package:myapp/services/user_service.dart'; // For userAccountServiceProvider and UserProfile
// LocalStorageService might still be used for other settings, but not primarily for username from Firebase.
// import 'package:myapp/services/local_storage_service.dart';

// Provider for LocalStorageService (if still needed for other purposes)
// final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
//   return LocalStorageService();
// });

// Provider for the current username string, fetched asynchronously from Firestore.
// Returns null if no user is signed in or if the user profile/username doesn't exist.
final usernameProvider = FutureProvider<String?>((ref) async {
  final firebaseUser = ref.watch(authStateChangesProvider).asData?.value;
  
  if (firebaseUser == null) {
    return null; // No user signed in
  }

  final userAccountService = ref.watch(userAccountServiceProvider);
  final userProfile = await userAccountService.getUserProfile(firebaseUser.uid);
  
  return userProfile?.username;
});

// Provider to check if a username has been set and fetched.
// This provides a synchronous boolean based on the async usernameProvider result.
final hasUsernameProvider = Provider<bool>((ref) {
  // Watch the usernameProvider's state
  final usernameAsyncValue = ref.watch(usernameProvider);
  // Return true if data is available and username is not null and not empty
  return usernameAsyncValue.when(
    data: (username) => username != null && username.isNotEmpty,
    loading: () => false, // Or true if you want to consider "loading" as "potentially has username"
    error: (_, __) => false,
  );
});

// Provider for the current UserProfile object, fetched asynchronously.
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final firebaseUser = ref.watch(authStateChangesProvider).asData?.value;
  if (firebaseUser == null) {
    return null;
  }
  final userAccountService = ref.watch(userAccountServiceProvider);
  return await userAccountService.getUserProfile(firebaseUser.uid);
});

// Example of how to create/update a user profile (e.g., after initial username setup):
// final userAccountService = ref.read(userAccountServiceProvider);
// final firebaseUser = ref.read(authStateChangesProvider).asData?.value;
// if (firebaseUser != null) {
//   await userAccountService.createNewUser(userId: firebaseUser.uid, username: "NewUser");
//   ref.refresh(usernameProvider); // Refresh to get the new username
//   ref.refresh(userProfileProvider); // Refresh to get the new profile
// }

// Example of how to get the transfer code:
// final profile = await ref.read(userProfileProvider.future);
// final transferCode = profile?.transferCode;