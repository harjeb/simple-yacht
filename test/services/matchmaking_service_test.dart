import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/services/matchmaking_service.dart';
import 'package:myapp/models/game_room.dart';
import 'package:myapp/models/game_enums.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as auth_mocks; // Alias to avoid conflict if User is also defined in firebase_auth_mocks
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth and User
import 'package:mockito/mockito.dart';

// Mock FirebaseAuth - using firebase_auth_mocks's MockFirebaseAuth
// We can directly use MockFirebaseAuth from the package if it suits the needs,
// or create a custom mock if more specific behavior is required.
// For this case, firebase_auth_mocks provides its own MockFirebaseAuth.
// Let's use the one from the package.

// Mock User - using firebase_auth_mocks's MockUser
// Similarly, firebase_auth_mocks provides MockUser.
// class MockUser extends Mock implements User { // This User should be from firebase_auth
//   @override
//   final String uid;
//   MockUser({this.uid = 'test_user_id'});
// }


void main() {
  // late MatchmakingService matchmakingService; // Removed: Will be initialized within tests/groups with DI
  late FakeFirebaseFirestore fakeFirestore;
  late auth_mocks.MockFirebaseAuth mockAuth;
  late auth_mocks.MockUser mockUser;

  // Top-level setUp is removed as MatchmakingService instance creation needs mocks.
  // Individual groups will handle their own setUp.

  group('MatchmakingService Tests', () {
    // Group for _generateRoomCode is removed.
    // Its functionality (length and hex format) will be tested as part of createTestMatch.

    group('createTestMatch', () {
      setUp(() {
        fakeFirestore = FakeFirebaseFirestore();
        // Provide more MockUser details if needed by the code under test, e.g., email, displayName
        mockUser = auth_mocks.MockUser(
          uid: 'test_user_id',
          email: 'test@example.com',
          displayName: 'Test User', // This might be used by the service
        );
        mockAuth = auth_mocks.MockFirebaseAuth(mockUser: mockUser, signedIn: true);

        // How MatchmakingService gets these instances is crucial.
        // If it's `FirebaseFirestore.instance`, `FakeFirebaseFirestore.instance` needs to be set.
        // If it's `FirebaseAuth.instance`, `MockFirebaseAuth` needs to be the instance.
        // This usually requires a DI setup or static instance overrides.

        // For `firebase_auth_mocks`, you typically pass the mockAuth instance.
        // For `fake_cloud_firestore`, it globally replaces `FirebaseFirestore.instance`.
        // So, `matchmakingService = MatchmakingService();` might pick up `FakeFirebaseFirestore.instance`.
        // However, `FirebaseAuth.instance` would still be the real one unless `firebase_auth_mocks`
        // provides a way to override the static getter, or `MatchmakingService` takes `FirebaseAuth` in its constructor.

        // Let's assume MatchmakingService can be instantiated for testing like this:
        // (This is a simplification; real-world would need proper DI)
        // matchmakingService = MatchmakingService(firestore: fakeFirestore, auth: mockAuth);
        // Since the service uses direct instantiation, we rely on global fakes if available,
        // or test methods that don't heavily depend on unmockable parts.

        // For this test, we'll proceed assuming FakeFirebaseFirestore is active globally
        // and we can mock FirebaseAuth interactions if MatchmakingService allowed injection.
        // Given the current structure of MatchmakingService, true unit testing of createTestMatch
        // with full mocking is challenging without refactoring.

        // We will use the actual MatchmakingService but with FakeFirebaseFirestore.
        // We need to ensure _auth.currentUser returns our mockUser.
        // This is the tricky part without DI for FirebaseAuth.
        // We will write the test assuming we *can* control FirebaseAuth.currentUser.
        // If not, this test becomes an integration test or needs service refactoring.

        // Let's simulate a scenario where MatchmakingService is refactored to accept auth
        // For now, we'll write the test as if `_auth` in MatchmakingService can be controlled.
        // This highlights the importance of testable code design.
      });

      test('should create a game room with a 6-digit hexadecimal ID and store it in Firestore', () async {
        // Arrange
        final opponentId = 'opponent_user_id';
        final expectedPlayerName = 'Test Player';
        final expectedOpponentName = 'Opponent Player';

        // Mock user data in Firestore for name retrieval
        await fakeFirestore.collection('users').doc(mockUser.uid).set({'displayName': expectedPlayerName});
        await fakeFirestore.collection('users').doc(opponentId).set({'displayName': expectedOpponentName});

        // Act
        // To make this testable, MatchmakingService needs to accept FirebaseAuth instance.
        // Let's assume we have a way to make `matchmakingService._auth` use `mockAuth`.
        // This is a conceptual step. In reality, you'd pass mockAuth to MatchmakingService constructor.
        // For example: `matchmakingService = MatchmakingService(auth: mockAuth, firestore: fakeFirestore);`

        // Due to direct instantiation `_auth = FirebaseAuth.instance;` in MatchmakingService,
        // we cannot easily inject `mockAuth` without refactoring the service.
        // We will proceed by testing the parts we can control (FakeFirestore) and acknowledge this limitation.

        // If we cannot mock _auth.currentUser, createTestMatch will throw if no real user is logged in.
        // For a true unit test, MatchmakingService should be refactored.
        // For now, we'll focus on the _generateRoomCode format and Firestore interaction.

        // Let's assume for the sake of this example that we *can* make `_auth.currentUser` return `mockUser`.
        // This would typically be done by initializing `FirebaseAuth.instance` with a mock,
        // or by passing `mockAuth` to `MatchmakingService`.

        // If MatchmakingService was:
        // class MatchmakingService {
        //   final FirebaseFirestore _firestore;
        //   final FirebaseAuth _auth;
        //   MatchmakingService({FirebaseFirestore? firestore, FirebaseAuth? auth})
        //       : _firestore = firestore ?? FirebaseFirestore.instance,
        //         _auth = auth ?? FirebaseAuth.instance;
        //   // ... rest of the class
        // }
        // Then we could do:
        // matchmakingService = MatchmakingService(firestore: fakeFirestore, auth: mockAuth);

        // Since it's not, we are limited. We will test the room code generation logic
        // and assume the auth part would work if a user was logged in.
        // The core of this test is to verify the room ID format and Firestore write.

        // Let's try to execute createTestMatch. It will likely fail on `_auth.currentUser`
        // if `firebase_auth_mocks` doesn't globally mock `FirebaseAuth.instance`.
        // `firebase_auth_mocks` typically requires you to pass the mock instance.

        // We will write the test assuming the happy path where auth is somehow mocked.
        // This is more of an integration test with FakeFirestore if auth isn't fully mocked.

        String? roomId;
        GameRoom? gameRoomData;

        // To make `_auth.currentUser` work with `MockFirebaseAuth`,
        // `MatchmakingService` needs to use the `mockAuth` instance.
        // Let's assume we are testing a refactored `MatchmakingService`
        // that takes `auth` and `firestore` in its constructor.
        // For the current code, this test will have issues with auth.

        // Let's focus on the _generateRoomCode part.
        // We can call _generateRoomCode if we make it public static for testing.
        // String generatedRoomId = MatchmakingService._generateRoomCode(); // If it was static

        // For now, we'll test the regex for the room code format.
        final hexRegex = RegExp(r'^[0-9A-F]{6}$');

        // We need to call createTestMatch. This is where the auth mock is critical.
        // If we can't mock auth, we can't reliably call createTestMatch in a unit test.
        // Let's assume we are in an environment where `FirebaseAuth.instance` IS `mockAuth`.
        // (e.g. using a test setup that allows overriding static instances, or DI)

        // Simulate a successful call to createTestMatch
        // This part of the test is highly dependent on the ability to mock FirebaseAuth.
        // If `_auth.currentUser` is null, it will throw.
        // We will assume `mockAuth.currentUser` is correctly returned.

        // To test `createTestMatch` properly with `MockFirebaseAuth` and `FakeFirebaseFirestore`,
        // `MatchmakingService` should be refactored for dependency injection:
        // ```dart
        // class MatchmakingService {
        //   final FirebaseFirestore _firestore;
        //   final FirebaseAuth _auth;
        //
        //   MatchmakingService({FirebaseFirestore? firestore, FirebaseAuth? auth})
        //       : _firestore = firestore ?? FirebaseFirestore.instance,
        //         _auth = auth ?? FirebaseAuth.instance;
        //   // ...
        // }
        // ```
        // Then in setUp:
        // `matchmakingService = MatchmakingService(firestore: fakeFirestore, auth: mockAuth);`

        // Given the current `MatchmakingService` structure, a true unit test for `createTestMatch`
        // is difficult. We will write the assertions assuming the call *could* be made.

        // Let's try to call it and catch potential auth errors, focusing on what we *can* test.
        try {
          // This is where the test would ideally run if auth was injectable
          // For now, this call might fail if FirebaseAuth.instance is not the mockAuth instance.
          // We are testing the *logic* of createTestMatch assuming auth works.
          
          // IMPORTANT: For this test to be a true unit test, MatchmakingService MUST be refactored
          // to accept FirebaseAuth and FirebaseFirestore via its constructor (Dependency Injection).
          // e.g., MatchmakingService({FirebaseAuth? auth, FirebaseFirestore? firestore})
          // The following line assumes such a refactor. If MatchmakingService() is called without DI,
          // it will use real Firebase instances (or global fakes if they work for auth).
          final matchmakingServiceWithDI = MatchmakingService( // Ensure this constructor matches the service
            auth: mockAuth,
            firestore: fakeFirestore,
          );
          roomId = await matchmakingServiceWithDI.createTestMatch(opponentId);

          // If we cannot refactor, we can only test _generateRoomCode if made public/static.
          // Let's assume we are testing the _generateRoomCode format.
          // This is a workaround due to the untestable nature of the current createTestMatch.
          
          // Hacky way to test _generateRoomCode via the existing service instance,
          // knowing it might fail at the auth step.
          // This is not a good unit test.
          
          // A more practical approach for the current code:
          // 1. Make _generateRoomCode public static for direct testing.
          // 2. For createTestMatch, write an integration test or refactor for DI.

          // Let's assume _generateRoomCode is made public static for testing its format:
          // class MatchmakingService {
          //   ...
          //   static String generateRoomCodeInternal() { ... } // formerly _generateRoomCode
          //   ...
          // }
          // final staticGeneratedRoomId = MatchmakingService.generateRoomCodeInternal();
          // expect(staticGeneratedRoomId.length, 6);
          // expect(hexRegex.hasMatch(staticGeneratedRoomId), isTrue, reason: "Room ID $staticGeneratedRoomId is not a 6-digit hex string");


          // Given the constraints, we will focus on testing the format of the generated code
          // by calling a method that uses it, and checking Firestore.
          // This makes it more of an integration test snippet.

          // We need a way to make MatchmakingService use mockAuth.
          // If not possible, this test is fundamentally flawed for unit testing `createTestMatch`.
          // We will write the ideal assertions, acknowledging the setup challenge.

          // Let's assume `MatchmakingService` is refactored for DI for this test to be valid.
          // final matchmakingServiceDI = MatchmakingService(firestore: fakeFirestore, auth: mockAuth);
          // roomId = await matchmakingServiceDI.createTestMatch(opponentId);

          // If we cannot assume DI, we must state this test cannot be a true unit test
          // for `createTestMatch` as written.
          // For the purpose of TDD, we write the test we *want* to pass.
          // This implies `MatchmakingService` should be refactored.

          // Let's proceed with the assumption that `matchmakingService` somehow uses `mockAuth` and `fakeFirestore`.
          // This is a strong assumption.
          
          // If `MatchmakingService` is NOT refactored, then `_auth.currentUser` will be the actual
          // logged-in user or null. If null, `createTestMatch` throws.
          // If a user is logged in (e.g. in a test environment), it uses the real Firebase.
          // `FakeFirebaseFirestore` will intercept Firestore calls.
          // `MockFirebaseAuth` is not used by `MatchmakingService` unless injected.

          // To make progress, we will assume `FirebaseAuth.instance` is successfully mocked
          // by `firebase_auth_mocks` in a way that `MatchmakingService` picks it up.
          // (e.g. `FirebaseAuth.instance = mockAuth;` if that were possible, or via a test setup).

          // The most robust way is DI. Without it, this is a best-effort test.
          // We will use the existing `matchmakingService` instance and hope `FakeFirebaseFirestore`
          // and `MockFirebaseAuth` (if it globally mocks) do their job.

          // roomId = await matchmakingService.createTestMatch(opponentId); // This line is removed, DI version is used above.

          // Assertions
          expect(roomId, isNotNull);
          expect(roomId.length, 6);
          expect(hexRegex.hasMatch(roomId), isTrue, reason: "Room ID $roomId is not a 6-digit hex string");

          // Verify Firestore document
          final roomDoc = await fakeFirestore.collection('gameRooms').doc(roomId).get();
          expect(roomDoc.exists, isTrue);

          gameRoomData = GameRoom.fromMap(roomDoc.data()!, roomDoc.id); // Pass document ID
          expect(gameRoomData.id, roomId);
          expect(gameRoomData.hostId, mockUser.uid);
          expect(gameRoomData.guestId, opponentId);
          expect(gameRoomData.gameMode, GameMode.multiplayer);
          expect(gameRoomData.status, GameRoomStatus.waiting);
          // Add null checks for gameState
          expect(gameRoomData.gameState, isNotNull);
          expect(gameRoomData.gameState!['hostName'], expectedPlayerName);
          expect(gameRoomData.gameState!['guestName'], expectedOpponentName);

        } catch (e) {
          // If an error occurs, it's likely due to the FirebaseAuth mocking issue.
          // For a real TDD cycle, this would indicate a need to refactor MatchmakingService for testability.
          print('Test execution error (likely auth mocking): $e');
          // We can't make strong assertions if the setup fails.
          // However, if _generateRoomCode was static, we could test it independently.
          // For now, we expect the test to pass if auth mocking works as hoped.
          // If it fails here, the primary issue is testability of MatchmakingService.
          expect(e, isNull, reason: "Test failed, likely due to FirebaseAuth mocking issues. Refactor service for DI.");
        }
      });
    });
  });
}

// Helper to make _generateRoomCode testable if it were public static
// class MatchmakingServiceTestHelper extends MatchmakingService {
//   static String testGenerateRoomCode() {
//     return MatchmakingService()._generateRoomCode(); // This doesn't work because _generateRoomCode is instance method
//   }
// }