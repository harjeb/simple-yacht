import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_enums.dart';

/// 游戏房间模型
class GameRoom {
  final String id;
  final String? roomCode; 
  final String hostId;
  final String? guestId;
  final GameMode gameMode;
  final GameRoomStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final Map<String, dynamic>? gameState;
  final Map<String, int>? scores;
  final Map<String, String>? playerNames; 
  final Map<String, int>? playerElos; 
  final int maxPlayers;
  final bool isPrivate;
  final String? password;

  const GameRoom({
    required this.id,
    this.roomCode, 
    required this.hostId,
    this.guestId,
    required this.gameMode,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.gameState,
    this.scores,
    this.playerNames, 
    this.playerElos, 
    this.maxPlayers = 2,
    this.isPrivate = false,
    this.password,
  });

  factory GameRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameRoom.fromMap(data, doc.id);
  }

  factory GameRoom.fromMap(Map<String, dynamic> map, String id) {
    return GameRoom(
      id: id,
      roomCode: map['roomCode'] as String?, 
      hostId: map['hostId'] as String,
      guestId: map['guestId'] as String?,
      gameMode: GameMode.values.firstWhere(
        (mode) => mode.name == map['gameMode'],
        orElse: () => GameMode.multiplayer,
      ),
      status: GameRoomStatus.values.firstWhere(
        (s) => s.name == map['status'], // Changed variable name to avoid conflict
        orElse: () => GameRoomStatus.waiting,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      startedAt: map['startedAt'] != null 
          ? (map['startedAt'] as Timestamp).toDate() 
          : null,
      finishedAt: map['finishedAt'] != null 
          ? (map['finishedAt'] as Timestamp).toDate() 
          : null,
      gameState: map['gameState'] == null ? null : Map<String, dynamic>.from(map['gameState'] as Map),
      scores: map['scores'] == null
          ? null
          : Map<String, int>.from(map['scores'] as Map),
      playerNames: map['playerNames'] == null
          ? null
          : Map<String, String>.from(map['playerNames'] as Map), 
      playerElos: map['playerElos'] == null
          ? null
          : Map<String, int>.from(map['playerElos'] as Map), 
      maxPlayers: map['maxPlayers'] as int? ?? 2,
      isPrivate: map['isPrivate'] as bool? ?? false,
      password: map['password'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomCode': roomCode, 
      'hostId': hostId,
      'guestId': guestId,
      'gameMode': gameMode.name,
      'status': status.name, // This should be correct
      'createdAt': Timestamp.fromDate(createdAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
      'gameState': gameState,
      'scores': scores,
      'playerNames': playerNames, 
      'playerElos': playerElos, 
      'maxPlayers': maxPlayers,
      'isPrivate': isPrivate,
      'password': password,
    };
  }

  GameRoom copyWith({
    String? id,
    String? roomCode,
    String? hostId,
    String? guestId,
    GameMode? gameMode,
    GameRoomStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    Map<String, dynamic>? gameState,
    Map<String, int>? scores,
    Map<String, String>? playerNames,
    Map<String, int>? playerElos,
    int? maxPlayers,
    bool? isPrivate,
    String? password,
  }) {
    return GameRoom(
      id: id ?? this.id,
      roomCode: roomCode ?? this.roomCode,
      hostId: hostId ?? this.hostId,
      guestId: guestId ?? this.guestId,
      gameMode: gameMode ?? this.gameMode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      gameState: gameState ?? this.gameState,
      scores: scores ?? this.scores,
      playerNames: playerNames ?? this.playerNames,
      playerElos: playerElos ?? this.playerElos,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      isPrivate: isPrivate ?? this.isPrivate,
      password: password ?? this.password,
    );
  }

  bool get isFull => guestId != null;

  bool get canStart => isFull && status == GameRoomStatus.waiting;

  bool containsPlayer(String userId) {
    return hostId == userId || guestId == userId;
  }

  int get playerCount { // Corrected getter syntax
    if (guestId != null && hostId.isNotEmpty) return 2;
    if (hostId.isNotEmpty) return 1;
    return 0;
  }

  @override
  String toString() {
    return 'GameRoom(id: $id, roomCode: $roomCode, hostId: $hostId, guestId: $guestId, '
           'gameMode: $gameMode, status: $status, playerCount: $playerCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameRoom && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}