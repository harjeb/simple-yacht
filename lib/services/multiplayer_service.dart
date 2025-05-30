import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_room.dart';
import '../models/game_enums.dart';

class MultiplayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 创建游戏房间
  Future<String> createRoom({
    required String roomName,
    required GameMode gameMode,
    Map<String, dynamic>? gameSettings,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    // 生成房间ID
    final roomId = _generateRoomId();
    
    final gameRoom = GameRoom(
      id: roomId,
      hostId: user.uid,
      gameMode: gameMode,
      status: GameRoomStatus.waiting,
      createdAt: DateTime.now(),
      gameState: gameSettings ?? {},
    );

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .set(gameRoom.toMap());

    return roomId;
  }

  // 加入游戏房间
  Future<void> joinRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomDoc = await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .get();

    if (!roomDoc.exists) {
      throw Exception('房间不存在');
    }

    final roomData = roomDoc.data()!;
    final gameRoom = GameRoom.fromMap(roomData, roomId);

    if (gameRoom.status != GameRoomStatus.waiting) {
      throw Exception('房间已满或游戏已开始');
    }

    if (gameRoom.guestId != null) {
      throw Exception('房间已满');
    }

    // 更新房间信息
    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
          'guestId': user.uid,
          'status': GameRoomStatus.waiting.toString().split('.').last,
        });
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

    final roomData = roomDoc.data()!;
    final gameRoom = GameRoom.fromMap(roomData, roomId);

    if (gameRoom.hostId == user.uid) {
      // 房主离开，删除房间
      await _firestore
          .collection('gameRooms')
          .doc(roomId)
          .delete();
    } else if (gameRoom.guestId == user.uid) {
      // 客人离开，重置房间状态
      await _firestore
          .collection('gameRooms')
          .doc(roomId)
          .update({
            'guestId': null,
            'status': GameRoomStatus.waiting.toString().split('.').last,
          });
    }
  }

  // 开始游戏
  Future<void> startGame(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomDoc = await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .get();

    if (!roomDoc.exists) {
      throw Exception('房间不存在');
    }

    final roomData = roomDoc.data()!;
    final gameRoom = GameRoom.fromMap(roomData, roomId);

    if (gameRoom.hostId != user.uid) {
      throw Exception('只有房主可以开始游戏');
    }

    if (gameRoom.guestId == null) {
      throw Exception('等待其他玩家加入');
    }

    // 更新房间状态为游戏中
    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
          'status': GameRoomStatus.playing.toString().split('.').last,
          'startedAt': FieldValue.serverTimestamp(),
        });
  }

  // 监听房间状态
  Stream<GameRoom?> watchRoom(String roomId) {
    return _firestore
        .collection('gameRooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return GameRoom.fromMap(doc.data()!, doc.id);
        });
  }

  // 更新游戏状态
  Future<void> updateGameState(String roomId, Map<String, dynamic> gameState) async {
    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
          'gameState': gameState,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
  }

  // 结束游戏
  Future<void> endGame(String roomId, Map<String, dynamic> finalResults) async {
    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
          'status': GameRoomStatus.finished.toString().split('.').last,
          'endedAt': FieldValue.serverTimestamp(),
          'finalResults': finalResults,
        });
  }

  // 获取可用房间列表
  Future<List<GameRoom>> getAvailableRooms({GameMode? gameMode}) async {
    Query query = _firestore
        .collection('gameRooms')
        .where('status', isEqualTo: GameRoomStatus.waiting.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .limit(20);

    if (gameMode != null) {
      query = query.where('gameMode', isEqualTo: gameMode.toString().split('.').last);
    }

    final snapshot = await query.get();
    
    return snapshot.docs
        .map((doc) => GameRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // 通过房间码加入房间
  Future<void> joinRoomByCode(String roomCode) async {
    final snapshot = await _firestore
        .collection('gameRooms')
        .where('roomCode', isEqualTo: roomCode)
        .where('status', isEqualTo: GameRoomStatus.waiting.toString().split('.').last)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('房间码无效或房间不存在');
    }

    final roomId = snapshot.docs.first.id;
    await joinRoom(roomId);
  }

  // 生成房间ID - 6位16进制字符
  String _generateRoomId() {
    const chars = '0123456789ABCDEF';
    final random = DateTime.now().millisecondsSinceEpoch;
    String roomId = '';
    
    // 生成6位16进制字符
    for (int i = 0; i < 6; i++) {
      final index = (random + i * 7) % chars.length;
      roomId += chars[index];
    }
    
    return roomId;
  }

  // 生成房间码
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    
    return code;
  }

  // 设置玩家准备状态
  Future<void> setPlayerReady(String roomId, bool isReady) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
          'playerReadyStatus.${user.uid}': isReady,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
  }

  // 踢出玩家（仅房主）
  Future<void> kickPlayer(String roomId, String playerId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomDoc = await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .get();

    if (!roomDoc.exists) {
      throw Exception('房间不存在');
    }

    final roomData = roomDoc.data()!;
    final gameRoom = GameRoom.fromMap(roomData, roomId);

    if (gameRoom.hostId != user.uid) {
      throw Exception('只有房主可以踢出玩家');
    }

    if (gameRoom.guestId == playerId) {
      await _firestore
          .collection('gameRooms')
          .doc(roomId)
          .update({
            'guestId': null,
            'status': GameRoomStatus.waiting.toString().split('.').last,
            'playerReadyStatus.$playerId': FieldValue.delete(),
          });
    }
  }

  // 发送游戏动作
  Future<void> sendGameAction(String roomId, Map<String, dynamic> action) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .collection('actions')
        .add({
          'playerId': user.uid,
          'action': action,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  // 监听游戏动作
  Stream<List<Map<String, dynamic>>> watchGameActions(String roomId) {
    return _firestore
        .collection('gameRooms')
        .doc(roomId)
        .collection('actions')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }
} 