/// 游戏模式枚举
enum GameMode {
  single,       // 单人模式
  multiplayer,  // 多人模式
}

/// 游戏房间状态枚举
enum GameRoomStatus {
  waiting,      // 等待玩家加入
  playing,      // 游戏进行中
  finished,     // 游戏结束
  cancelled,    // 游戏取消
}

/// 匹配状态枚举
enum MatchmakingStatus {
  searching,    // 正在搜索对手
  matched,      // 已匹配成功
  timeout,      // 匹配超时
  cancelled,    // 取消匹配
} 