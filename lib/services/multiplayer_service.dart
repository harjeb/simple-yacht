import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_room.dart';
import '../models/game_enums.dart';
import '../models/multiplayer_game_state.dart';
import '../core_logic/game_state.dart';

class MultiplayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 创建游戏房间
  Future<String> createRoom({
    required GameMode gameMode,
    Map<String, dynamic>? gameSettings,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    // 获取用户信息
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userName = userDoc.exists 
        ? userDoc.data()?['displayName'] ?? '未知用户'
        : '未知用户';

    final roomId = _generateRoomCode();
    
    final gameRoom = GameRoom(
      id: roomId,
      hostId: user.uid,
      gameMode: gameMode,
      status: GameRoomStatus.waiting,
      createdAt: DateTime.now(),
      gameState: gameSettings ?? {
        'timeLimit': 15 * 60 * 1000, // 15分钟
        'rounds': 13,
        'hostName': userName,
      },
    );

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .set(gameRoom.toMap());

    return roomId;
  }

  // 加入游戏房间
  Future<bool> joinRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomDoc = await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .get();

    if (!roomDoc.exists) {
      throw Exception('房间不存在');
    }

    final room = GameRoom.fromFirestore(roomDoc);

    if (room.isFull) {
      throw Exception('房间已满');
    }

    if (room.containsPlayer(user.uid)) {
      return true; // 已经在房间中
    }

    // 获取用户信息
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userName = userDoc.exists 
        ? userDoc.data()?['displayName'] ?? '未知用户'
        : '未知用户';

    // 更新房间信息 - 添加客人
    final updatedGameState = Map<String, dynamic>.from(room.gameState ?? {});
    updatedGameState['guestName'] = userName;

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
      'guestId': user.uid,
      'status': GameRoomStatus.waiting.name,
      'gameState': updatedGameState,
    });

    return true;
  }

  // 离开游戏房间
  Future<void> leaveRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final roomDoc = await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .get();

    if (!roomDoc.exists) return;

    final room = GameRoom.fromFirestore(roomDoc);

    if (!room.containsPlayer(user.uid)) return;

    if (room.hostId == user.uid) {
      // 房主离开，删除房间
      await _firestore.collection('gameRooms').doc(roomId).delete();
    } else {
      // 客人离开，清除客人信息
      final updatedGameState = Map<String, dynamic>.from(room.gameState ?? {});
      updatedGameState.remove('guestName');

      await _firestore
          .collection('gameRooms')
          .doc(roomId)
          .update({
        'guestId': null,
        'status': GameRoomStatus.waiting.name,
        'gameState': updatedGameState,
      });
    }
  }

  // 开始游戏
  Future<String> startGame(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomDoc = await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .get();

    if (!roomDoc.exists) {
      throw Exception('房间不存在');
    }

    final room = GameRoom.fromFirestore(roomDoc);

    if (room.hostId != user.uid) {
      throw Exception('只有房主可以开始游戏');
    }

    if (!room.canStart) {
      throw Exception('房间状态不正确或玩家未满');
    }

    // 更新房间状态为游戏中
    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
      'status': GameRoomStatus.playing.name,
      'startedAt': FieldValue.serverTimestamp(),
    });

    return roomId;
  }

  // 结束游戏
  Future<void> finishGame(String roomId, Map<String, int> finalScores) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
      'status': GameRoomStatus.finished.name,
      'finishedAt': FieldValue.serverTimestamp(),
      'scores': finalScores,
    });
  }

  // 监听游戏房间状态
  Stream<GameRoom?> watchRoom(String roomId) {
    return _firestore
        .collection('gameRooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return GameRoom.fromFirestore(doc);
    });
  }

  // 获取房间信息
  Future<GameRoom?> getRoom(String roomId) async {
    final doc = await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .get();

    if (!doc.exists) return null;
    return GameRoom.fromFirestore(doc);
  }

  // 获取用户创建的房间列表
  Future<List<GameRoom>> getUserRooms() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('gameRooms')
        .where('hostId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => GameRoom.fromFirestore(doc))
        .toList();
  }

  // 获取用户参与的房间列表
  Future<List<GameRoom>> getJoinedRooms() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('gameRooms')
        .where('guestId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => GameRoom.fromFirestore(doc))
        .toList();
  }

  // 生成房间代码
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // 清理过期房间
  Future<void> cleanupExpiredRooms() async {
    final cutoffTime = DateTime.now().subtract(Duration(hours: 24));
    
    final snapshot = await _firestore
        .collection('gameRooms')
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoffTime))
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}
