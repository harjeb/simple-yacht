import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// Ensure this is the correct import path for the package
import 'package:firebase_database_mocks/firebase_database_mocks.dart'; 
import 'package:simple_yacht/services/presence_service.dart';

// --- Mocks for FirebaseAuth ---
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {
  @override
  final String uid;
  MockUser(this.uid);

  @override
  String? get displayName => 'Test User';
}

void main() {
  late PresenceService presenceService;
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseDatabase fakeDatabase; 
  late MockUser mockUser;

  late StreamController<User?> authStateController;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeDatabase = FakeFirebaseDatabase(); 
    
    mockUser = MockUser('test_user_id_123');

    authStateController = StreamController<User?>.broadcast();

    when(mockAuth.currentUser).thenReturn(null);
    when(mockAuth.authStateChanges()).thenAnswer((_) => authStateController.stream);

    presenceService = PresenceService(mockAuth, database: fakeDatabase);
  });

  tearDown(() async {
    await authStateController.close();
    presenceService.dispose();
    fakeDatabase.clear();
  });

  group('Authentication State Changes & _goOnline', () {
    test('WHEN user logs in (initially null) THEN user status and online count are updated correctly', () async {
      var userStatusNodeBefore = await fakeDatabase.ref('online_users/${mockUser.uid}').get();
      expect(userStatusNodeBefore.value, isNull, reason: "User status should initially be null");

      var onlineCountNodeBefore = await fakeDatabase.ref('online_users_count').get();
      expect(onlineCountNodeBefore.value, isNull, reason: "Online count should initially be null");

      authStateController.add(mockUser);
      await Future.delayed(Duration.zero); 

      final userStatusSnapshot = await fakeDatabase.ref('online_users/${mockUser.uid}').get();
      expect(userStatusSnapshot.value, true, reason: "User status should be true after login");

      final onlineCountSnapshot = await fakeDatabase.ref('online_users_count').get();
      expect(onlineCountSnapshot.value, 1, reason: "Online count should be 1 after login");

      // Simulate disconnect to test onDisconnect handlers
      // Note: FakeFirebaseDatabase needs to support simulating disconnects for this to work.
      // The `firebase_database_mocks` package might have a specific way to do this.
      // For example, it might be `fakeDatabase.goOffline()` or similar.
      // Let's assume for now it clears the data or runs registered onDisconnects.
      
      // If FakeFirebaseDatabase has a method like `triggerDisconnect()` or `goOffline()`
      // Call it here: e.g., fakeDatabase.goOffline();
      // Then re-check the values:
      // final userStatusAfterDisconnect = await fakeDatabase.ref('online_users/${mockUser.uid}').get();
      // expect(userStatusAfterDisconnect.value, isNull, reason: "User status should be null after disconnect");
      // final onlineCountAfterDisconnect = await fakeDatabase.ref('online_users_count').get();
      // expect(onlineCountAfterDisconnect.value, 0, reason: "Online count should be 0 after disconnect");
    });

    test('WHEN service is initialized with an existing user THEN user status and online count are updated correctly', () async {
      await authStateController.close(); 
      presenceService.dispose();         
      fakeDatabase.clear();              

      authStateController = StreamController<User?>.broadcast();
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockAuth.authStateChanges()).thenAnswer((_) => authStateController.stream);
  
      presenceService = PresenceService(mockAuth, database: fakeDatabase);
      await Future.delayed(Duration.zero);
  
      final userStatusSnapshot = await fakeDatabase.ref('online_users/${mockUser.uid}').get();
      expect(userStatusSnapshot.value, true);

      final onlineCountSnapshot = await fakeDatabase.ref('online_users_count').get();
      expect(onlineCountSnapshot.value, 1);
    });
  });
test('WHEN user logs in multiple times THEN online count does not inflate', () async {
      // Initial login
      authStateController.add(mockUser);
      await Future.delayed(Duration.zero);

      var onlineCountSnapshot = await fakeDatabase.ref('online_users_count').get();
      expect(onlineCountSnapshot.value, 1, reason: "Online count should be 1 after first login");

      // Simulate re-login or redundant auth state change for the same user
      // This will call _goOnline again internally via _handleAuthStateChanged
      authStateController.add(mockUser); 
      await Future.delayed(Duration.zero);

      onlineCountSnapshot = await fakeDatabase.ref('online_users_count').get();
      expect(onlineCountSnapshot.value, 1, reason: "Online count should remain 1 after redundant login");

      // Simulate another user logging in to ensure count can still increment
      final mockUser2 = MockUser('test_user_id_456');
      authStateController.add(mockUser2);
      await Future.delayed(Duration.zero);

      onlineCountSnapshot = await fakeDatabase.ref('online_users_count').get();
      expect(onlineCountSnapshot.value, 2, reason: "Online count should be 2 after a different user logs in");
    });

  // TODO: Add tests for _goOffline()
  // TODO: Add tests for getOnlinePlayersCountStream()
  // TODO: Add tests for dispose() for _goOffline call
}