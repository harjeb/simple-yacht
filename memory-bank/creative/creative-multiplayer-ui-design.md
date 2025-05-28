# 🎨🎨🎨 ENTERING CREATIVE PHASE: 双人游戏界面设计

## 组件描述

本创意阶段专注于设计双人游戏功能的三个核心界面组件：

1. **多人游戏大厅界面** (MultiplayerLobbyScreen)
2. **游戏房间界面** (MultiplayerRoomScreen)
3. **多人游戏界面** (MultiplayerGameScreen)

这些界面将为用户提供完整的双人游戏体验，从进入大厅、创建/加入房间，到进行实际的双人游戏。

## 需求与约束

### 功能需求
- 用户能够轻松找到和加入游戏
- 清晰的房间状态显示
- 流畅的游戏体验
- 实时状态更新
- 错误处理和用户反馈

### 技术约束
- 基于现有的 Flutter 架构
- 使用 Riverpod 状态管理
- 集成现有的 MultiplayerService 和 MatchmakingService
- 支持多语言本地化
- 响应式设计，适配不同屏幕尺寸

### 设计约束
- 保持与现有应用风格一致
- 简洁直观的用户界面
- 清晰的视觉层次
- 符合 Material Design 规范

## 设计选项分析

### 选项 1: 分步式导航设计

**概念**: 用户通过明确的步骤进入双人游戏
主界面 → 多人大厅 → 选择模式 → 游戏房间 → 开始游戏

**优点**:
- 用户流程清晰，不会迷失方向
- 每个界面职责单一，易于维护
- 便于添加新功能和模式
- 符合用户的心理预期

**缺点**:
- 步骤较多，可能影响快速开始游戏
- 需要更多的界面开发工作
- 增加了应用的复杂度

### 选项 2: 一体化快速匹配设计

**概念**: 在主界面直接提供快速匹配，减少中间步骤
主界面 → 直接匹配 → 游戏房间 → 开始游戏

**优点**:
- 快速开始游戏，用户体验流畅
- 界面简洁，开发工作量较少
- 适合休闲游戏的快节奏需求

**缺点**:
- 缺少自定义选项
- 用户无法了解匹配过程
- 难以扩展更多游戏模式
- 错误处理复杂

### 选项 3: 混合式设计

**概念**: 结合快速匹配和详细选项
主界面提供快速匹配按钮，同时提供"更多选项"进入详细大厅

**优点**:
- 满足不同用户需求
- 保持界面简洁的同时提供灵活性
- 便于后续功能扩展
- 用户可以根据需要选择体验深度

**缺点**:
- 设计复杂度中等
- 需要考虑两种用户路径
- 可能造成功能重复

## 推荐方案

### 选择: 选项 1 - 分步式导航设计

**理由**:
1. **清晰的用户体验**: 对于 Yahtzee 这样的策略游戏，用户更愿意了解游戏设置和对手信息
2. **可扩展性**: 便于后续添加更多游戏模式（好友对战、锦标赛等）
3. **错误处理**: 每个步骤都可以独立处理错误，提供更好的用户反馈
4. **符合现有架构**: 与当前的单人游戏流程保持一致

### 详细界面设计

#### 1. 多人游戏大厅界面 (MultiplayerLobbyScreen)

**布局结构**:
```
[AppBar: 多人游戏大厅]
[用户信息卡片: 用户名、ELO评级、胜率]
[在线状态: 当前在线玩家数]
[游戏模式选择]
  - 快速匹配 (自动匹配相近ELO的对手)
  - 创建房间 (自定义房间设置)
  - 加入房间 (输入房间码)
[最近游戏记录 (可选)]
[返回主界面按钮]
```

**关键功能**:
- 实时显示在线玩家数量
- ELO评级和统计信息展示
- 三种游戏模式的清晰入口
- 加载状态和错误提示

**交互设计**:
- 快速匹配: 大按钮，突出显示，点击后进入匹配界面
- 创建房间: 弹出设置对话框，然后创建房间
- 加入房间: 输入框 + 加入按钮

#### 2. 游戏房间界面 (MultiplayerRoomScreen)

**布局结构**:
```
[AppBar: 房间 #ROOMCODE]
[房间信息卡片]
  - 房间码 (可复制)
  - 游戏设置 (时间限制、回合数等)
  - 房间状态
[玩家列表]
  - 房主 (带皇冠图标)
  - 客人 (或等待中...)
  - 玩家信息 (用户名、ELO、准备状态)
[聊天区域 (可选)]
[控制按钮区域]
  - 房主: [开始游戏] [踢出玩家] [离开房间]
  - 客人: [准备] [离开房间]
```

**关键功能**:
- 实时玩家状态更新
- 房间码分享功能
- 房主权限管理
- 准备状态指示

**交互设计**:
- 房间码点击复制
- 准备按钮切换状态
- 开始游戏按钮仅在所有玩家准备后启用
- 离开房间需要确认对话框

