import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_yacht/core_logic/score_entry.dart';
import 'package:simple_yacht/services/leaderboard_service.dart';
import 'package:simple_yacht/state_management/providers/leaderboard_providers.dart';
import 'package:simple_yacht/state_management/providers/user_providers.dart';

final personalBestScoreProvider = FutureProvider.autoDispose<ScoreEntry?>((ref) async {
  // Await the actual username string from the usernameProvider future
  final String? actualUsername = await ref.watch(usernameProvider.future);
  final leaderboardService = ref.watch(leaderboardServiceProvider);

  // 移除对 leaderboardProvider 的监听，避免不必要的排行榜数据获取
  // 个人最佳分数从用户文档中获取，不需要依赖排行榜数据
  // ref.watch(leaderboardProvider); // 已移除

  if (actualUsername == null || actualUsername.isEmpty) {
    return null; // No username, so no personal best score to fetch
  }

  // Now actualUsername is a String, so it can be used directly.
  return await leaderboardService.getPersonalBestScore(actualUsername);
});