import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_room.dart';
import '../models/multiplayer_game_state.dart';
import '../core_logic/game_state.dart';

class MultiplayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 创建游戏房间
  Future<String> createRoom({
    required GameMode gameMode,
    int maxPlayers = 2,
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
      roomId: roomId,
      hostId: user.uid,
      playerIds: [user.uid],
      playerNames: [userName],
      status: GameRoomStatus.waiting,
      gameMode: gameMode,
      maxPlayers: maxPlayers,
      createdAt: DateTime.now(),
      gameSettings: gameSettings ?? {
        'timeLimit': 15 * 60 * 1000, // 15分钟
        'rounds': 13,
      },
    );

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .set(gameRoom.toFirestore());

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

    // 更新房间信息
    final updatedPlayerIds = [...room.playerIds, user.uid];
    final updatedPlayerNames = [...room.playerNames, userName];
    final newStatus = updatedPlayerIds.length >= room.maxPlayers 
        ? GameRoomStatus.ready 
        : GameRoomStatus.waiting;

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
      'playerIds': updatedPlayerIds,
      'playerNames': updatedPlayerNames,
      'status': newStatus.toString().split('.').last,
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

    final updatedPlayerIds = room.playerIds.where((id) => id != user.uid).toList();
    final updatedPlayerNames = [...room.playerNames];
    
    // 找到用户在列表中的位置并移除对应的名字
    final userIndex = room.playerIds.indexOf(user.uid);
    if (userIndex >= 0 && userIndex < updatedPlayerNames.length) {
      updatedPlayerNames.removeAt(userIndex);
    }

    if (updatedPlayerIds.isEmpty) {
      // 房间为空，删除房间
      await _firestore.collection('gameRooms').doc(roomId).delete();
    } else {
      // 更新房间信息
      String newHostId = room.hostId;
      if (room.hostId == user.uid) {
        // 如果离开的是房主，选择新房主
        newHostId = updatedPlayerIds.first;
      }

      await _firestore
          .collection('gameRooms')
          .doc(roomId)
          .update({
        'hostId': newHostId,
        'playerIds': updatedPlayerIds,
        'playerNames': updatedPlayerNames,
        'status': GameRoomStatus.waiting.toString().split('.').last,
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

    if (!room.isHost(user.uid)) {
      throw Exception('只有房主可以开始游戏');
    }

    if (room.status != GameRoomStatus.ready) {
      throw Exception('房间状态不正确');
    }

    // 创建多人游戏状态
    final gameId = _generateGameId();
    final multiplayerGame = MultiplayerGameState(
      gameId: gameId,
      playerIds: room.playerIds,
      playerNames: Map.fromIterables(room.playerIds, room.playerNames),
      status: MultiplayerGameStatus.waiting,
      gameMode: room.gameMode.toString().split('.').last,
      startTime: DateTime.now(),
      timeLimit: room.gameSettings['timeLimit'] ?? 15 * 60 * 1000,
      playerGameStates: {},
      finalScores: {},
      playerReady: Map.fromIterable(
        room.playerIds,
        key: (id) => id,
        value: (_) => false,
      ),
      lastActivity: Map.fromIterable(
        room.playerIds,
        key: (id) => id,
        value: (_) => DateTime.now(),
      ),
    );

    // 保存多人游戏状态
    await _firestore
        .collection('multiplayerGames')
        .doc(gameId)
        .set(multiplayerGame.toFirestore());

    // 更新房间状态
    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .update({
      'status': GameRoomStatus.playing.toString().split('.').last,
      'gameId': gameId,
    });

    return gameId;
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

  // 监听多人游戏状态
  Stream<MultiplayerGameState?> watchMultiplayerGame(String gameId) {
    return _firestore
        .collection('multiplayerGames')
        .doc(gameId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return MultiplayerGameState.fromFirestore(doc);
    });
  }

  // 设置玩家准备状态
  Future<void> setPlayerReady(String gameId, bool ready) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('multiplayerGames')
        .doc(gameId)
        .update({
      'playerReady.${user.uid}': ready,
      'lastActivity.${user.uid}': FieldValue.serverTimestamp(),
    });
  }

  // 更新玩家游戏状态
  Future<void> updatePlayerGameState(String gameId, GameState gameState) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('multiplayerGames')
        .doc(gameId)
        .update({
      'playerGameStates.${user.uid}': gameState.toMap(),
      'lastActivity.${user.uid}': FieldValue.serverTimestamp(),
    });
  }

  // 完成游戏
  Future<void> completeGame(String gameId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final gameDoc = await _firestore
        .collection('multiplayerGames')
        .doc(gameId)
        .get();

    if (!gameDoc.exists) return;

    final game = MultiplayerGameState.fromFirestore(gameDoc);
    
    // 计算最终得分
    final finalScores = <String, int>{};
    String? winnerId;
    int highestScore = -1;

    game.playerGameStates.forEach((playerId, gameState) {
      final score = gameState.totalScore;
      finalScores[playerId] = score;
      
      if (score > highestScore) {
        highestScore = score;
        winnerId = playerId;
      }
    });

    // 更新游戏状态
    await _firestore
        .collection('multiplayerGames')
        .doc(gameId)
        .update({
      'status': MultiplayerGameStatus.completed.toString().split('.').last,
      'endTime': FieldValue.serverTimestamp(),
      'finalScores': finalScores,
      'winnerId': winnerId,
    });
  }

  // 放弃游戏
  Future<void> abandonGame(String gameId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('multiplayerGames')
        .doc(gameId)
        .update({
      'status': MultiplayerGameStatus.abandoned.toString().split('.').last,
      'endTime': FieldValue.serverTimestamp(),
      'abandonedBy': user.uid,
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

  // 获取多人游戏信息
  Future<MultiplayerGameState?> getMultiplayerGame(String gameId) async {
    final doc = await _firestore
        .collection('multiplayerGames')
        .doc(gameId)
        .get();

    if (!doc.exists) return null;
    return MultiplayerGameState.fromFirestore(doc);
  }

  // 生成房间代码
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // 生成游戏ID
  String _generateGameId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString().padLeft(3, '0');
  }

  // 检查房间代码是否有效
  Future<bool> isValidRoomCode(String roomCode) async {
    final doc = await _firestore
        .collection('gameRooms')
        .doc(roomCode.toUpperCase())
        .get();
    
    return doc.exists;
  }

  // 获取用户当前的游戏房间
  Future<GameRoom?> getCurrentRoom() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('gameRooms')
        .where('playerIds', arrayContains: user.uid)
        .where('status', whereIn: ['waiting', 'ready', 'playing'])
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return GameRoom.fromFirestore(snapshot.docs.first);
  }

  // 获取用户当前的多人游戏
  Future<MultiplayerGameState?> getCurrentMultiplayerGame() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('multiplayerGames')
        .where('playerIds', arrayContains: user.uid)
        .where('status', whereIn: ['waiting', 'playing'])
        .orderBy('startTime', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return MultiplayerGameState.fromFirestore(snapshot.docs.first);
  }
}
