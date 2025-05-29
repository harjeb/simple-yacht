import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Assuming you have a way to provide FirebaseAuth instance, e.g., via another provider
// For this example, let's assume firebaseAuthProvider exists.
// final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

class PresenceService {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;
  User? _currentUser;
  StreamSubscription? _authSubscription;
  DatabaseReference? _userStatusRef;
  DatabaseReference? _onlineCountRef;

  PresenceService(this._auth, this._database) {
    _onlineCountRef = _database.ref('online_users_count');
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
    // Initialize with current user if already logged in
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _userStatusRef = _database.ref('online_users/${_currentUser!.uid}');
      _goOnline();
    }
  }

  void _onAuthStateChanged(User? user) {
    if (user != null) {
      if (_currentUser?.uid != user.uid) { // User changed or logged in
        if (_currentUser != null) {
          // If there was a previous user, ensure they are marked offline
          _goOffline(_currentUser!.uid);
        }
        _currentUser = user;
        _userStatusRef = _database.ref('online_users/${user.uid}');
        _goOnline();
      } else if (_currentUser == null) { // Fresh login
        _currentUser = user;
        _userStatusRef = _database.ref('online_users/${user.uid}');
        _goOnline();
      }
    } else { // User logged out
      if (_currentUser != null) {
        _goOffline(_currentUser!.uid);
      }
      _currentUser = null;
      _userStatusRef = null;
    }
  }

  Future<void> _goOnline() async {
    if (_userStatusRef == null || _onlineCountRef == null || _currentUser == null) return;

    try {
      await _userStatusRef!.set(true);
      await _onlineCountRef!.runTransaction((currentData) {
        final currentCount = currentData as num? ?? 0;
        return Transaction.success(currentCount + 1);
      });
      await _userStatusRef!.onDisconnect().remove();
      // Use ServerValue.increment for atomic decrement on disconnect
      await _onlineCountRef!.onDisconnect().set(ServerValue.increment(-1));
    } catch (e) {
      // Log error or handle as needed
      print('Error going online: $e');
    }
  }

  Future<void> _goOffline(String userId) async {
    // Use a specific ref for the user going offline, not necessarily _userStatusRef
    final userOfflineRef = _database.ref('online_users/$userId');
    if (_onlineCountRef == null) return;

    try {
      // Check if user was actually online before decrementing
      // This prevents issues if _goOffline is called multiple times
      // or if the onDisconnect already handled it.
      final snapshot = await userOfflineRef.get();
      if (snapshot.exists && (snapshot.value == true || snapshot.value != null) ) { // Check if node exists and is true
        await userOfflineRef.remove();
        await _onlineCountRef!.runTransaction((currentData) {
          final currentCount = currentData as num? ?? 0;
          // Ensure count doesn't go below zero
          return Transaction.success(max(0, currentCount - 1));
        });
      }
    } catch (e) {
      // Log error or handle as needed
      print('Error going offline for user $userId: $e');
    }
  }

  Stream<int> getOnlinePlayersCountStream() {
    return _onlineCountRef?.onValue.map((event) {
          final value = event.snapshot.value;
          if (value is int) {
            return value;
          } else if (value is num) {
            return value.toInt();
          }
          return 0; // Default to 0 if null or not a number
        }).handleError((error) {
          print("Error in onlinePlayersCountStream: $error");
          return 0; // Return 0 or some default on error
        }) ??
        Stream.value(0);
  }

  void dispose() {
    _authSubscription?.cancel();
    if (_currentUser != null) {
      // Call _goOffline with the UID of the user who was logged in
      _goOffline(_currentUser!.uid);
    }
    // It's important not to nullify _onlineCountRef here if the stream is still needed
    // or if onDisconnect operations are pending.
    // Firebase handles onDisconnect cleanup automatically.
  }
}

// Provider for FirebaseAuth - assuming it's set up elsewhere if not default instance
// If you have a central place for Firebase initializations, use that.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final presenceServiceProvider = Provider<PresenceService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  // Ensure FirebaseDatabase.instance is used or a specific app instance if needed
  final database = FirebaseDatabase.instance;
  final service = PresenceService(auth, database);
  ref.onDispose(() => service.dispose());
  return service;
});

final onlinePlayersCountProvider = StreamProvider<int>((ref) {
  final presenceService = ref.watch(presenceServiceProvider);
  return presenceService.getOnlinePlayersCountStream();
});