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
    print("DEBUG: 开始生成唯一传输代码");
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const codeLength = 18;
    final random = Random();
    String code;
    bool isUnique = false;
    int attempts = 0;

    do {
      attempts++;
      code = String.fromCharCodes(Iterable.generate(
          codeLength, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
      
      print("DEBUG: 尝试 #$attempts - 生成的代码: $code");
      print("DEBUG: 检查代码唯一性...");
      print("DEBUG: 查询条件 - collection: users, where: transferCode == $code, limit: 1");
      
      try {
        final querySnapshot = await _usersCollection.where('transferCode', isEqualTo: code).limit(1).get();
        isUnique = querySnapshot.docs.isEmpty;
        print("DEBUG: 查询成功 - 代码唯一性检查结果: ${isUnique ? '唯一' : '重复'}");
        print("DEBUG: 查询返回文档数量: ${querySnapshot.docs.length}");
      } catch (e) {
        print("DEBUG: 查询 transferCode 唯一性时发生错误: $e");
        print("DEBUG: 错误类型: ${e.runtimeType}");
        if (e is FirebaseException) {
          print("DEBUG: Firebase 错误代码: ${e.code}");
          print("DEBUG: Firebase 错误消息: ${e.message}");
        }
        rethrow;
      }
      
      if (!isUnique) {
        print("DEBUG: 代码重复，重新生成...");
      }
    } while (!isUnique);

    print("DEBUG: 生成唯一传输代码成功，总尝试次数: $attempts, 最终代码: $code");
    return code;
  }

  /// Creates a new user document in Firestore.
  /// This is typically called after a new user signs in anonymously and sets up their username.
  Future<UserProfile?> createNewUser({required String userId, required String username}) async {
    print("=== DEBUG: UserAccountService.createNewUser 开始 ===");
    print("DEBUG: 输入参数 - userId: $userId, username: '$username'");
    print("DEBUG: 用户名验证 - 长度: ${username.length}, 是否为空: ${username.isEmpty}");
    
    try {
      print("DEBUG: 开始生成唯一传输代码...");
      final transferCode = await _generateUniqueTransferCode();
      print("DEBUG: 生成的传输代码: $transferCode");
      
      // Use FieldValue.serverTimestamp() to ensure server-side timestamp
      final userData = {
        'username': username,
        'transferCode': transferCode,
        'createdAt': FieldValue.serverTimestamp(), // Server timestamp for security rules
      };
      
      print("DEBUG: 准备写入 Firestore 的用户数据:");
      print("DEBUG: - username: ${userData['username']}");
      print("DEBUG: - transferCode: ${userData['transferCode']}");
      print("DEBUG: - createdAt: ${userData['createdAt']}");
      print("DEBUG: 目标文档路径: users/$userId");
      
      print("DEBUG: 开始写入 Firestore...");
      await _usersCollection.doc(userId).set(userData);
      print("DEBUG: Firestore 写入成功");
      
      // Return UserProfile with current timestamp for local use
      final userProfile = UserProfile(
        uid: userId,
        username: username,
        transferCode: transferCode,
        createdAt: Timestamp.now(), // Local timestamp for return value
      );
      print("DEBUG: 创建 UserProfile 对象成功");
      print("DEBUG: 返回的 UserProfile - uid: ${userProfile.uid}, username: ${userProfile.username}");
      return userProfile;
    } on FirebaseException catch (e) {
      print("=== DEBUG: FirebaseException 在 createNewUser 中捕获 ===");
      print("DEBUG: 错误代码: ${e.code}");
      print("DEBUG: 错误消息: ${e.message}");
      print("DEBUG: 错误插件: ${e.plugin}");
      print("DEBUG: 完整错误: ${e.toString()}");
      
      if (e.code == 'not-found' || (e.message?.contains('NOT_FOUND') ?? false) || (e.message?.contains('database does not exist') ?? false)) {
        // Rethrow to be caught by the caller, allowing specific UI handling
        print('DEBUG: 检测到 Firestore 数据库未找到错误，重新抛出');
        throw FirebaseException(plugin: 'Firestore', code: 'not-found', message: 'Firestore database not found during user creation.');
      }
      print('DEBUG: 重新抛出其他 FirebaseException');
      rethrow; // Rethrow other FirebaseExceptions
    } catch (e) {
      print("=== DEBUG: 通用异常在 createNewUser 中捕获 ===");
      print("DEBUG: 异常类型: ${e.runtimeType}");
      print("DEBUG: 异常消息: $e");
      print("DEBUG: 异常堆栈跟踪:");
      print(StackTrace.current);
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
        print('Functions Exception Code: ${e.code}');
        
        // 检查是否是 App Check 相关的错误
        if (e.code == 'invalid-argument' && e.message?.contains('uid') == true) {
          print('=== 可能的 App Check 验证失败 ===');
          print('这个错误可能是由于 Firebase App Check 验证失败导致的，而不是真正的参数缺失');
          print('建议检查 Firebase 项目的 App Check 配置');
        }
      }
      return false;
    }
  }
}