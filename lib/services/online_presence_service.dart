import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnlinePresenceService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _currentUserId;
  DatabaseReference? _userPresenceRef;
  DatabaseReference? _onlineCountRef;

  // 设置用户在线状态
  Future<void> goOnline() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _currentUserId = user.uid;
    _userPresenceRef = _database.child('online_users/${user.uid}');
    _onlineCountRef = _database.child('online_users_count');

    // 设置在线状态
    await _userPresenceRef!.set({
      'online': true,
      'lastSeen': ServerValue.timestamp,
    });

    // 设置离线时的自动清理
    await _userPresenceRef!.onDisconnect().remove();
    
    // 更新在线人数计数器
    await _onlineCountRef!.set(ServerValue.increment(1));
    await _onlineCountRef!.onDisconnect().set(ServerValue.increment(-1));

    print('用户 ${user.uid} 已设置为在线状态');
  }

  // 手动设置离线状态
  Future<void> goOffline() async {
    if (_currentUserId == null) return;

    try {
      // 移除在线状态
      await _userPresenceRef?.remove();
      
      // 减少在线人数
      await _onlineCountRef?.set(ServerValue.increment(-1));
      
      print('用户 $_currentUserId 已设置为离线状态');
    } catch (e) {
      print('设置离线状态失败: $e');
    }

    _currentUserId = null;
    _userPresenceRef = null;
    _onlineCountRef = null;
  }

  // 监听在线用户数量
  Stream<int> watchOnlineUsersCount() {
    return _database.child('online_users_count').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return 0;
    });
  }

  // 监听在线用户列表
  Stream<Map<String, dynamic>> watchOnlineUsers() {
    return _database.child('online_users').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return <String, dynamic>{};
    });
  }

  // 清理所有在线状态（管理员功能）
  Future<void> clearAllOnlineStatus() async {
    await _database.child('online_users').remove();
    await _database.child('online_users_count').set(0);
    print('已清理所有在线状态');
  }
} 