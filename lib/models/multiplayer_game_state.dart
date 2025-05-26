import 'package:cloud_firestore/cloud_firestore.dart';
import '../core_logic/game_state.dart';

enum MultiplayerGameStatus {
  waiting,      // 等待开始
  playing,      // 游戏进行中
  completed,    // 游戏完成
  abandoned,    // 游戏被放弃
}

class MultiplayerGameState {
  final String gameId;
  final List<String> playerIds;
  final Map<String, String> playerNames;
  final MultiplayerGameStatus status;
  final String gameMode; // 'ranked' 或 'casual'
  final DateTime startTime;
  final DateTime? endTime;
  final int timeLimit; // 游戏时间限制（毫秒）
  final Map<String, GameState> playerGameStates;
  final Map<String, int> finalScores;
  final String? winnerId;
  final Map<String, bool> playerReady;
  final Map<String, DateTime> lastActivity;

  MultiplayerGameState({
    required this.gameId,
    required this.playerIds,
    required this.playerNames,
    required this.status,
    required this.gameMode,
    required this.startTime,
    this.endTime,
    required this.timeLimit,
    required this.playerGameStates,
    required this.finalScores,
    this.winnerId,
    required this.playerReady,
    required this.lastActivity,
  });

  // 从Firestore文档创建MultiplayerGameState对象
  factory MultiplayerGameState.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // 解析玩家游戏状态
    final Map<String, GameState> gameStates = {};
    if (data['playerGameStates'] != null) {
      final statesData = data['playerGameStates'] as Map<String, dynamic>;
      statesData.forEach((playerId, stateData) {
        if (stateData != null) {
          gameStates[playerId] = GameState.fromMap(stateData as Map<String, dynamic>);
        }
      });
    }

    return MultiplayerGameState(
      gameId: doc.id,
      playerIds: List<String>.from(data['playerIds'] ?? []),
      playerNames: Map<String, String>.from(data['playerNames'] ?? {}),
      status: MultiplayerGameStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => MultiplayerGameStatus.waiting,
      ),
      gameMode: data['gameMode'] ?? 'casual',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      timeLimit: data['timeLimit'] ?? 15 * 60 * 1000, // 默认15分钟
      playerGameStates: gameStates,
      finalScores: Map<String, int>.from(data['finalScores'] ?? {}),
      winnerId: data['winnerId'],
      playerReady: Map<String, bool>.from(data['playerReady'] ?? {}),
      lastActivity: Map<String, DateTime>.from(
        (data['lastActivity'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, (value as Timestamp).toDate()),
        ),
      ),
    );
  }

  // 转换为Firestore文档
  Map<String, dynamic> toFirestore() {
    // 序列化玩家游戏状态
    final Map<String, dynamic> gameStatesData = {};
    playerGameStates.forEach((playerId, gameState) {
      gameStatesData[playerId] = gameState.toMap();
    });

    return {
      'playerIds': playerIds,
      'playerNames': playerNames,
      'status': status.toString().split('.').last,
      'gameMode': gameMode,
      'startTime': Timestamp.fromDate(startTime),
      if (endTime != null) 'endTime': Timestamp.fromDate(endTime!),
      'timeLimit': timeLimit,
      'playerGameStates': gameStatesData,
      'finalScores': finalScores,
      if (winnerId != null) 'winnerId': winnerId,
      'playerReady': playerReady,
      'lastActivity': lastActivity.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
    };
  }

  // 复制并修改
  MultiplayerGameState copyWith({
    String? gameId,
    List<String>? playerIds,
    Map<String, String>? playerNames,
    MultiplayerGameStatus? status,
    String? gameMode,
    DateTime? startTime,
    DateTime? endTime,
    int? timeLimit,
    Map<String, GameState>? playerGameStates,
    Map<String, int>? finalScores,
    String? winnerId,
    Map<String, bool>? playerReady,
    Map<String, DateTime>? lastActivity,
  }) {
    return MultiplayerGameState(
      gameId: gameId ?? this.gameId,
      playerIds: playerIds ?? this.playerIds,
      playerNames: playerNames ?? this.playerNames,
      status: status ?? this.status,
      gameMode: gameMode ?? this.gameMode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeLimit: timeLimit ?? this.timeLimit,
      playerGameStates: playerGameStates ?? this.playerGameStates,
      finalScores: finalScores ?? this.finalScores,
      winnerId: winnerId ?? this.winnerId,
      playerReady: playerReady ?? this.playerReady,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  // 检查游戏是否已开始
  bool get isStarted => status == MultiplayerGameStatus.playing;

  // 检查游戏是否已结束
  bool get isCompleted => status == MultiplayerGameStatus.completed;

  // 获取剩余时间（毫秒）
  int get remainingTimeMs {
    if (!isStarted) return timeLimit;
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    return (timeLimit - elapsed).clamp(0, timeLimit);
  }

  // 检查是否超时
  bool get isTimeout => remainingTimeMs <= 0;

  // 检查所有玩家是否准备就绪
  bool get allPlayersReady {
    return playerIds.every((playerId) => playerReady[playerId] == true);
  }

  // 获取玩家的游戏状态
  GameState? getPlayerGameState(String playerId) {
    return playerGameStates[playerId];
  }

  // 更新玩家的游戏状态
  MultiplayerGameState updatePlayerGameState(String playerId, GameState gameState) {
    final newGameStates = Map<String, GameState>.from(playerGameStates);
    newGameStates[playerId] = gameState;
    
    final newActivity = Map<String, DateTime>.from(lastActivity);
    newActivity[playerId] = DateTime.now();

    return copyWith(
      playerGameStates: newGameStates,
      lastActivity: newActivity,
    );
  }

  // 设置玩家准备状态
  MultiplayerGameState setPlayerReady(String playerId, bool ready) {
    final newReady = Map<String, bool>.from(playerReady);
    newReady[playerId] = ready;
    return copyWith(playerReady: newReady);
  }

  // 完成游戏并计算最终得分
  MultiplayerGameState completeGame() {
    final newFinalScores = <String, int>{};
    
    playerGameStates.forEach((playerId, gameState) {
      newFinalScores[playerId] = gameState.totalScore;
    });

    // 找出获胜者
    String? winner;
    int highestScore = -1;
    newFinalScores.forEach((playerId, score) {
      if (score > highestScore) {
        highestScore = score;
        winner = playerId;
      }
    });

    return copyWith(
      status: MultiplayerGameStatus.completed,
      endTime: DateTime.now(),
      finalScores: newFinalScores,
      winnerId: winner,
    );
  }
}
