import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
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
    print('[PresenceService] Constructor called.');
    _onlineCountRef = _database.ref('online_users_count');
    print('[PresenceService] online_users_count ref: ${_onlineCountRef?.path}');
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
    // Initialize with current user if already logged in
    _currentUser = _auth.currentUser;
    print('[PresenceService] Initial currentUser: ${_currentUser?.uid}');
    if (_currentUser != null) {
      _userStatusRef = _database.ref('online_users/${_currentUser!.uid}');
      print('[PresenceService] Initial userStatusRef: ${_userStatusRef?.path}');
      _goOnline();
    }
  }

  void _onAuthStateChanged(User? user) {
    print('[PresenceService] _onAuthStateChanged triggered. User: ${user?.uid}');
    if (user != null) {
      print('[PresenceService] User is not null. Current _currentUser: ${_currentUser?.uid}');
      if (_currentUser?.uid != user.uid) { // User changed or logged in
        print('[PresenceService] User changed or new login. Old UID: ${_currentUser?.uid}, New UID: ${user.uid}');
        if (_currentUser != null) {
          // If there was a previous user, ensure they are marked offline
          _goOffline(_currentUser!.uid);
        }
        _currentUser = user;
        _userStatusRef = _database.ref('online_users/${user.uid}');
        print('[PresenceService] Set userStatusRef for ${user.uid}: ${_userStatusRef?.path}');
        _goOnline();
      } else if (_currentUser == null) { // Fresh login
        print('[PresenceService] Fresh login for UID: ${user.uid}. _currentUser was null.');
        _currentUser = user;
        _userStatusRef = _database.ref('online_users/${user.uid}');
        print('[PresenceService] Set userStatusRef for ${user.uid}: ${_userStatusRef?.path}');
        _goOnline();
      } else {
        print('[PresenceService] User is not null, but UID is the same as _currentUser.uid OR _currentUser was not null. No specific action taken in this branch for _onAuthStateChanged.');
      }
    } else { // User logged out
      print('[PresenceService] User logged out. Current _currentUser: ${_currentUser?.uid}');
      if (_currentUser != null) {
        _goOffline(_currentUser!.uid);
      }
      _currentUser = null;
      _userStatusRef = null;
      print('[PresenceService] _currentUser and _userStatusRef set to null.');
    }
  }

  Future<void> _goOnline() async {
    print('[PresenceService] _goOnline called. CurrentUser: ${_currentUser?.uid}, UserStatusRef: ${_userStatusRef?.path}');
    if (_userStatusRef == null || _onlineCountRef == null || _currentUser == null) {
      print('[PresenceService] _goOnline: Preconditions not met. _userStatusRef: ${_userStatusRef}, _onlineCountRef: ${_onlineCountRef}, _currentUser: ${_currentUser}');
      return;
    }

    try {
      print('[PresenceService] Attempting to set ${_userStatusRef!.path} to true');
      await _userStatusRef!.set(true);
      print('[PresenceService] Successfully set ${_userStatusRef!.path} to true');
      print('[PresenceService] Attempting to run transaction on ${_onlineCountRef!.path}');
      await _onlineCountRef!.runTransaction((currentData) {
        final currentCount = currentData as num? ?? 0;
        print('[PresenceService] Transaction: currentCount = $currentCount, newCount = ${currentCount + 1}');
        return Transaction.success(currentCount + 1);
      });
      print('[PresenceService] Transaction completed on ${_onlineCountRef!.path}');
      print('[PresenceService] Setting onDisconnect().remove() for ${_userStatusRef!.path}');
      await _userStatusRef!.onDisconnect().remove();
      // Use ServerValue.increment for atomic decrement on disconnect
      print('[PresenceService] Setting onDisconnect().set(ServerValue.increment(-1)) for ${_onlineCountRef!.path}');
      await _onlineCountRef!.onDisconnect().set(ServerValue.increment(-1));
      print('[PresenceService] _goOnline completed successfully for ${_currentUser!.uid}.');
    } catch (e) {
      // Log error or handle as needed
      print('[PresenceService] Error going online for ${_currentUser?.uid}: $e');
    }
  }

  Future<void> _goOffline(String userId) async {
    print('[PresenceService] _goOffline called for user $userId.');
    // Use a specific ref for the user going offline, not necessarily _userStatusRef
    final userOfflineRef = _database.ref('online_users/$userId');
    print('[PresenceService] userOfflineRef for $userId: ${userOfflineRef.path}');
    if (_onlineCountRef == null) {
      print('[PresenceService] _goOffline: _onlineCountRef is null. Returning.');
      return;
    }

    try {
      // Check if user was actually online before decrementing
      // This prevents issues if _goOffline is called multiple times
      // or if the onDisconnect already handled it.
      print('[PresenceService] Getting snapshot for ${userOfflineRef.path}');
      final snapshot = await userOfflineRef.get();
      print('[PresenceService] Snapshot for ${userOfflineRef.path} exists: ${snapshot.exists}, value: ${snapshot.value}');
      if (snapshot.exists && (snapshot.value == true || snapshot.value != null) ) { // Check if node exists and is true
        print('[PresenceService] Attempting to remove ${userOfflineRef.path}');
        await userOfflineRef.remove();
        print('[PresenceService] Successfully removed ${userOfflineRef.path}');
        print('[PresenceService] Attempting to run transaction on ${_onlineCountRef!.path} for decrement');
        await _onlineCountRef!.runTransaction((currentData) {
          final currentCount = currentData as num? ?? 0;
          final newCount = max(0, currentCount - 1);
          print('[PresenceService] Transaction (decrement): currentCount = $currentCount, newCount = $newCount');
          return Transaction.success(newCount);
        });
        print('[PresenceService] Transaction (decrement) completed on ${_onlineCountRef!.path}');
      } else {
        print('[PresenceService] User ${userOfflineRef.path} was not online or node did not exist. No action taken to decrement count.');
      }
      print('[PresenceService] _goOffline completed for user $userId.');
    } catch (e) {
      // Log error or handle as needed
      print('[PresenceService] Error going offline for user $userId: $e');
    }
  }

  Stream<int> getOnlinePlayersCountStream() {
    print('[PresenceService] getOnlinePlayersCountStream called. Ref: ${_onlineCountRef?.path}');
    return _onlineCountRef?.onValue.map((event) {
          final value = event.snapshot.value;
          print('[PresenceService] onlinePlayersCountStream event: ${event.snapshot.key}, value: $value');
          if (value is int) {
            return value;
          } else if (value is num) {
            return value.toInt();
          }
          return 0; // Default to 0 if null or not a number
        }).handleError((error) {
          print("[PresenceService] Error in onlinePlayersCountStream: $error");
          return 0; // Return 0 or some default on error
        }) ??
        Stream.value(0);
  }

  void dispose() {
    print('[PresenceService] dispose called. CurrentUser: ${_currentUser?.uid}');
    _authSubscription?.cancel();
    print('[PresenceService] _authSubscription cancelled.');
    if (_currentUser != null) {
      // Call _goOffline with the UID of the user who was logged in
      print('[PresenceService] Calling _goOffline from dispose for user ${_currentUser!.uid}');
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
  // Explicitly set the databaseURL to ensure correctness.
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(), // Use the default Firebase app
    databaseURL: 'https://yacht-f816d-default-rtdb.firebaseio.com', // CORRECT RTDB URL
  );
  print('[PresenceService] FirebaseDatabase instance created with URL: ${database.databaseURL}');
  final service = PresenceService(auth, database);
  ref.onDispose(() => service.dispose());
  return service;
});

final onlinePlayersCountProvider = StreamProvider<int>((ref) {
  final presenceService = ref.watch(presenceServiceProvider);
  return presenceService.getOnlinePlayersCountStream();
});