import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_enums.dart';

class MatchmakingQueue {
  final String playerId;
  final String playerName;
  final GameMode gameMode;
  final int eloRating;
  final MatchmakingStatus status;
  final DateTime joinedAt;
  final String? roomId;
  final DateTime? matchedAt;
  final DateTime? timeoutAt;

  MatchmakingQueue({
    required this.playerId,
    required this.playerName,
    required this.gameMode,
    required this.eloRating,
    required this.status,
    required this.joinedAt,
    this.roomId,
    this.matchedAt,
    this.timeoutAt,
  });

  // 从Firestore文档创建MatchmakingQueue对象
  factory MatchmakingQueue.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchmakingQueue(
      playerId: doc.id,
      playerName: data['playerName'] ?? '',
      gameMode: GameMode.values.firstWhere(
        (mode) => mode.name == data['gameMode'],
        orElse: () => GameMode.multiplayer,
      ),
      eloRating: data['eloRating'] ?? 1200,
      status: MatchmakingStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => MatchmakingStatus.searching,
      ),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      roomId: data['roomId'],
      matchedAt: (data['matchedAt'] as Timestamp?)?.toDate(),
      timeoutAt: (data['timeoutAt'] as Timestamp?)?.toDate(),
    );
  }

  // 转换为Firestore文档
  Map<String, dynamic> toFirestore() {
    return {
      'playerName': playerName,
      'gameMode': gameMode.name,
      'eloRating': eloRating,
      'status': status.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      if (roomId != null) 'roomId': roomId,
      if (matchedAt != null) 'matchedAt': Timestamp.fromDate(matchedAt!),
      if (timeoutAt != null) 'timeoutAt': Timestamp.fromDate(timeoutAt!),
    };
  }

  // 复制并修改
  MatchmakingQueue copyWith({
    String? playerId,
    String? playerName,
    GameMode? gameMode,
    int? eloRating,
    MatchmakingStatus? status,
    DateTime? joinedAt,
    String? roomId,
    DateTime? matchedAt,
    DateTime? timeoutAt,
  }) {
    return MatchmakingQueue(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      gameMode: gameMode ?? this.gameMode,
      eloRating: eloRating ?? this.eloRating,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      roomId: roomId ?? this.roomId,
      matchedAt: matchedAt ?? this.matchedAt,
      timeoutAt: timeoutAt ?? this.timeoutAt,
    );
  }

  // 获取等待时间（毫秒）
  int get waitTimeMs => DateTime.now().difference(joinedAt).inMilliseconds;

  // 获取等待时间（秒）
  int get waitTimeSeconds => DateTime.now().difference(joinedAt).inSeconds;

  // 检查是否超时（2分钟）
  bool get isTimeout => waitTimeMs > 2 * 60 * 1000;

  // 计算当前匹配范围（基于等待时间）
  int get currentMatchRange {
    final expandedRange = (waitTimeSeconds / 30).floor() * 100; // 每30秒扩大100分
    return (expandedRange > 500) ? 500 : expandedRange; // 最大500分差距
  }
}
