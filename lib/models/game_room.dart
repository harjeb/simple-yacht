import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_enums.dart';

/// 游戏房间模型
class GameRoom {
  final String id;
  final String hostId;
  final String? guestId;
  final GameMode gameMode;
  final GameRoomStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final Map<String, dynamic>? gameState;
  final Map<String, int>? scores;
  final int maxPlayers;
  final bool isPrivate;
  final String? password;

  const GameRoom({
    required this.id,
    required this.hostId,
    this.guestId,
    required this.gameMode,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.gameState,
    this.scores,
    this.maxPlayers = 2,
    this.isPrivate = false,
    this.password,
  });

  /// 从Firestore文档创建GameRoom实例
  factory GameRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameRoom.fromMap(data, doc.id);
  }

  /// 从Map创建GameRoom实例
  factory GameRoom.fromMap(Map<String, dynamic> map, String id) {
    return GameRoom(
      id: id,
      hostId: map['hostId'] as String,
      guestId: map['guestId'] as String?,
      gameMode: GameMode.values.firstWhere(
        (mode) => mode.name == map['gameMode'],
        orElse: () => GameMode.multiplayer,
      ),
      status: GameRoomStatus.values.firstWhere(
        (status) => status.name == map['status'],
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
      maxPlayers: map['maxPlayers'] as int? ?? 2,
      isPrivate: map['isPrivate'] as bool? ?? false,
      password: map['password'] as String?,
    );
  }

  /// 转换为Map用于Firestore存储
  Map<String, dynamic> toMap() {
    return {
      'hostId': hostId,
      'guestId': guestId,
      'gameMode': gameMode.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
      'gameState': gameState,
      'scores': scores,
      'maxPlayers': maxPlayers,
      'isPrivate': isPrivate,
      'password': password,
    };
  }

  /// 创建副本并更新指定字段
  GameRoom copyWith({
    String? id,
    String? hostId,
    String? guestId,
    GameMode? gameMode,
    GameRoomStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    Map<String, dynamic>? gameState,
    Map<String, int>? scores,
    int? maxPlayers,
    bool? isPrivate,
    String? password,
  }) {
    return GameRoom(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      guestId: guestId ?? this.guestId,
      gameMode: gameMode ?? this.gameMode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      gameState: gameState ?? this.gameState,
      scores: scores ?? this.scores,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      isPrivate: isPrivate ?? this.isPrivate,
      password: password ?? this.password,
    );
  }

  /// 检查房间是否已满
  bool get isFull => guestId != null;

  /// 检查房间是否可以开始游戏
  bool get canStart => isFull && status == GameRoomStatus.waiting;

  /// 检查指定用户是否在房间中
  bool containsPlayer(String userId) {
    return hostId == userId || guestId == userId;
  }

  /// 获取房间中的玩家数量
  int get playerCount => guestId != null ? 2 : 1;

  @override
  String toString() {
    return 'GameRoom(id: $id, hostId: $hostId, guestId: $guestId, '
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