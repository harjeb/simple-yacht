# 多人战斗功能完整指南

## 📋 概述

本文档详细说明了Yahtzee游戏的多人战斗功能实现，包括随机匹配、好友对战、ELO评级系统等核心功能。

## 🏗️ 架构设计

### 核心组件
1. **匹配系统** - 基于ELO的智能匹配
2. **游戏房间** - 实时多人游戏状态管理
3. **ELO评级** - 标准ELO算法实现
4. **好友系统** - 好友邀请和对战
5. **排行榜** - 全球和个人统计

### 数据流程
```
用户加入队列 → 匹配算法 → 创建游戏房间 → 实时游戏 → 结果提交 → ELO更新 → 排行榜更新
```

## 🔐 Firestore安全规则

### 主要集合权限

#### 用户数据 (`/users/{userId}`)
- ✅ 用户只能读写自己的数据
- ✅ 其他用户可读取基本信息（用户名、ELO）
- ❌ 敏感数据完全隔离

#### 游戏房间 (`/gameRooms/{roomId}`)
- ✅ 只有房间参与者可以访问
- ✅ 严格的状态更新控制
- ✅ 防止非法操作

#### 匹配队列 (`/matchmakingQueue/{userId}`)
- ✅ 用户只能管理自己的队列状态
- ✅ 自动清理过期条目

#### 好友系统 (`/friendships/{friendshipId}`)
- ✅ 双向权限验证
- ✅ 状态转换控制

## ⚙️ Cloud Functions API

### 1. 设置用户名
```javascript
// 调用方式
const result = await firebase.functions().httpsCallable('setUniqueUsername')({
  username: 'PlayerName123'
});

// 返回结果
{
  success: true
}
```

**功能特点:**
- 🔒 事务保证用户名唯一性
- ✅ 格式验证（3-15字符，字母数字下划线）
- 🔄 支持用户名更改
- 📊 自动初始化游戏统计

### 2. 随机匹配
```javascript
// 加入匹配队列
const result = await firebase.functions().httpsCallable('joinMatchmakingQueue')({
  gameMode: 'random'
});

// 可能的返回结果
// 情况1：立即匹配成功
{
  success: true,
  matched: true,
  roomId: 'user1_user2_1234567890',
  opponent: {
    id: 'opponentUserId',
    username: 'OpponentName',
    elo: 1250
  }
}

// 情况2：加入队列等待
{
  success: true,
  matched: false,
  message: 'Added to matchmaking queue',
  queueId: 'currentUserId'
}
```

**匹配算法:**
- 🎯 ELO差距控制在±200以内
- ⚡ 智能匹配，优先匹配相近水平玩家
- 🔄 自动清理过期队列（5分钟）

### 3. 离开匹配队列
```javascript
const result = await firebase.functions().httpsCallable('leaveMatchmakingQueue')();
```

### 4. 好友对战
```javascript
// 创建好友对战房间
const result = await firebase.functions().httpsCallable('createFriendBattle')({
  friendId: 'friendUserId'
});

// 返回结果
{
  success: true,
  roomId: 'friend_user1_user2_1234567890',
  message: 'Friend battle room created'
}

// 好友加入房间
const joinResult = await firebase.functions().httpsCallable('joinFriendBattle')({
  roomId: 'friend_user1_user2_1234567890'
});
```

### 5. 提交游戏结果
```javascript
const result = await firebase.functions().httpsCallable('submitGameResult')({
  roomId: 'gameRoomId',
  playerScore: 350,
  opponentScore: 280
});

// 返回结果
{
  success: true,
  winner: 'currentUserId',
  eloChanges: {
    player1: +15,
    player2: -15
  },
  finalScores: {
    player1: 350,
    player2: 280
  }
}
```

**ELO计算特点:**
- 📈 标准ELO算法，K因子=32
- 🎮 只有随机匹配影响ELO
- 👥 好友对战不影响排名
- 📊 详细的历史记录

### 6. 获取全球排行榜
```javascript
const result = await firebase.functions().httpsCallable('getGlobalLeaderboard')({
  limit: 50,
  gameMode: 'random'
});

// 返回结果
{
  success: true,
  leaderboard: [
    {
      rank: 1,
      userId: 'topPlayerId',
      username: 'TopPlayer',
      elo: 1850,
      wins: 45,
      losses: 12,
      draws: 3,
      totalGames: 60,
      winRate: 75
    },
    // ... 更多玩家
  ],
  timestamp: '2025-01-XX...'
}
```

## 📊 数据模型

### 用户文档 (`/users/{userId}`)
```javascript
{
  username: 'PlayerName',
  normalizedUsername: 'playername',
  elo: 1200,
  wins: 0,
  losses: 0,
  draws: 0,
  totalGames: 0,
  transferCode: 'ABC123DEF456GHI789',
  createdAt: Timestamp,
  updatedAt: Timestamp,
  lastGameAt: Timestamp
}
```

