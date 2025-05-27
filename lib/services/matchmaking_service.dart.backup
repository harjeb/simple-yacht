import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/matchmaking_queue.dart';
import '../models/game_room.dart';

class MatchmakingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 匹配参数
  static const int _maxWaitTimeMinutes = 2;  // 2分钟超时
  static const int _rangeExpansionInterval = 30; // 每30秒扩大范围
  static const int _rangeExpansionAmount = 100; // 每次扩大100分
  static const int _maxRangeDifference = 500; // 最大允许500分差距

  // 加入匹配队列
  Future<void> joinQueue({
    required String playerName,
    required GameMode gameMode,
    int eloRating = 1200,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final queue = MatchmakingQueue(
      playerId: user.uid,
      playerName: playerName,
      gameMode: gameMode,
      eloRating: eloRating,
      status: MatchmakingStatus.searching,
      joinedAt: DateTime.now(),
    );

    await _firestore
        .collection('matchmakingQueue')
        .doc(user.uid)
        .set(queue.toFirestore());
  }

  // 离开匹配队列
  Future<void> leaveQueue() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('matchmakingQueue')
        .doc(user.uid)
        .delete();
  }

  // 监听匹配状态
  Stream<MatchmakingQueue?> watchMatchmakingStatus() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('matchmakingQueue')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return MatchmakingQueue.fromFirestore(doc);
    });
  }

  // 取消匹配
  Future<void> cancelMatching() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('matchmakingQueue')
        .doc(user.uid)
        .update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  // 获取当前ELO评分
  Future<int> getCurrentEloRating() async {
    final user = _auth.currentUser;
    if (user == null) return 1200;

    final doc = await _firestore
        .collection('eloRatings')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return doc.data()?['rating'] ?? 1200;
    }
    return 1200;
  }

  // 更新ELO评分（仅用于本地计算预览）
  Future<void> updateEloRating(int newRating) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('eloRatings')
        .doc(user.uid)
        .set({
      'rating': newRating,
      'gamesPlayed': FieldValue.increment(1),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 获取ELO排行榜
  Future<List<Map<String, dynamic>>> getEloLeaderboard({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('eloRatings')
        .orderBy('rating', descending: true)
        .limit(limit)
        .get();

    final leaderboard = <Map<String, dynamic>>[];
    
    for (int i = 0; i < snapshot.docs.length; i++) {
      final doc = snapshot.docs[i];
      final data = doc.data();
      
      // 获取用户名
      final userDoc = await _firestore
          .collection('users')
          .doc(doc.id)
          .get();
      
      final userName = userDoc.exists 
          ? userDoc.data()?['displayName'] ?? '未知用户'
          : '未知用户';

      leaderboard.add({
        'rank': i + 1,
        'userId': doc.id,
        'userName': userName,
        'rating': data['rating'] ?? 1200,
        'gamesPlayed': data['gamesPlayed'] ?? 0,
        'lastUpdated': data['lastUpdated'],
      });
    }

    return leaderboard;
  }

  // 计算ELO评分变化（预览）
  Map<String, int> calculateEloChange({
    required int player1Rating,
    required int player2Rating,
    required int player1Score,
    required int player2Score,
  }) {
    const int K = 32; // ELO系数

    // 计算期望得分
    final expected1 = 1 / (1 + pow(10, (player2Rating - player1Rating) / 400));
    final expected2 = 1 / (1 + pow(10, (player1Rating - player2Rating) / 400));

    // 计算实际得分（0-1之间）
    double actual1, actual2;
    if (player1Score > player2Score) {
      actual1 = 1.0;
      actual2 = 0.0;
    } else if (player1Score < player2Score) {
      actual1 = 0.0;
      actual2 = 1.0;
    } else {
      actual1 = 0.5;
      actual2 = 0.5;
    }

    // 计算新评分
    final newRating1 = (player1Rating + K * (actual1 - expected1)).round();
    final newRating2 = (player2Rating + K * (actual2 - expected2)).round();

    return {
      'player1NewRating': newRating1,
      'player2NewRating': newRating2,
      'player1Change': newRating1 - player1Rating,
      'player2Change': newRating2 - player2Rating,
    };
  }

  // 生成房间代码
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // 手动匹配（用于测试）
  Future<String> createTestMatch(String opponentId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final roomId = _generateRoomCode();
    
    // 获取用户信息
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final opponentDoc = await _firestore.collection('users').doc(opponentId).get();
    
    final userName = userDoc.exists ? userDoc.data()?['displayName'] ?? '玩家1' : '玩家1';
    final opponentName = opponentDoc.exists ? opponentDoc.data()?['displayName'] ?? '玩家2' : '玩家2';

    final gameRoom = GameRoom(
      roomId: roomId,
      hostId: user.uid,
      playerIds: [user.uid, opponentId],
      playerNames: [userName, opponentName],
      status: GameRoomStatus.ready,
      gameMode: GameMode.casual,
      maxPlayers: 2,
      createdAt: DateTime.now(),
      gameSettings: {
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

  // 获取匹配历史
  Future<List<Map<String, dynamic>>> getMatchHistory({int limit = 20}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('multiplayerGames')
        .where('playerIds', arrayContains: user.uid)
        .orderBy('startTime', descending: true)
        .limit(limit)
        .get();

    final history = <Map<String, dynamic>>[];
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      history.add({
        'gameId': doc.id,
        'gameMode': data['gameMode'],
        'status': data['status'],
        'startTime': data['startTime'],
        'endTime': data['endTime'],
        'playerNames': data['playerNames'],
        'finalScores': data['finalScores'],
        'winnerId': data['winnerId'],
        'isWinner': data['winnerId'] == user.uid,
      });
    }

    return history;
  }

  // 获取匹配统计
  Future<Map<String, dynamic>> getMatchStats() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final snapshot = await _firestore
        .collection('multiplayerGames')
        .where('playerIds', arrayContains: user.uid)
        .where('status', isEqualTo: 'completed')
        .get();

    int totalGames = snapshot.docs.length;
    int wins = 0;
    int totalScore = 0;
    int highestScore = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final finalScores = Map<String, dynamic>.from(data['finalScores'] ?? {});
      final userScore = finalScores[user.uid] ?? 0;
      
      totalScore += userScore as int;
      if (userScore > highestScore) {
        highestScore = userScore as int;
      }
      
      if (data['winnerId'] == user.uid) {
        wins++;
      }
    }

    final winRate = totalGames > 0 ? (wins / totalGames * 100).round() : 0;
    final avgScore = totalGames > 0 ? (totalScore / totalGames).round() : 0;

    return {
      'totalGames': totalGames,
      'wins': wins,
      'losses': totalGames - wins,
      'winRate': winRate,
      'averageScore': avgScore,
      'highestScore': highestScore,
    };
  }
}
