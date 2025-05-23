# TODO List

## High Priority / Next Steps

- [ ] 实现 Firebase 后端和在线功能 (身份验证、用于游戏状态/排行榜的 Firestore) (来自: [`memory-bank/activeContext.md:10`](memory-bank/activeContext.md:10), [`memory-bank/progress.md:25`](memory-bank/progress.md:25))
- [ ] 将前端与 Firebase 服务集成 (来自: [`memory-bank/progress.md:26`](memory-bank/progress.md:26))
- [ ] 仔细配置 Firebase 安全规则 (来自: [`memory-bank/decisionLog.md:36`](memory-bank/decisionLog.md:36))

## Backend & Networking

- [ ] 实现用户账户创建 API 端点 (`POST /users`) (来自: [`memory-bank/architecture.md:112`](memory-bank/architecture.md:112))
- [ ] 实现获取用户资料 API 端点 (`GET /users/{userId}`) (来自: [`memory-bank/architecture.md:113`](memory-bank/architecture.md:113))
- [ ] 实现创建新游戏 API 端点 (`POST /games`) (来自: [`memory-bank/architecture.md:114`](memory-bank/architecture.md:114))
- [ ] 实现加入游戏 API 端点 (`POST /games/{gameId}/join`) (来自: [`memory-bank/architecture.md:115`](memory-bank/architecture.md:115))
- [ ] 实现游戏内掷骰子 API 端点 (`POST /games/{gameId}/roll`) (或通过 Firestore 实时同步) (来自: [`memory-bank/architecture.md:116`](memory-bank/architecture.md:116))
- [ ] 实现提交分数 API 端点 (`POST /games/{gameId}/score`) (来自: [`memory-bank/architecture.md:117`](memory-bank/architecture.md:117))
- [ ] 实现获取全球排行榜 API 端点 (`GET /leaderboard/global`) (来自: [`memory-bank/architecture.md:118`](memory-bank/architecture.md:118))
- [ ] 实现获取个人最佳成绩 API 端点 (`GET /leaderboard/personal/{userId}`) (来自: [`memory-bank/architecture.md:119`](memory-bank/architecture.md:119))
- [ ] 实现加入随机匹配队列 API 端点 (`POST /matchmaking/queue`) (来自: [`memory-bank/architecture.md:120`](memory-bank/architecture.md:120))
- [ ] 实现离开随机匹配队列 API 端点 (`DELETE /matchmaking/queue`) (来自: [`memory-bank/architecture.md:121`](memory-bank/architecture.md:121))
- [ ] 实现 ELO 更新逻辑 (内部触发 `POST /elo/update`) (来自: [`memory-bank/architecture.md:122`](memory-bank/architecture.md:122))
- [ ] 完整实现 Firestore `users` 集合模式 (来自: [`memory-bank/architecture.md:128-135`](memory-bank/architecture.md:128-135))
- [ ] 完整实现 Firestore `games` 集合模式 (用于双人对战) (来自: [`memory-bank/architecture.md:136-150`](memory-bank/architecture.md:136-150))
- [ ] 完整实现 Firestore `leaderboard` 集合模式 (来自: [`memory-bank/architecture.md:151-159`](memory-bank/architecture.md:151-159))
- [ ] 完整实现 Firestore `matchmakingQueue` 集合模式 (来自: [`memory-bank/architecture.md:160-164`](memory-bank/architecture.md:160-164))

## Frontend Features & UI

- [ ] 实现双人游戏模式 (来自: [`memory-bank/productContext.md:16`](memory-bank/productContext.md:16))
- [ ] 实现全球高分排行榜功能及 UI (`leaderboard_screen.dart`) (来自: [`memory-bank/productContext.md:21`](memory-bank/productContext.md:21), [`memory-bank/architecture.md:41`](memory-bank/architecture.md:41))
- [ ] 实现随机匹配功能及 UI (`matchmaking_screen.dart`) (来自: [`memory-bank/productContext.md:25`](memory-bank/productContext.md:25), [`memory-bank/architecture.md:42`](memory-bank/architecture.md:42))
- [ ] 实现好友对战模式功能及 UI (`friend_battle_screen.dart`) (来自: [`memory-bank/productContext.md:26`](memory-bank/productContext.md:26), [`memory-bank/architecture.md:43`](memory-bank/architecture.md:43))
- [ ] 实现 ELO 评分系统 (逻辑及 UI 展示) (来自: [`memory-bank/productContext.md:28`](memory-bank/productContext.md:28))
- [ ] 实现全球天梯排名 (基于 ELO, 逻辑及 UI 展示) (来自: [`memory-bank/productContext.md:29`](memory-bank/productContext.md:29))
- [ ] 创建 `models/user_model.dart` (来自: [`memory-bank/architecture.md:28`](memory-bank/architecture.md:28))
- [ ] 创建 `models/score_model.dart` (来自: [`memory-bank/architecture.md:29`](memory-bank/architecture.md:29))
- [ ] 创建 `models/game_model.dart` (来自: [`memory-bank/architecture.md:30`](memory-bank/architecture.md:30))
- [ ] 创建 `models/leaderboard_entry_model.dart` (来自: [`memory-bank/architecture.md:31`](memory-bank/architecture.md:31))
- [ ] 创建 `services/api_service.dart` (来自: [`memory-bank/architecture.md:33`](memory-bank/architecture.md:33))
- [ ] 创建/完善 `services/game_service.dart` (来自: [`memory-bank/architecture.md:35`](memory-bank/architecture.md:35))
- [ ] 创建 `services/auth_service.dart` (来自: [`memory-bank/architecture.md:36`](memory-bank/architecture.md:36))
- [ ] 创建 `widgets/player_avatar_widget.dart` (来自: [`memory-bank/architecture.md:47`](memory-bank/architecture.md:47))
- [ ] 创建 `widgets/custom_button_widget.dart` (来自: [`memory-bank/architecture.md:48`](memory-bank/architecture.md:48))

## Development Process & Quality

- [ ] 编写单元测试 (来自: [`memory-bank/architecture.md:235`](memory-bank/architecture.md:235))
- [ ] 编写 widget 测试 (来自: [`memory-bank/architecture.md:235`](memory-bank/architecture.md:235))
- [ ] 编写集成测试 (来自: [`memory-bank/architecture.md:235`](memory-bank/architecture.md:235))
- [ ] 建立持续集成/持续部署 (CI/CD) 流程 (来自: [`memory-bank/architecture.md:236`](memory-bank/architecture.md:236))
- [ ] 定义和实施测试模式 (来自: [`memory-bank/systemPatterns.md:24`](memory-bank/systemPatterns.md:24))