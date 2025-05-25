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
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('Error signing in anonymously: $e');
      // Consider using a more robust error handling/logging mechanism
      return null;
    }
  }

  /// Signs in the user with a custom token.
  /// Used for account recovery.
  /// Returns the User object if successful, null otherwise.
  Future<User?> signInWithCustomToken(String token) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCustomToken(token);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with custom token: $e');
      return null;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}