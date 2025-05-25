import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Correct package import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/services/auth_service.dart'; // For firebaseAuthProvider

// Provider for FirebaseFirestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Provider for FirebaseFunctions instance
final functionsProvider = Provider<FirebaseFunctions>((ref) { // Use FirebaseFunctions type
  // You can specify the region if your functions are not in us-central1
  return FirebaseFunctions.instance; // Use FirebaseFunctions.instance
});

final userAccountServiceProvider = Provider<UserAccountService>((ref) {
  return UserAccountService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(functionsProvider),
  );
});

// Model for User Data (can be expanded)
class UserProfile {
  final String uid;
  final String username;
  final String transferCode;
  final Timestamp createdAt;
  // Add other game data fields as needed, e.g.,
  // final int highScore;
  // final int eloRating;

  UserProfile({
    required this.uid,
    required this.username,
    required this.transferCode,
    required this.createdAt,
    // this.highScore = 0,
    // this.eloRating = 1000,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception("User data is null in Firestore snapshot!");
    }
    return UserProfile(
      uid: snapshot.id,
      username: data['username'] as String,
      transferCode: data['transferCode'] as String,
      createdAt: data['createdAt'] as Timestamp,
      // highScore: data['gameData']?['highScore'] as int? ?? 0,
      // eloRating: data['gameData']?['eloRating'] as int? ?? 1000,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'transferCode': transferCode,
      'createdAt': createdAt,
      // 'gameData': {
      //   'highScore': highScore,
      //   'eloRating': eloRating,
      // },
    };
  }
}


class UserAccountService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions; // Use FirebaseFunctions type

  UserAccountService(this._firebaseAuth, this._firestore, this._functions);

  CollectionReference<Map<String, dynamic>> get _usersCollection => _firestore.collection('users');

  /// Generates a unique 18-character alphanumeric (uppercase) transfer code.
  /// Checks Firestore for uniqueness.
  Future<String> _generateUniqueTransferCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const codeLength = 18;
    final random = Random();
    String code;
    bool isUnique = false;

    do {
      code = String.fromCharCodes(Iterable.generate(
          codeLength, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
      
      final querySnapshot = await _usersCollection.where('transferCode', isEqualTo: code).limit(1).get();
      isUnique = querySnapshot.docs.isEmpty;
    } while (!isUnique);

    return code;
  }

  /// Creates a new user document in Firestore.
  /// This is typically called after a new user signs in anonymously and sets up their username.
  Future<UserProfile?> createNewUser({required String userId, required String username}) async {
    try {
      final transferCode = await _generateUniqueTransferCode();
      final userProfile = UserProfile(
        uid: userId,
        username: username,
        transferCode: transferCode,
        createdAt: Timestamp.now(),
      );
      await _usersCollection.doc(userId).set(userProfile.toFirestore());
      return userProfile;
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || (e.message?.contains('NOT_FOUND') ?? false) || (e.message?.contains('database does not exist') ?? false)) {
        // Rethrow to be caught by the caller, allowing specific UI handling
        print('Error creating new user: Firestore database not found. $e');
        throw FirebaseException(plugin: 'Firestore', code: 'not-found', message: 'Firestore database not found during user creation.');
      }
      print('Error creating new user: $e');
      rethrow; // Rethrow other FirebaseExceptions
    } catch (e) {
      print('Error creating new user: $e');
      rethrow; // Rethrow other general exceptions
    }
  }

  /// Retrieves a user's profile from Firestore by their UID.
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();
      if (docSnapshot.exists) {
        return UserProfile.fromFirestore(docSnapshot);
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || (e.message?.contains('NOT_FOUND') ?? false) || (e.message?.contains('database does not exist') ?? false)) {
         print('Error getting user profile: Firestore database not found. $e');
        // It's important that FutureProviders handle exceptions correctly.
        // Throwing here will make the FutureProvider enter an error state.
        throw FirebaseException(plugin: 'Firestore', code: 'not-found', message: 'Firestore database not found when getting user profile.');
      }
      print('Error getting user profile: $e');
      rethrow; // Rethrow other FirebaseExceptions
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow; // Rethrow other general exceptions
    }
  }
  
  /// Finds a user's UID by their transfer code.
  Future<String?> getUserIdByTransferCode(String transferCode) async {
    try {
      final querySnapshot = await _usersCollection
          .where('transferCode', isEqualTo: transferCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // The document ID is the UID
      }
      return null;
    } catch (e) {
      print('Error finding user by transfer code: $e');
      return null;
    }
  }

  /// Deletes the current user's account and all associated data.
  /// Calls the 'deleteUserData' Cloud Function.
  Future<bool> deleteCurrentUserAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      print('No user signed in to delete.');
      return false;
    }
    try {
      final HttpsCallable callable = _functions.httpsCallable('deleteUserData');
      final response = await callable.call<Map<String, dynamic>>({'uid': user.uid});
      
      if (response.data['success'] == true) {
        print('User account deleted successfully via Cloud Function.');
        // The auth state listener in AuthService should handle sign-out automatically
        // after the user is deleted from Firebase Auth by the function.
        return true;
      } else {
        print('Cloud Function indicated failure in deleting user: ${response.data['message']}');
        return false;
      }
    } catch (e) {
      print('Error calling deleteUserData Cloud Function: $e');
      if (e is FirebaseFunctionsException) { // This type comes from cloud_functions package
        print('Functions Exception Details: ${e.details}');
        print('Functions Exception Message: ${e.message}');
      }
      return false;
    }
  }
}