### 游戏房间 (`/gameRooms/{roomId}`)
```javascript
{
  roomId: 'user1_user2_1234567890',
  player1: 'userId1',
  player2: 'userId2',
  players: ['userId1', 'userId2'],
  gameMode: 'random', // 'random' | 'friend'
  status: 'active', // 'waiting' | 'active' | 'completed' | 'expired'
  currentPlayer: 'userId1',
  winner: null, // userId or null for draw
  gameState: {
    round: 1,
    player1Score: 0,
    player2Score: 0,
    isGameOver: false
  },
  finalScores: {
    userId1: 350,
    userId2: 280
  },
  createdAt: Timestamp,
  lastActivity: Timestamp,
  completedAt: Timestamp
}
```

### 匹配队列 (`/matchmakingQueue/{userId}`)
```javascript
{
  userId: 'currentUserId',
  username: 'PlayerName',
  elo: 1200,
  gameMode: 'random',
  status: 'waiting',
  createdAt: Timestamp,
  lastActivity: Timestamp
}
```

### ELO历史 (`/eloHistory/{userId}/matches/{matchId}`)
```javascript
{
  opponentId: 'opponentUserId',
  opponentUsername: 'OpponentName',
  myScore: 350,
  opponentScore: 280,
  eloChange: +15,
  newElo: 1215,
  result: 'win', // 'win' | 'loss' | 'draw'
  gameMode: 'random',
  timestamp: Timestamp
}
```

### 好友关系 (`/friendships/{friendshipId}`)
```javascript
{
  user1: 'userId1',
  user2: 'userId2',
  status: 'accepted', // 'pending' | 'accepted' | 'rejected'
  createdAt: Timestamp
}
```

## 🔄 实时监听

### 监听匹配结果
```javascript
// 监听匹配队列状态
const unsubscribe = firebase.firestore()
  .collection('matchmakingQueue')
  .doc(currentUserId)
  .onSnapshot((doc) => {
    if (!doc.exists) {
      // 匹配成功，队列条目被删除
      checkForGameRoom();
    }
  });
```

### 监听游戏房间
```javascript
// 监听游戏房间状态
const unsubscribe = firebase.firestore()
  .collection('gameRooms')
  .doc(roomId)
  .onSnapshot((doc) => {
    if (doc.exists) {
      const roomData = doc.data();
      updateGameUI(roomData);
    }
  });
```

## 🛠️ 客户端集成示例

### Flutter服务类示例
```dart
class MultiplayerService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 加入匹配队列
  Future<MatchResult> joinMatchmaking() async {
    final callable = _functions.httpsCallable('joinMatchmakingQueue');
    final result = await callable.call({'gameMode': 'random'});
    return MatchResult.fromMap(result.data);
  }

  // 监听游戏房间
  Stream<GameRoom> watchGameRoom(String roomId) {
    return _firestore
        .collection('gameRooms')
        .doc(roomId)
        .snapshots()
        .map((doc) => GameRoom.fromMap(doc.data()!));
  }

  // 提交游戏结果
  Future<GameResult> submitResult(String roomId, int myScore, int opponentScore) async {
    final callable = _functions.httpsCallable('submitGameResult');
    final result = await callable.call({
      'roomId': roomId,
      'playerScore': myScore,
      'opponentScore': opponentScore,
    });
    return GameResult.fromMap(result.data);
  }
}
```

## 🔧 维护和监控

### 自动清理机制
- ⏰ **队列清理**: 每5分钟清理过期队列条目
- 🏠 **房间清理**: 每小时标记过期房间
- 📊 **数据优化**: 定期清理历史数据

### 监控指标
- 📈 匹配成功率
- ⏱️ 平均匹配时间
- 🎮 活跃游戏房间数
- 📊 ELO分布情况

## 🚀 部署步骤

1. **部署Firestore规则**
```bash
firebase deploy --only firestore:rules
```

2. **部署Cloud Functions**
```bash
firebase deploy --only functions
```

3. **验证部署**
```bash
firebase functions:log
```

## 🔍 故障排除

### 常见问题
1. **匹配失败** - 检查用户ELO范围和队列状态
2. **权限错误** - 验证Firestore安全规则
3. **函数超时** - 检查网络连接和函数日志

### 调试工具
- Firebase控制台日志
- Firestore数据查看器
- Functions模拟器

## 📝 最佳实践

1. **错误处理** - 实现完整的错误处理和重试机制
2. **状态管理** - 使用Riverpod管理复杂的多人游戏状态
3. **网络优化** - 实现离线支持和网络状态检测
4. **用户体验** - 提供清晰的匹配状态和进度指示

---

这个多人战斗系统提供了完整的、生产就绪的解决方案，支持扩展和自定义。通过合理的架构设计和安全措施，确保了系统的稳定性和安全性。 