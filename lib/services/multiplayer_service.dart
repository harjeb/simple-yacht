import 'dart:async';
import 'dart:math'; // For Random.secure()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_room.dart';
import '../models/game_enums.dart';

class MultiplayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 创建游戏房间
  Future<String> createRoom({
    // required String roomName, // roomName seems unused in GameRoom model
    required GameMode gameMode,
    Map<String, dynamic>? gameSettings,
    String? roomCode, 
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomId = _firestore.collection('gameRooms').doc().id; 
    final finalRoomCode = roomCode ?? _generateRoomCode(); 

    final gameRoom = GameRoom(
      id: roomId,
      roomCode: finalRoomCode, 
      hostId: user.uid,
      gameMode: gameMode,
      status: GameRoomStatus.waiting,
      createdAt: DateTime.now(),
      gameState: gameSettings ?? {},
      scores: {}, 
      playerNames: {user.uid: user.displayName ?? '房主'}, 
      playerElos: {}, 
    );

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .set(gameRoom.toMap());

    return roomId; 
  }

  // 加入游戏房间 (使用事务)
  Future<void> joinRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomDocRef = _firestore.collection('gameRooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomDocRef);

      if (!roomSnapshot.exists) {
        throw Exception('房间不存在');
      }

      final roomData = roomSnapshot.data()!;
      final gameRoom = GameRoom.fromMap(roomData, roomId); 

      if (gameRoom.hostId == user.uid) {
        return; 
      }

      if (gameRoom.status != GameRoomStatus.waiting) {
        throw Exception('房间已满或游戏已开始');
      }

      if (gameRoom.guestId != null && gameRoom.guestId != user.uid) { 
        throw Exception('房间已满');
      }
      
      if (gameRoom.guestId == user.uid) { 
        return;
      }


      transaction.update(roomDocRef, {
        'guestId': user.uid,
        'status': GameRoomStatus.waiting.name, 
        'playerNames.${user.uid}': user.displayName ?? '访客', 
      });
    });
  }

  // 离开游戏房间
  Future<void> leaveRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final roomDocRef = _firestore.collection('gameRooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomDocRef);

      if (!roomSnapshot.exists) return; 

      final roomData = roomSnapshot.data()!;
      final gameRoom = GameRoom.fromMap(roomData, roomId);

      if (gameRoom.hostId == user.uid) {
        transaction.update(roomDocRef, {
          'status': GameRoomStatus.cancelled.name, 
          'guestId': null,
        });
      } else if (gameRoom.guestId == user.uid) {
        transaction.update(roomDocRef, {
          'guestId': null,
          'status': GameRoomStatus.waiting.name, 
          'playerNames.${user.uid}': FieldValue.delete(), 
          'playerReadyStatus.${user.uid}': FieldValue.delete(), 
        });
      }
    });
  }

  // 开始游戏
  Future<void> startGame(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomDocRef = _firestore.collection('gameRooms').doc(roomId);
    
    await _firestore.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomDocRef);

      if (!roomSnapshot.exists) {
        throw Exception('房间不存在');
      }

      final roomData = roomSnapshot.data()!;
      final gameRoom = GameRoom.fromMap(roomData, roomId);

      if (gameRoom.hostId != user.uid) {
        throw Exception('只有房主可以开始游戏');
      }

      if (gameRoom.guestId == null) {
        throw Exception('等待其他玩家加入');
      }
      
      transaction.update(roomDocRef, {
        'status': GameRoomStatus.playing.name, 
        'startedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // 监听房间状态
  Stream<GameRoom?> watchRoom(String roomId) {
    return _firestore
        .collection('gameRooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return GameRoom.fromMap(doc.data()!, doc.id);
        });
  }

  // 更新游戏状态
  Future<void> updateGameState(String roomId, Map<String, dynamic> gameStateUpdates) async {
    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
          'gameState': gameStateUpdates, 
          'lastUpdated': FieldValue.serverTimestamp(),
        });
  }

  // 结束游戏
  Future<void> endGame(String roomId, Map<String, dynamic> finalResults) async {
    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
          'status': GameRoomStatus.finished.name, 
          'endedAt': FieldValue.serverTimestamp(),
          'finalResults': finalResults, 
        });
  }

  // 获取可用房间列表
  Future<List<GameRoom>> getAvailableRooms({GameMode? gameMode, int limit = 20}) async {
    Query query = _firestore
        .collection('gameRooms')
        .where('status', isEqualTo: GameRoomStatus.waiting.name) 
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (gameMode != null) {
      query = query.where('gameMode', isEqualTo: gameMode.name); 
    }

    final snapshot = await query.get();
    
    return snapshot.docs
        .map((doc) => GameRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // 通过房间码加入房间
  Future<void> joinRoomByCode(String roomCode) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final querySnapshot = await _firestore
        .collection('gameRooms')
        .where('roomCode', isEqualTo: roomCode) 
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('房间码无效或房间不存在');
    }

    final roomDoc = querySnapshot.docs.first;
    final gameRoom = GameRoom.fromMap(roomDoc.data(), roomDoc.id);

    if (gameRoom.status != GameRoomStatus.waiting) {
      throw Exception('房间已满或游戏已开始');
    }
    if (gameRoom.guestId != null && gameRoom.guestId != user.uid) { 
        throw Exception('房间已满');
    }
    if (gameRoom.hostId == user.uid) {
        return; 
    }
    await joinRoom(roomDoc.id); 
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'; 
    final random = Random.secure();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    return code;
  }

  // 设置玩家准备状态
  Future<void> setPlayerReady(String roomId, bool isReady) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final fieldPath = FieldPath(['playerReadyStatus', user.uid]);

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
          fieldPath: isReady,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
  }

  // 踢出玩家（仅房主）
  Future<void> kickPlayer(String roomId, String playerIdToKick) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomDocRef = _firestore.collection('gameRooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomDocRef);

      if (!roomSnapshot.exists) {
        throw Exception('房间不存在');
      }
      final roomData = roomSnapshot.data()!;
      final gameRoom = GameRoom.fromMap(roomData, roomId);

      if (gameRoom.hostId != user.uid) {
        throw Exception('只有房主可以踢出玩家');
      }

      if (gameRoom.guestId == playerIdToKick) {
        transaction.update(roomDocRef, {
          'guestId': null,
          'status': GameRoomStatus.waiting.name, 
          'playerNames.$playerIdToKick': FieldValue.delete(), 
          'playerReadyStatus.$playerIdToKick': FieldValue.delete(), 
          'playerElos.$playerIdToKick': FieldValue.delete(), 
        });
      } else {
        throw Exception('无法踢出指定的玩家');
      }
    });
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
          'actionType': action['type'], 
          'actionData': action['data'], 
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  // 监听游戏动作
  Stream<List<Map<String, dynamic>>> watchGameActions(String roomId) {
    return _firestore
        .collection('gameRooms')
        .doc(roomId)
        .collection('actions')
        .orderBy('timestamp', descending: false) 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id, 
                  ...doc.data(),
                })
            .toList());
  }
}