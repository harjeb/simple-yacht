import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'lib/firebase_options.dart';

void main() async {
  print("=== Cloud Function 调试测试开始 ===");
  
  // 初始化 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("✓ Firebase 初始化完成");
  
  // 检查当前用户状态
  final auth = FirebaseAuth.instance;
  User? currentUser = auth.currentUser;
  
  print("当前用户状态: ${currentUser != null ? '已登录' : '未登录'}");
  
  if (currentUser == null) {
    print("正在执行匿名登录...");
    try {
      final userCredential = await auth.signInAnonymously();
      currentUser = userCredential.user;
      print("✓ 匿名登录成功");
      print("  - UID: ${currentUser?.uid}");
      print("  - 是否匿名: ${currentUser?.isAnonymous}");
    } catch (e) {
      print("✗ 匿名登录失败: $e");
      return;
    }
  } else {
    print("✓ 用户已登录");
    print("  - UID: ${currentUser.uid}");
    print("  - 是否匿名: ${currentUser.isAnonymous}");
  }
  
  // 获取 ID Token 进行调试
  try {
    final idToken = await currentUser!.getIdToken();
    if (idToken != null) {
      print("✓ 获取 ID Token 成功");
      print("  - Token 长度: ${idToken.length}");
      print("  - Token 前50字符: ${idToken.substring(0, 50)}...");
    } else {
      print("✗ ID Token 为 null");
    }
  } catch (e) {
    print("✗ 获取 ID Token 失败: $e");
  }
  
  // 测试 Cloud Function 调用
  print("\n=== 测试 deleteUserData Cloud Function ===");
  
  final functions = FirebaseFunctions.instance;
  final callable = functions.httpsCallable('deleteUserData');
  
  // 准备参数
  final params = {'uid': currentUser!.uid};
  print("调用参数: $params");
  
  try {
    print("正在调用 Cloud Function...");
    final response = await callable.call(params);
    print("✓ Cloud Function 调用成功");
    print("响应数据: ${response.data}");
  } catch (e) {
    print("✗ Cloud Function 调用失败");
    print("错误类型: ${e.runtimeType}");
    print("错误信息: $e");
    
    if (e is FirebaseFunctionsException) {
      print("Functions 异常详情:");
      print("  - 代码: ${e.code}");
      print("  - 消息: ${e.message}");
      print("  - 详情: ${e.details}");
    }
  }
  
  print("\n=== 测试完成 ===");
}