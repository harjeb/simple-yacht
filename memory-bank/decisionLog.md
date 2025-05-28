# 决策日志

记录项目中的关键架构和实现决策。

## 核心技术决策

### 状态管理
**[2025-05-23]** 选择 Riverpod 作为 Flutter 状态管理方案
- 编译时安全、可测试性强、无需 BuildContext 访问

### 导航系统
**[2025-05-23]** 采用 GoRouter 进行路由管理
- 声明式路由、深度链接支持、类型安全

### 后端架构
**[2025-05-24]** Firebase 后端集成
- Authentication: 匿名认证 + 自定义令牌
- Firestore: 用户数据、排行榜存储
- Cloud Functions: 安全敏感逻辑

## 关键问题修复

### 账号恢复功能
**[2025-05-27]** 修复账号恢复后最高分未显示
- Cloud Function 返回 personalBestScore 字段
- 客户端正确保存到本地存储
- 状态提供者刷新顺序优化

### 认证流程
**[2025-05-25]** 修复 Firebase 认证问题
- 应用启动时自动匿名登录
- 解决 Firestore 权限拒绝错误
- 优化用户名创建流程

### 游戏状态管理
**[2025-05-26]** 修复新游戏不显示画面
- GameState.initial() 工厂构造函数
- 游戏屏幕渲染逻辑优化
- 导航守卫添加

### 数据清理
**[2025-05-26]** 账号删除后状态清理
- 认证状态清除
- 本地数据清理
- Riverpod Provider 重置
- 强制导航到初始屏幕

## 安全决策

### Firestore 安全规则
**[2025-05-25]** 实施最小权限原则
- 用户只能访问自己的数据
- 排行榜写入权限控制
- 用户名唯一性通过 Cloud Function 保证

### 数据验证
**[2025-05-26]** 强化数据完整性
- 服务器端时间戳验证
- 用户名格式验证
- 分数范围限制

## 当前状态

- ✅ 核心游戏功能完整
- ✅ 账号恢复功能正常
- ✅ Firebase 集成稳定
- ✅ 安全规则完善
- 🔧 代码细节优化进行中 (84个问题)

---
### Decision (Debug)
[2025-05-28 10:09:00] - Bug Fix Strategy: Resolved Flutter localization build error by updating l10n.yaml, correcting import statements, and regenerating localization files.

**Rationale:**
The error logs indicated `AppLocalizations` was undefined and `package:flutter_gen/gen_l10n/app_localizations.dart` could not be resolved. This pointed to issues with localization file generation or incorrect import paths. The project name 'myapp' was confirmed, and the import path needed to reflect this. Adding `untranslated-messages-file` to `l10n.yaml` helps in tracking missing translations.

**Details:**
- Modified `l10n.yaml` to include `untranslated-messages-file: untranslated_messages.txt`.
- Updated import statements in `lib/ui_screens/home_screen.dart`, `lib/ui_screens/multiplayer_game_screen.dart`, `lib/widgets/scoreboard_widget.dart` from `package:flutter_gen/gen_l10n/app_localizations.dart` to `package:myapp/generated/app_localizations.dart`.
- Executed `flutter pub get`, `flutter gen-l10n`, `flutter clean`, and `flutter pub get` again.

---
### Decision (Matchmaking)
[2025-05-28] - 更改游戏房间代码生成逻辑为6位十六进制格式。

**Rationale:**
为了简化房间代码的格式，使其更易于用户记忆和输入（相对于可能更长或包含混合大小写字母和特殊字符的代码）。6位十六进制提供了超过1600万个唯一ID，在当前项目规模下被认为是足够的。

**Implementation Details:**
- 修改 `lib/services/matchmaking_service.dart` 中的 `_generateRoomCode()` 方法。
- 使用 "0123456789ABCDEF" 作为字符集。
- 生成一个长度为6的随机字符串。
- 包含一个可选的 `isRoomIdTaken()` 检查以确保ID的唯一性，防止在高并发情况下发生冲突。
- 客户端UI (`multiplayer_room_screen.dart`) 预计不受直接影响，因为它应将房间代码视为不透明字符串。

**Impact Assessment:**
- **数据存储**: `gameRooms` 集合中 `roomId` 的格式将统一为6位十六进制。
- **唯一性**: 16^6 (~16.7M) 个可用ID。如果未来并发量或房间总数大幅增加，可能需要重新评估此方案。
- **向后兼容性**: 如果系统中存在旧格式的房间ID，此更改不会自动迁移它们。新旧房间ID将共存，除非进行数据迁移。对于新创建的房间，将使用新格式。

---
### Decision (Code)
[2025-05-28 13:25:58] - Implemented 6-digit hexadecimal room code generation

**Rationale:**
As per prior decision logged on [2025-05-28] (see above entry "更改游戏房间代码生成逻辑为6位十六进制格式"). This change simplifies room codes for better user experience.

**Details:**
- Modified `_generateRoomCode()` in [`lib/services/matchmaking_service.dart`](lib/services/matchmaking_service.dart:189) to use "0123456789ABCDEF" and generate a 6-character string.
- Verified that `createTestMatch()` in the same file correctly utilizes the updated `_generateRoomCode()` for new room IDs.

---
**Timestamp:** 2025-05-28 13:59:56
**Decision:** Enhanced security for game room ID generation and access.
**Rationale:**
1.  **Room ID Generation:** Changed `_generateRoomCode` in `lib/services/matchmaking_service.dart` to use `Random.secure()` instead of `Random()`. This provides cryptographically stronger random numbers, making room IDs significantly harder to predict or enumerate.
2.  **Firestore Access Control:** Strengthened Firestore rules for the `gameRooms` collection in `firestore.rules`.
    *   `create`: Allowed only if `request.auth.uid` matches `request.resource.data.hostId`.
    *   `read`: Allowed only if `request.auth.uid` is either `resource.data.hostId` or `resource.data.guestId`.
    *   `update`: Allowed only if `request.auth.uid` is either `resource.data.hostId` or `resource.data.guestId`, and critical fields (`hostId`, `guestId`, `createdAt`) are not modified.
    *   `delete`: Allowed only if `request.auth.uid` is `resource.data.hostId`.
**Impact:** Reduced risk of unauthorized game room access, data tampering, and denial-of-service attacks related to room creation.
---
