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
  final FirebaseDatabase _database; // This will be initialized by the constructor
  User? _currentUser;
  StreamSubscription? _authSubscription;
  DatabaseReference? _userStatusRef;
  DatabaseReference? _onlineCountRef;
  bool _isProcessingAuthStateChange = false; // 新增

  PresenceService(this._auth, {FirebaseDatabase? database}) : _database = database ?? FirebaseDatabase.instance {
    print('[PresenceService] Constructor called.');
    _onlineCountRef = _database.ref('online_users_count');
    print('[PresenceService] online_users_count ref: ${_onlineCountRef?.path}');
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged_wrapper); // 使用包装器
    // 构造函数中对初始用户的 _goOnline 调用已移至 _onAuthStateChanged_wrapper 的首次调用处理
    // _currentUser = _auth.currentUser; // 这行可以移除，因为 _onAuthStateChanged_wrapper 会处理初始状态
    // print('[PresenceService] Initial currentUser (in constructor): ${_currentUser?.uid}');
    // if (_currentUser != null) {
    //   _userStatusRef = _database.ref('online_users/${_currentUser!.uid}');
    //   print('[PresenceService] Initial userStatusRef (in constructor): ${_userStatusRef?.path}');
    //   _goOnline(); // 避免竞争，由 _onAuthStateChanged_wrapper 处理
    // }
  }

  Future<void> _onAuthStateChanged_wrapper(User? newUser) async { // 新增包装器
    print('[PresenceService] _onAuthStateChanged_wrapper triggered. User: ${newUser?.uid}');
    if (_isProcessingAuthStateChange) {
      print('[PresenceService] Auth state change processing already in progress. Skipping.');
      return;
    }
    _isProcessingAuthStateChange = true;
    try {
      await _handleAuthStateChanged(newUser);
    } catch (error) {
      print('[PresenceService] Error in _handleAuthStateChanged: $error');
      // Consider logging to a more persistent store or rethrowing if critical
    } finally {
      _isProcessingAuthStateChange = false;
    }
  }

  Future<void> _handleAuthStateChanged(User? newUser) async { // 原 _onAuthStateChanged 逻辑，需细化
    print('[PresenceService] _handleAuthStateChanged processing. New User: ${newUser?.uid}');
    final previousUser = _currentUser; // Capture previous user before updating _currentUser

    if (newUser != null) { // 用户已登录或切换
      print('[PresenceService] New user is not null. UID: ${newUser.uid}');
      if (previousUser?.uid != newUser.uid) { // 用户更改或新登录
        print('[PresenceService] User changed or new login. Previous UID: ${previousUser?.uid}, New UID: ${newUser.uid}');
        if (previousUser != null) {
          print('[PresenceService] Marking previous user ${previousUser.uid} offline.');
          // Use the specific user's ref for going offline
          final previousUserStatusRef = _database.ref('online_users/${previousUser.uid}');
          await _goOffline(previousUser.uid, previousUserStatusRef);
        }
        _currentUser = newUser;
        _userStatusRef = _database.ref('online_users/${_currentUser!.uid}');
        print('[PresenceService] Set _currentUser to ${newUser.uid}, _userStatusRef to ${_userStatusRef?.path}');
        await _goOnline();
      } else if (previousUser == null) { // 明确处理从 null 到新用户 (例如，应用首次启动时用户已登录)
        print('[PresenceService] Fresh login (previousUser was null). New UID: ${newUser.uid}');
        _currentUser = newUser;
        _userStatusRef = _database.ref('online_users/${_currentUser!.uid}');
        print('[PresenceService] Set _currentUser to ${newUser.uid}, _userStatusRef to ${_userStatusRef?.path}');
        await _goOnline();
      } else { // UID 相同，确保在线状态（例如服务重启或热重载后 _currentUser 仍然存在但状态可能需要刷新）
        print('[PresenceService] User UID ${newUser.uid} is the same as previousUser.uid. Ensuring online status.');
        if (_userStatusRef == null) { // Ensure _userStatusRef is set if it somehow became null
             _userStatusRef = _database.ref('online_users/${newUser.uid}');
             print('[PresenceService] _userStatusRef was null, re-initialized to ${_userStatusRef?.path}');
        }
        // _currentUser is already newUser
        await _goOnline(); // _goOnline 内部有检查，会处理重复上线的情况
      }
    } else { // 用户已登出
      print('[PresenceService] New user is null (logout). Previous user: ${previousUser?.uid}');
      if (previousUser != null) {
        print('[PresenceService] Marking previous user ${previousUser.uid} offline due to logout.');
        final previousUserStatusRef = _database.ref('online_users/${previousUser.uid}');
        await _goOffline(previousUser.uid, previousUserStatusRef);
      }
      _currentUser = null;
      _userStatusRef = null;
      print('[PresenceService] _currentUser and _userStatusRef set to null after logout.');
    }
  }

  Future<void> _goOnline() async {
    print('[PresenceService] _goOnline called. CurrentUser: ${_currentUser?.uid}, UserStatusRef: ${_userStatusRef?.path}');

    if (_userStatusRef == null || _onlineCountRef == null || _currentUser == null) {
      print('[PresenceService] _goOnline: Preconditions not met.');
      return;
    }

    try {
      final userStatusSnapshot = await _userStatusRef!.get();
      print('[PresenceService] Snapshot for ${_userStatusRef!.path} exists: ${userStatusSnapshot.exists}, value: ${userStatusSnapshot.value}');

      if (userStatusSnapshot.exists && userStatusSnapshot.value == true) {
        print('[PresenceService] User ${_currentUser!.uid} is already online. Ensuring onDisconnect handlers.');
        await _userStatusRef!.onDisconnect().remove();
        await _onlineCountRef!.onDisconnect().set(ServerValue.increment(-1));
        print('[PresenceService] onDisconnect handlers re-set for already online user ${_currentUser!.uid}.');
        return;
      }

      bool shouldIncrementGlobalCount = false;
      if (!userStatusSnapshot.exists) {
        print('[PresenceService] User node ${_userStatusRef!.path} does not exist. Will increment global count.');
        shouldIncrementGlobalCount = true;
      } else {
        print('[PresenceService] User node ${_userStatusRef!.path} exists but value is not true (value: ${userStatusSnapshot.value}). NOT incrementing global count to prevent inflation.');
      }

      await _userStatusRef!.set(true); // Mark user as online
      print('[PresenceService] Set ${_userStatusRef!.path} to true.');

      if (shouldIncrementGlobalCount) {
        print('[PresenceService] Attempting to increment global online count.');
        await _onlineCountRef!.runTransaction((currentData) {
          final currentCount = currentData as num? ?? 0;
          final newCount = currentCount + 1;
          print('[PresenceService] Transaction (increment): currentCount = $currentCount, newCount = $newCount');
          return Transaction.success(newCount);
        });
        print('[PresenceService] Global online count incremented.');
      } else {
        print('[PresenceService] Skipped incrementing global online count for user ${_currentUser!.uid}.');
      }
      
      await _userStatusRef!.onDisconnect().remove();
      await _onlineCountRef!.onDisconnect().set(ServerValue.increment(-1));
      print('[PresenceService] _goOnline completed for ${_currentUser!.uid}.');
    } catch (e) {
      print('[PresenceService] Error going online for ${_currentUser?.uid}: $e');
    }
  }

  Future<void> _goOffline(String userIdToMarkOffline, DatabaseReference specificUserStatusRef) async { // 接受特定 ref
    print('[PresenceService] _goOffline called for user $userIdToMarkOffline with ref ${specificUserStatusRef.path}.');
    if (_onlineCountRef == null) {
      print('[PresenceService] _goOffline: _onlineCountRef is null. Returning.');
      return;
    }

    try {
      print('[PresenceService] Getting snapshot for ${specificUserStatusRef.path}');
      final snapshot = await specificUserStatusRef.get();
      print('[PresenceService] Snapshot for ${specificUserStatusRef.path} exists: ${snapshot.exists}, value: ${snapshot.value}');
      
      // Only proceed if the user was actually marked as online (true)
      if (snapshot.exists && snapshot.value == true) {
        print('[PresenceService] Attempting to remove ${specificUserStatusRef.path}');
        await specificUserStatusRef.remove(); // Remove the user's online status node
        print('[PresenceService] Successfully removed ${specificUserStatusRef.path}');
        
        print('[PresenceService] Attempting to run transaction on ${_onlineCountRef!.path} for decrement');
        await _onlineCountRef!.runTransaction((currentData) {
          final currentCount = currentData as num? ?? 0;
          final newCount = max(0, currentCount - 1); // Ensure count doesn't go below 0
          print('[PresenceService] Transaction (decrement): currentCount = $currentCount, newCount = $newCount');
          return Transaction.success(newCount);
        });
        print('[PresenceService] Transaction (decrement) completed on ${_onlineCountRef!.path}');
      } else {
        print('[PresenceService] User ${specificUserStatusRef.path} was not online (or node did not exist/value was not true). No action taken to decrement count.');
      }
      print('[PresenceService] _goOffline completed for user $userIdToMarkOffline.');
    } catch (e) {
      print('[PresenceService] Error going offline for user $userIdToMarkOffline: $e');
    }
  }

  Stream<int> getOnlinePlayersCountStream() {
    print('[PresenceService] getOnlinePlayersCountStream (int) called. Ref: ${_onlineCountRef?.path}');

    if (_onlineCountRef == null) {
      print('[PresenceService] _onlineCountRef is null, returning error stream.');
      // Throw an error that StreamProvider can catch and convert to AsyncValue.error
      return Stream.error(StateError('Online count reference is null'));
    }

    return _onlineCountRef!.onValue.map((event) {
      final value = event.snapshot.value;
      print('[PresenceService] onlinePlayersCountStream (int) event: ${event.snapshot.key}, value: $value, exists: ${event.snapshot.exists}');
      if (value is int) {
        return value;
      } else if (value is num) {
        return value.toInt();
      } else if (value == null && event.snapshot.exists) {
        // Node exists but value is null
        return 0;
      } else if (!event.snapshot.exists) {
        // Node doesn't exist
        return 0;
      } else {
        // Unexpected value type, throw an error
        final errorMessage = "Unexpected data type for online count: ${value?.runtimeType}, value: $value";
        print("[PresenceService] $errorMessage");
        throw StateError(errorMessage);
      }
    }).handleError((error, stackTrace) {
      // Log and rethrow, or transform into a specific error type if needed
      print("[PresenceService] Error in onlinePlayersCountStream (int) processing: $error");
      // Let StreamProvider handle this error by rethrowing.
      // Alternatively, could return a stream with an error: return Stream.error(error);
      // but throwing directly is often cleaner for StreamProvider.
      throw error; // Rethrow to be caught by StreamProvider
    });
  }

  void dispose() {
    print('[PresenceService] dispose called. CurrentUser: ${_currentUser?.uid}');
    _authSubscription?.cancel();
    print('[PresenceService] _authSubscription cancelled.');
    if (_currentUser != null) {
      // Ensure we use the correct user ID and a fresh reference for dispose
      final userIdForDispose = _currentUser!.uid;
      final tempUserRefForDispose = _database.ref('online_users/$userIdForDispose');
      print('[PresenceService] Calling _goOffline from dispose for user $userIdForDispose using ref ${tempUserRefForDispose.path}');
      // Use an async context if _goOffline is truly async and needs to complete,
      // but for dispose, it's often fire-and-forget or best-effort.
      // For simplicity here, direct call. If it must complete, consider `Future.microtask` or similar.
      _goOffline(userIdForDispose, tempUserRefForDispose); // 确保使用参数化的 _goOffline
    }
    // _onlineCountRef is not nullified as its stream might still be in use or onDisconnect pending.
    print('[PresenceService] Dispose finished.');
  }
}

// Provider for FirebaseAuth - assuming it's set up elsewhere if not default instance
// If you have a central place for Firebase initializations, use that.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final presenceServiceProvider = Provider<PresenceService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  // Ensure FirebaseDatabase.instance is used or a specific app instance if needed
  // Explicitly set the databaseURL to ensure correctness.
  final database = FirebaseDatabase.instance; // Use the default instance configured by initializeApp
  print('[PresenceService] FirebaseDatabase instance using default URL: ${database.databaseURL}');
  // Pass the database instance explicitly, though it would default to FirebaseDatabase.instance
  final service = PresenceService(auth, database: database);
  ref.onDispose(() => service.dispose());
  return service;
});

final onlinePlayersCountProvider = StreamProvider.autoDispose<int>((ref) {
  final presenceService = ref.watch(presenceServiceProvider);
  return presenceService.getOnlinePlayersCountStream();
});