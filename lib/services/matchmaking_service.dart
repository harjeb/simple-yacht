import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/matchmaking_queue.dart';
import '../models/game_room.dart';
import '../models/game_enums.dart';

class MatchmakingService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Constructor for dependency injection
  MatchmakingService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const int _maxWaitTimeMinutes = 2;
  static const int _rangeExpansionInterval = 30;
  static const int _rangeExpansionAmount = 100;
  static const int _maxRangeDifference = 500;

  Future<void> joinQueue({
    required String playerName,
    required GameMode gameMode,
    int eloRating = 1000,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

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

  int calculateCurrentEloRange(DateTime joinedAt) {
    final waitTimeSeconds = DateTime.now().difference(joinedAt).inSeconds;
    final intervals = waitTimeSeconds ~/ _rangeExpansionInterval;
    const baseRange = 100;
    final expansion = intervals * _rangeExpansionAmount;
    return min(baseRange + expansion, _maxRangeDifference);
  }

  bool isMatchmakingTimeout(DateTime joinedAt) {
    final waitTimeMinutes = DateTime.now().difference(joinedAt).inMinutes;
    return waitTimeMinutes >= _maxWaitTimeMinutes;
  }

  Future<void> leaveQueue() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('matchmakingQueue')
        .doc(user.uid)
        .delete();
  }

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

  Future<int> getCurrentEloRating() async {
    final user = _auth.currentUser;
    if (user == null) return 1000;

    final doc = await _firestore
        .collection('eloRatings')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return doc.data()?['rating'] ?? 1000;
    }
    return 1000;
  }

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
      
      final userDoc = await _firestore
          .collection('users')
          .doc(doc.id)
          .get();
      
      final userName = userDoc.exists 
          ? (userDoc.data()?['displayName'] ?? 'Unknown User')
          : 'Unknown User';

      leaderboard.add({
        'rank': i + 1,
        'userId': doc.id,
        'userName': userName,
        'rating': data['rating'] ?? 1000,
        'gamesPlayed': data['gamesPlayed'] ?? 0,
        'lastUpdated': data['lastUpdated'],
      });
    }

    return leaderboard;
  }

  Map<String, int> calculateEloChange({
    required int player1Rating,
    required int player2Rating,
    required int player1Score,
    required int player2Score,
  }) {
    const int K = 32;

    final expected1 = 1 / (1 + pow(10, (player2Rating - player1Rating) / 400));
    final expected2 = 1 / (1 + pow(10, (player1Rating - player2Rating) / 400));

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

    final newRating1 = (player1Rating + K * (actual1 - expected1)).round();
    final newRating2 = (player2Rating + K * (actual2 - expected2)).round();

    return {
      'player1NewRating': newRating1,
      'player2NewRating': newRating2,
      'player1Change': newRating1 - player1Rating,
      'player2Change': newRating2 - player2Rating,
    };
  }

  String _generateRoomCode() {
    const hexChars = "0123456789ABCDEF";
    final random = Random.secure(); // 使用加密安全的随机数生成器
    final roomCodeBuilder = StringBuffer();

    for (int i = 0; i < 6; i++) {
      final randomIndex = random.nextInt(hexChars.length);
      roomCodeBuilder.write(hexChars[randomIndex]);
    }

    return roomCodeBuilder.toString();
  }

  Future<String> createTestMatch(String opponentId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final roomId = _generateRoomCode();
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final opponentDoc = await _firestore.collection('users').doc(opponentId).get();
    
    final userName = userDoc.exists ? (userDoc.data()?['displayName'] ?? 'Player 1') : 'Player 1';
    final opponentName = opponentDoc.exists ? (opponentDoc.data()?['displayName'] ?? 'Player 2') : 'Player 2';

    final gameRoom = GameRoom(
      id: roomId,
      hostId: user.uid,
      guestId: opponentId,
      gameMode: GameMode.multiplayer,
      status: GameRoomStatus.waiting,
      createdAt: DateTime.now(),
      gameState: {
        'timeLimit': 15 * 60 * 1000,
        'rounds': 13,
        'hostName': userName,
        'guestName': opponentName,
      },
    );

    await _firestore
        .collection('gameRooms')
        .doc(roomId)
        .set(gameRoom.toMap());

    return roomId;
  }

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