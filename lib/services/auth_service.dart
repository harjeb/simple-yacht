import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

// Provider to get the current Firebase user
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in the user anonymously.
  /// Returns the User object if successful, null otherwise.
  Future<User?> signInAnonymously() async {
    developer.log('Attempting anonymous sign-in...', name: 'AuthService.signInAnonymously');
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      developer.log('Anonymous sign-in successful. User UID: ${userCredential.user?.uid}', name: 'AuthService.signInAnonymously');
      return userCredential.user;
    } catch (e) {
      developer.log('Error signing in anonymously: $e', name: 'AuthService.signInAnonymously', error: e);
      // Consider using a more robust error handling/logging mechanism
      return null;
    }
  }

  /// Signs in the user with a custom token.
  /// Used for account recovery.
  /// Returns the User object if successful, null otherwise.
  Future<User?> signInWithCustomToken(String token) async {
    developer.log('Attempting sign-in with custom token...', name: 'AuthService.signInWithCustomToken');
    try {
      final userCredential = await _firebaseAuth.signInWithCustomToken(token);
      developer.log('Sign-in with custom token successful. User UID: ${userCredential.user?.uid}', name: 'AuthService.signInWithCustomToken');
      return userCredential.user;
    } catch (e) {
      developer.log('Error signing in with custom token: $e', name: 'AuthService.signInWithCustomToken', error: e);
      return null;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    developer.log('Attempting sign-out...', name: 'AuthService.signOut');
    try {
      await _firebaseAuth.signOut();
      developer.log('Sign-out successful.', name: 'AuthService.signOut');
    } catch (e) {
      developer.log('Error signing out: $e', name: 'AuthService.signOut', error: e);
    }
  }
}