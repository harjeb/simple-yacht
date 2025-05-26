import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'lib/firebase_options.dart';

void main() async {
  print("=== 测试 deleteUserData Cloud Function ===");
  
  try {
    // 初始化 Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase 初始化成功");
    
    // 检查当前用户
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ 没有登录用户，请先登录");
      return;
    }
    
    print("📋 当前用户信息:");
    print("   UID: ${user.uid}");
    print("   匿名用户: ${user.isAnonymous}");
    
    // 调用 deleteUserData Cloud Function
    print("\n🔄 调用 deleteUserData Cloud Function...");
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('deleteUserData');
    
    final response = await callable.call<Map<String, dynamic>>({
      'uid': user.uid,
    });
    
    print("✅ Cloud Function 调用成功!");
    print("📋 响应数据:");
    print("   success: ${response.data['success']}");
    print("   message: ${response.data['message']}");
    
  } catch (e) {
    print("❌ 测试失败:");
    print("   错误类型: ${e.runtimeType}");
    print("   错误信息: $e");
    
    if (e is FirebaseFunctionsException) {
      print("   Functions 错误代码: ${e.code}");
      print("   Functions 错误详情: ${e.details}");
    }
  }
}