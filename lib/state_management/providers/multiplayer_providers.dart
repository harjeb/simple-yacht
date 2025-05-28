import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/multiplayer_service.dart';
import '../../services/matchmaking_service.dart';
import '../../models/game_room.dart';
import '../../models/multiplayer_game_state.dart';
import '../../models/matchmaking_queue.dart';
import '../../models/game_enums.dart';

// 服务提供者
final multiplayerServiceProvider = Provider<MultiplayerService>((ref) {
  return MultiplayerService();
});

final matchmakingServiceProvider = Provider<MatchmakingService>((ref) {
  return MatchmakingService();
});

// 当前房间状态提供者
final currentRoomProvider = StateProvider<GameRoom?>((ref) => null);

// 当前多人游戏状态提供者
final currentMultiplayerGameProvider = StateProvider<MultiplayerGameState?>((ref) => null);

// 当前匹配队列状态提供者
final currentMatchmakingQueueProvider = StateProvider<MatchmakingQueue?>((ref) => null);

// 房间监听提供者
final roomStreamProvider = StreamProvider.family<GameRoom?, String>((ref, roomId) {
  final service = ref.read(multiplayerServiceProvider);
  return service.watchRoom(roomId);
});

// 匹配状态监听提供者
final matchmakingStatusStreamProvider = StreamProvider<MatchmakingQueue?>((ref) {
  final service = ref.read(matchmakingServiceProvider);
  return service.watchMatchmakingStatus();
});

// ELO评分提供者
final eloRatingProvider = FutureProvider<int>((ref) async {
  final service = ref.read(matchmakingServiceProvider);
  return await service.getCurrentEloRating();
});

// ELO排行榜提供者
final eloLeaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(matchmakingServiceProvider);
  return await service.getEloLeaderboard();
});

// 匹配历史提供者
final matchHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(matchmakingServiceProvider);
  return await service.getMatchHistory();
});

// 匹配统计提供者
final matchStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(matchmakingServiceProvider);
  return await service.getMatchStats();
});

// 多人游戏控制器
class MultiplayerController extends StateNotifier<AsyncValue<void>> {
  final MultiplayerService _multiplayerService;
  final MatchmakingService _matchmakingService;

  MultiplayerController(this._multiplayerService, this._matchmakingService) 
      : super(const AsyncValue.data(null));

  // 创建房间
  Future<String?> createRoom(GameMode gameMode) async {
    state = const AsyncValue.loading();
    try {
      final roomId = await _multiplayerService.createRoom(
        roomName: 'Game Room',
        gameMode: gameMode,
      );
      state = const AsyncValue.data(null);
      return roomId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  // 加入房间
  Future<bool> joinRoom(String roomId) async {
    state = const AsyncValue.loading();
    try {
      await _multiplayerService.joinRoom(roomId);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  // 离开房间
  Future<void> leaveRoom(String roomId) async {
    state = const AsyncValue.loading();
    try {
      await _multiplayerService.leaveRoom(roomId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 开始游戏
  Future<void> startGame(String roomId) async {
    state = const AsyncValue.loading();
    try {
      await _multiplayerService.startGame(roomId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 加入匹配队列
  Future<void> joinMatchmaking({
    required String playerName,
    required GameMode gameMode,
    int? eloRating,
  }) async {
    state = const AsyncValue.loading();
    try {
      final rating = eloRating ?? await _matchmakingService.getCurrentEloRating();
      await _matchmakingService.joinQueue(
        playerName: playerName,
        gameMode: gameMode,
        eloRating: rating,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 离开匹配队列
  Future<void> leaveMatchmaking() async {
    state = const AsyncValue.loading();
    try {
      await _matchmakingService.leaveQueue();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 取消匹配
  Future<void> cancelMatching() async {
    state = const AsyncValue.loading();
    try {
      await _matchmakingService.cancelMatching();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// 多人游戏控制器提供者
final multiplayerControllerProvider = StateNotifierProvider<MultiplayerController, AsyncValue<void>>((ref) {
  final multiplayerService = ref.read(multiplayerServiceProvider);
  final matchmakingService = ref.read(matchmakingServiceProvider);
  return MultiplayerController(multiplayerService, matchmakingService);
}); 