#### 3. 多人游戏界面 (MultiplayerGameScreen)

**布局结构**:
```
[AppBar: 多人游戏 - 回合 X/13]
[对手信息栏]
  - 对手用户名、头像
  - 对手当前分数
  - 对手状态 (投掷中/选择分数/等待中)
[游戏区域] (复用现有单人游戏组件)
  - 骰子区域
  - 计分板
  - 操作按钮
[当前玩家信息]
  - 自己的用户名、分数
  - 回合状态指示
[游戏控制]
  - 聊天按钮 (可选)
  - 设置按钮
  - 退出游戏按钮
```

**关键功能**:
- 实时游戏状态同步
- 回合制逻辑管理
- 对手操作状态显示
- 游戏结果处理

**交互设计**:
- 清晰的回合指示器
- 等待对手时的加载动画
- 游戏结束时的结果展示
- 断线重连处理

## 实现指南

### 技术架构

#### 状态管理
```dart
// 使用 Riverpod 管理多人游戏状态
final multiplayerLobbyProvider = StateNotifierProvider<MultiplayerLobbyNotifier, MultiplayerLobbyState>((ref) {
  return MultiplayerLobbyNotifier(ref.read(multiplayerServiceProvider));
});

final gameRoomProvider = StateNotifierProvider<GameRoomNotifier, GameRoomState>((ref) {
  return GameRoomNotifier(ref.read(multiplayerServiceProvider));
});

final multiplayerGameProvider = StateNotifierProvider<MultiplayerGameNotifier, MultiplayerGameState>((ref) {
  return MultiplayerGameNotifier(ref.read(multiplayerServiceProvider));
});
```

#### 路由配置
```dart
// 在 app_router.dart 中添加路由
GoRoute(
  path: '/multiplayer_lobby',
  builder: (context, state) => const MultiplayerLobbyScreen(),
),
GoRoute(
  path: '/multiplayer_room/:roomId',
  builder: (context, state) => MultiplayerRoomScreen(
    roomId: state.pathParameters['roomId']!,
  ),
),
GoRoute(
  path: '/multiplayer_game/:roomId',
  builder: (context, state) => MultiplayerGameScreen(
    roomId: state.pathParameters['roomId']!,
  ),
),
```

#### 实时通信
```dart
// 使用 Stream 监听实时更新
class MultiplayerLobbyNotifier extends StateNotifier<MultiplayerLobbyState> {
  late StreamSubscription _onlinePlayersSubscription;
  
  void _listenToOnlinePlayers() {
    _onlinePlayersSubscription = multiplayerService
        .getOnlinePlayersStream()
        .listen((count) {
      state = state.copyWith(onlinePlayersCount: count);
    });
  }
}
```

### 用户体验优化

#### 加载状态
- 使用 CircularProgressIndicator 显示加载状态
- 提供有意义的加载文本（"正在寻找对手..."）
- 设置合理的超时时间

#### 错误处理
- 网络错误：显示重试按钮
- 房间不存在：提示用户检查房间码
- 连接断开：自动重连机制

#### 响应式设计
- 使用 MediaQuery 适配不同屏幕尺寸
- 在小屏幕上隐藏非关键信息
- 确保按钮大小适合触摸操作

### 本地化支持

#### 文本资源
```json
// app_zh.arb
{
  "multiplayerLobby": "多人游戏大厅",
  "quickMatch": "快速匹配",
  "createRoom": "创建房间",
  "joinRoom": "加入房间",
  "onlinePlayers": "在线玩家: {count}",
  "roomCode": "房间码",
  "waitingForPlayers": "等待玩家加入...",
  "gameStarting": "游戏即将开始",
  "yourTurn": "轮到你了",
  "opponentTurn": "对手回合"
}
```

## 验证检查点

### 功能验证
- [ ] 用户能够从主界面进入多人游戏大厅
- [ ] 大厅界面正确显示在线玩家数和用户信息
- [ ] 快速匹配功能正常工作
- [ ] 创建房间和加入房间功能正常
- [ ] 房间界面实时更新玩家状态
- [ ] 游戏界面正确同步双方操作
- [ ] 游戏结束后正确处理结果

### 用户体验验证
- [ ] 界面响应流畅，无明显延迟
- [ ] 错误信息清晰易懂
- [ ] 加载状态提供适当反馈
- [ ] 多语言支持完整
- [ ] 在不同屏幕尺寸下显示正常

### 技术质量验证
- [ ] 代码结构清晰，符合现有架构
- [ ] 状态管理正确，无内存泄漏
- [ ] 网络请求有适当的错误处理
- [ ] 实时通信稳定可靠

# 🎨🎨🎨 EXITING CREATIVE PHASE

创意设计阶段完成。推荐采用分步式导航设计，为用户提供清晰的多人游戏体验流程。设计方案包含三个核心界面的详细布局、交互设计和技术实现指南，确保与现有应用架构的无缝集成。

