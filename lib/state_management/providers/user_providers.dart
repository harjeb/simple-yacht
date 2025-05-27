import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For FirebaseException
import 'package:myapp/services/auth_service.dart'; // For authStateChangesProvider
import 'package:myapp/services/user_service.dart'; // For userAccountServiceProvider and UserProfile
// LocalStorageService is now used as a fallback for username when Firebase fails
// import 'package:myapp/services/local_storage_service.dart'; // No longer needed here
import 'package:myapp/state_management/providers/service_providers.dart'; // Import new service providers

// Provider for LocalStorageService - MOVED to service_providers.dart


final anonymousSignInNotifierProvider = ChangeNotifierProvider<AnonymousSignInNotifier>((ref) {
  // authServiceProvider is now from service_providers.dart
  return AnonymousSignInNotifier(ref.watch(authServiceProvider), ref.watch(userAccountServiceProvider));
});

class AnonymousSignInNotifier extends ChangeNotifier {
  final AuthService _authService;
  final UserAccountService _userAccountService;

  AnonymousSignInNotifier(this._authService, this._userAccountService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> attemptAnonymousSignIn() async {
    developer.log('Attempting anonymous sign-in...', name: 'AnonymousSignInNotifier.attemptAnonymousSignIn');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInAnonymously();
      if (_currentUser == null) {
        _errorMessage = "Anonymous sign-in failed. User is null.";
        developer.log(_errorMessage!, name: 'AnonymousSignInNotifier.attemptAnonymousSignIn');
      } else {
        developer.log('Anonymous sign-in successful. User UID: ${_currentUser!.uid}', name: 'AnonymousSignInNotifier.attemptAnonymousSignIn');
        // After successful anonymous sign-in, try to get user profile to check Firestore status
        try {
          // This call might throw if Firestore is not set up
          await _userAccountService.getUserProfile(_currentUser!.uid);
          developer.log('User profile check successful after anonymous sign-in.', name: 'AnonymousSignInNotifier.attemptAnonymousSignIn');
        } on FirebaseException catch (fe) {
          if (fe.code == 'not-found') {
            _errorMessage = "Backend database not configured. Please contact administrator."; // Specific error message
            developer.log(_errorMessage!, name: 'AnonymousSignInNotifier.attemptAnonymousSignIn', error: fe);
            _currentUser = null; // Effectively treat this as a sign-in failure for UI purposes
          } else {
            _errorMessage = "Error checking user profile: ${fe.toString()}";
            developer.log(_errorMessage!, name: 'AnonymousSignInNotifier.attemptAnonymousSignIn', error: fe);
             _currentUser = null;
          }
        } catch (e) {
           _errorMessage = "Unexpected error checking user profile: ${e.toString()}";
           developer.log(_errorMessage!, name: 'AnonymousSignInNotifier.attemptAnonymousSignIn', error: e);
           _currentUser = null;
        }
      }
    } on FirebaseException catch (e) { // Catch FirebaseException from signInAnonymously or getUserProfile
      if (e.code == 'not-found') {
         _errorMessage = "Backend database not configured. Please contact administrator.";
      } else {
        _errorMessage = "Error during sign-in process: ${e.toString()}";
      }
      developer.log(_errorMessage!, name: 'AnonymousSignInNotifier.attemptAnonymousSignIn', error: e);
      _currentUser = null; // Ensure currentUser is null on error
    }
    catch (e) { // Catch other general exceptions
      _errorMessage = "Error during sign-in process: ${e.toString()}";
      developer.log(_errorMessage!, name: 'AnonymousSignInNotifier.attemptAnonymousSignIn', error: e);
      _currentUser = null; // Ensure currentUser is null on error
    }
    finally {
      _isLoading = false;
      developer.log('Finished attemptAnonymousSignIn. isLoading: $_isLoading, User: ${_currentUser?.uid}, Error: $_errorMessage', name: 'AnonymousSignInNotifier.attemptAnonymousSignIn');
      notifyListeners();
    }
  }
}


// Provider for the current username string, fetched asynchronously from Firestore.
// Falls back to local storage if Firebase fails.
final usernameProvider = FutureProvider<String?>((ref) async {
  final firebaseUser = ref.watch(authStateChangesProvider).asData?.value;
  
  if (firebaseUser == null) {
    return null; // No user signed in
  }

  // Try to get username from Firebase first
  try {
    final userAccountService = ref.watch(userAccountServiceProvider);
    final userProfile = await userAccountService.getUserProfile(firebaseUser.uid);
    
    if (userProfile?.username != null && userProfile!.username.isNotEmpty) {
      developer.log('Username retrieved from Firebase: ${userProfile.username}',
                    name: 'usernameProvider');
      return userProfile.username;
    }
  } catch (e) {
    developer.log('Error getting username from Firebase: $e',
                  name: 'usernameProvider');
    // Continue to fallback if Firebase fails
  }
  
  // Fallback to local storage if Firebase failed or returned empty username
  try {
    final localStorageService = ref.watch(localStorageServiceProvider);
    final localUsername = await localStorageService.getUsername();
    
    if (localUsername != null && localUsername.isNotEmpty) {
      developer.log('Username retrieved from local storage: $localUsername',
                    name: 'usernameProvider');
      return localUsername;
    }
  } catch (e) {
    developer.log('Error getting username from local storage: $e',
                  name: 'usernameProvider');
  }
  
  developer.log('No username found in Firebase or local storage',
                name: 'usernameProvider');
  return null; // No username found in either location
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