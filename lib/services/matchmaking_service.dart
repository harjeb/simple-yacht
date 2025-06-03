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

    final queueEntry = MatchmakingQueue(
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
        .set(queueEntry.toFirestore());

    await _findMatchAndCreateRoom(queueEntry);
  }

  Future<void> _findMatchAndCreateRoom(MatchmakingQueue currentUserQueueEntry) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.runTransaction((transaction) async {
      final currentUserDocRef = _firestore.collection('matchmakingQueue').doc(currentUser.uid);
      final currentUserSnapshot = await transaction.get(currentUserDocRef);

      if (!currentUserSnapshot.exists) {
        return;
      }
      final freshCurrentUserQueueEntry = MatchmakingQueue.fromFirestore(currentUserSnapshot);
      if (freshCurrentUserQueueEntry.status != MatchmakingStatus.searching) {
        return;
      }

      final querySnapshot = await _firestore
          .collection('matchmakingQueue')
          .where('status', isEqualTo: MatchmakingStatus.searching.name) 
          .where('gameMode', isEqualTo: currentUserQueueEntry.gameMode.name) 
          .orderBy('joinedAt')
          .get();

      MatchmakingQueue? opponentQueueEntry;
      DocumentReference? opponentDocRef;

      for (final doc in querySnapshot.docs) {
        if (doc.id == currentUser.uid) continue; 

        final potentialOpponent = MatchmakingQueue.fromFirestore(doc);
        final eloDiff = (currentUserQueueEntry.eloRating - potentialOpponent.eloRating).abs();
        final currentUserEloRange = calculateCurrentEloRange(freshCurrentUserQueueEntry.joinedAt, freshCurrentUserQueueEntry.eloRating);
        final opponentEloRange = calculateCurrentEloRange(potentialOpponent.joinedAt, potentialOpponent.eloRating);
        
        if (eloDiff <= currentUserEloRange && eloDiff <= opponentEloRange) {
          opponentQueueEntry = potentialOpponent;
          opponentDocRef = doc.reference;
          break;
        }
      }

      if (opponentQueueEntry != null && opponentDocRef != null) {
        final roomId = await _createRoomForMatch(
          transaction,
          freshCurrentUserQueueEntry, 
          opponentQueueEntry,
        );

        if (roomId != null) {
          transaction.update(currentUserDocRef, {
            'status': MatchmakingStatus.matched.name,
            'roomId': roomId, 
            'matchedAt': FieldValue.serverTimestamp(),
          });
          transaction.update(opponentDocRef, {
            'status': MatchmakingStatus.matched.name,
            'roomId': roomId, 
            'matchedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  Future<String?> _createRoomForMatch(
    Transaction transaction,
    MatchmakingQueue player1Queue,
    MatchmakingQueue player2Queue,
  ) async {
    final roomCode = _generateRoomCode(); 
    final roomId = _firestore.collection('gameRooms').doc().id; 

    final gameRoom = GameRoom(
      id: roomId,
      roomCode: roomCode, 
      hostId: player1Queue.playerId,
      guestId: player2Queue.playerId, 
      gameMode: player1Queue.gameMode,
      status: GameRoomStatus.waiting, 
      createdAt: DateTime.now(),
      playerNames: { 
        player1Queue.playerId: player1Queue.playerName,
        player2Queue.playerId: player2Queue.playerName,
      },
      playerElos: {  
        player1Queue.playerId: player1Queue.eloRating,
        player2Queue.playerId: player2Queue.eloRating,
      },
      gameState: {}, 
      scores: {}, 
    );

    final roomDocRef = _firestore.collection('gameRooms').doc(roomId);
    transaction.set(roomDocRef, gameRoom.toMap());
    return roomId;
  }


  int calculateCurrentEloRange(DateTime joinedAt, int baseElo) {
    final waitTimeSeconds = DateTime.now().difference(joinedAt).inSeconds;
    final nonNegativeWaitTime = max(0, waitTimeSeconds);
    final intervals = nonNegativeWaitTime ~/ _rangeExpansionInterval;
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
          if (!doc.exists || doc.data() == null) return null;
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
          'status': MatchmakingStatus.cancelled.name, 
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

    if (doc.exists && doc.data() != null) {
      return doc.data()!['rating'] as int? ?? 1000;
    }
    return 1000;
  }

  Future<void> updateEloRating(String userId, int newRating, bool wonGame) async {
    await _firestore
        .collection('eloRatings') 
        .doc(userId)
        .set({
          'rating': newRating,
          'gamesPlayed': FieldValue.increment(1),
          'wins': wonGame ? FieldValue.increment(1) : FieldValue.increment(0),
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
      
      final userDoc = await _firestore.collection('users').doc(doc.id).get();
      final userName = userDoc.exists && userDoc.data() != null
          ? (userDoc.data()!['displayName'] as String? ?? 'Unknown User')
          : 'Unknown User';

      leaderboard.add({
        'rank': i + 1,
        'userId': doc.id,
        'userName': userName,
        'rating': data['rating'] as int? ?? 1000,
        'gamesPlayed': data['gamesPlayed'] as int? ?? 0,
        'wins': data['wins'] as int? ?? 0, 
        'lastUpdated': data['lastUpdated'] as Timestamp?,
      });
    }
    return leaderboard;
  }


  Map<String, int> calculateEloChange({
    required int player1Rating,
    required int player2Rating,
    required bool player1Won, 
  }) {
    const int K = 32; 

    final expectedScore1 = 1 / (1 + pow(10, (player2Rating - player1Rating) / 400));
    final expectedScore2 = 1 / (1 + pow(10, (player1Rating - player2Rating) / 400));

    double actualScore1;
    double actualScore2;

    if (player1Won) {
      actualScore1 = 1.0; 
      actualScore2 = 0.0; 
    } else {
      actualScore1 = 0.0; 
      actualScore2 = 1.0; 
    }

    final newRating1 = (player1Rating + K * (actualScore1 - expectedScore1)).round();
    final newRating2 = (player2Rating + K * (actualScore2 - expectedScore2)).round();

    return {
      'player1NewRating': newRating1,
      'player2NewRating': newRating2,
      'player1Change': newRating1 - player1Rating,
      'player2Change': newRating2 - player2Rating,
    };
  }

  String _generateRoomCode() {
    const hexChars = "0123456789ABCDEF";
    final random = Random.secure();
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

    final roomCode = _generateRoomCode(); 
    final roomId = _firestore.collection('gameRooms').doc().id;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final opponentDoc = await _firestore.collection('users').doc(opponentId).get();
    
    final userName = userDoc.exists && userDoc.data() != null ? (userDoc.data()!['displayName'] as String? ?? 'Player 1') : 'Player 1';
    final opponentName = opponentDoc.exists && opponentDoc.data() != null ? (opponentDoc.data()!['displayName'] as String? ?? 'Player 2') : 'Player 2';

    final gameRoom = GameRoom(
      id: roomId,
      roomCode: roomCode,  
      hostId: user.uid,
      guestId: opponentId, 
      gameMode: GameMode.multiplayer, 
      status: GameRoomStatus.waiting,
      createdAt: DateTime.now(),
      playerNames: { 
        user.uid: userName,
        opponentId: opponentName,
      },
      gameState: {}, 
      scores: {}, 
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
        .orderBy('endTime', descending: true) 
        .limit(limit)
        .get();

    final history = <Map<String, dynamic>>[];
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      history.add({
        'gameId': doc.id,
        'gameMode': data['gameMode'] != null ? GameMode.values.byName(data['gameMode'] as String) : GameMode.single, 
        'status': data['status'] != null ? GameRoomStatus.values.byName(data['status'] as String) : GameRoomStatus.cancelled, 
        'startTime': data['startTime'] as Timestamp?,
        'endTime': data['endTime'] as Timestamp?,
        'playerNames': Map<String, String>.from(data['playerNames'] as Map? ?? {}),
        'finalScores': Map<String, int>.from(data['finalScores'] as Map? ?? {}),
        'winnerId': data['winnerId'] as String?,
        'isWinner': data['winnerId'] == user.uid,
        'eloChange': data['eloChanges'] != null && (data['eloChanges'] as Map).containsKey(user.uid)
            ? (data['eloChanges'] as Map)[user.uid] as int?
            : null, 
      });
    }
    return history;
  }

  Future<Map<String, dynamic>> getMatchStats() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final eloDoc = await _firestore.collection('eloRatings').doc(user.uid).get();
    int currentElo = 1000;
    int gamesPlayed = 0;
    int wins = 0;

    if (eloDoc.exists && eloDoc.data() != null) {
      final data = eloDoc.data()!;
      currentElo = data['rating'] as int? ?? 1000;
      gamesPlayed = data['gamesPlayed'] as int? ?? 0;
      wins = data['wins'] as int? ?? 0;
    }

    // Placeholder for win rate calculation if needed
    // double winRate = gamesPlayed > 0 ? (wins / gamesPlayed) * 100 : 0;

    return {
      'currentElo': currentElo,
      'gamesPlayed': gamesPlayed,
      'wins': wins,
      // 'winRate': winRate, // Uncomment if you want to include win rate
    };
  }
}