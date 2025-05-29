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

---
### 决策 (在线玩家计数架构)
[2025-05-28] - 确定了“在线玩家数”功能的架构方案。

**基本原理:**
利用 Firebase Realtime Database 的实时能力和 `onDisconnect()` 机制，结合客户端 Flutter (通过 `PresenceService`) 和 Riverpod 状态管理，实现高效、近实时的在线玩家数量统计和显示。

**架构详情:**
1.  **Firebase Realtime Database (RTDB) 结构:**
    *   `/online_users/{userId}`: (Boolean/Timestamp) 标记单个用户在线状态。
        *   规则: 用户只能写入自己的状态 (`auth.uid == userId`)。
    *   `/online_users_count`: (Integer) 存储在线用户总数。
        *   规则: 禁止客户端直接写入；通过事务和 `onDisconnect` 的 `ServerValue.increment()` 进行原子更新。
    *   `onDisconnect()` 钩子:
        *   在 `/online_users/{userId}` 上设置 `onDisconnect().remove()`。
        *   在 `/online_users_count` 上设置 `onDisconnect().set(ServerValue.increment(-1))`。

2.  **客户端 Flutter (`PresenceService`):**
    *   **`_goOnline(userId)`**: 用户认证后，设置 `/online_users/{userId}` 为 true，并通过事务递增 `/online_users_count`。同时设置上述 `onDisconnect()` 操作。
    *   **`_goOffline(userId)`**: 用户主动下线时，移除 `/online_users/{userId}`，并通过事务递减 `/online_users_count`。
    *   **`getOnlinePlayersCountStream() -> Stream<int>`**: 监听 `/online_users_count` 的变化，通过 Riverpod `StreamProvider` 供 UI 使用。

3.  **前端 UI ([`MultiplayerLobbyScreen`](lib/ui_screens/multiplayer_lobby_screen.dart:0)):**
    *   使用 Riverpod `ConsumerWidget` 监听 `onlinePlayersCountProvider` 以实时显示在线数量。

**选择理由:**
*   **实时性**: RTDB 非常适合高频更新和实时监听的场景。
*   **可靠性**: `onDisconnect()` 机制能较好地处理客户端意外断开连接的情况，确保数据最终一致性。
*   **原子性**: 使用 RTDB 事务和 `ServerValue.increment()` 保证计数更新的原子性，避免竞态条件。
*   **客户端驱动**: 主要逻辑在客户端，减少了对 Cloud Functions 的依赖，简化了后端部署和维护（除非未来需要更复杂的服务器端逻辑）。

**潜在风险与考虑:**
*   **扩展性**: 对于超大规模用户量，纯粹依赖 `/online_users_count` 的单一计数器可能会遇到写入瓶颈。但对于当前项目规模，此方案足够。
*   **准确性**: “近实时”，允许微小延迟。
*   **安全性**: 依赖正确的 Firebase 安全规则配置来保护数据。

---
### Decision (Debug)
[2025-05-29 00:57:00] - Bug Fix Strategy: Address `MissingPluginException(No implementation found for method Query#observe on channel plugins.flutter.io/firebase_database)`

**Rationale:**
The error indicates a failure in the native Android Firebase Realtime Database setup. The primary suspect is an incomplete or outdated `google-services.json` file, specifically missing the `firebase_url` entry which is essential for Realtime Database. A secondary check involves ensuring the `google-services` Gradle plugin classpath is correctly defined in the project-level `android/build.gradle.kts` (or `build.gradle`).

**Details:**
1.  **Verify and Update `google-services.json`**: Instructed user to re-download `google-services.json` from the Firebase console for the Android app (`com.example.myapp` within project `yacht-f816d`) and replace the existing file at [`android/app/google-services.json`](android/app/google-services.json). The new file must contain the `firebase_url` field.
2.  **Verify Project-Level Gradle**: Instructed user to check `android/build.gradle.kts` (or `build.gradle`) for the correct `com.google.gms:google-services` classpath declaration in the `plugins` or `buildscript { dependencies }` block. Recommended version `4.4.1` or a similar recent stable version.
3.  **Clean and Rebuild**: Recommended running `flutter clean`, `flutter pub get`, and then `flutter run`.

---
### Decision (Debug)
[2025-05-29 01:10:19] - Corrected `firebase_url` format in `google-services.json`

**Rationale:**
The application was throwing a "firebase fatal error: cannot parse firebase url,please use https://yourfirebase.firebaseio.com" error. This indicated that the `firebase_url` in [`android/app/google-services.json`](android/app/google-services.json) was malformed. The previous value was "https://yacht-f816d-default-rtdb.firebaseio.com/", which includes an extra "-default-rtdb" segment and a trailing slash.

**Details:**
- Modified `firebase_url` in [`android/app/google-services.json`](android/app/google-services.json) from `"https://yacht-f816d-default-rtdb.firebaseio.com/"` to `"https://yacht-f816d.firebaseio.com"`.

---
### Decision (Debug)
[2025-05-29 01:13:33] - Resolved Gradle plugin version conflict for `com.google.gms.google-services`.

**Rationale:**
The Android build failed with an error indicating a version mismatch for the `com.google.gms.google-services` plugin between the project-level ([`android/build.gradle.kts`](android/build.gradle.kts:1)) and app-level ([`android/app/build.gradle.kts`](android/app/build.gradle.kts:1)) Gradle files. The project-level file specified version `4.4.1`, while the app-level file had an unspecified version, leading to the conflict with a previously resolved version `4.3.15` on the classpath.

**Details:**
- Updated [`android/app/build.gradle.kts`](android/app/build.gradle.kts:1) to explicitly set the `com.google.gms.google-services` plugin version to `4.4.1`. Specifically, changed `id("com.google.gms.google-services")` to `id("com.google.gms.google-services") version "4.4.1"`.
- Verified that the project-level [`android/build.gradle.kts`](android/build.gradle.kts:1) already correctly specified `id("com.google.gms.google-services") version "4.4.1" apply false`.

---
### Decision (Code)
[2025-05-29 01:59:45] - Unified `com.google.gms.google-services` plugin version to `4.4.1` across Gradle files.

**Rationale:**
An Android build error `Error resolving plugin [id: 'com.google.gms.google-services', version: '4.4.1', apply: false] > The request for this plugin could not be satisfied because the plugin is already on the classpath with a different version (4.3.15)` indicated a version conflict. While project-level ([`android/build.gradle.kts`](android/build.gradle.kts:1)) and app-level ([`android/app/build.gradle.kts`](android/app/build.gradle.kts:1)) Gradle files correctly specified version `4.4.1`, the [`android/settings.gradle.kts`](android/settings.gradle.kts:1) file declared version `4.3.15`.

**Details:**
- Verified [`android/build.gradle.kts`](android/build.gradle.kts:1) uses `id("com.google.gms.google-services") version "4.4.1" apply false`.
- Verified [`android/app/build.gradle.kts`](android/app/build.gradle.kts:1) uses `id("com.google.gms.google-services") version "4.4.1"`.
- Updated [`android/settings.gradle.kts`](android/settings.gradle.kts:23) from `id("com.google.gms.google-services") version("4.3.15") apply false` to `id("com.google.gms.google-services") version("4.4.1") apply false`.

---
### Decision (Code)
[2025-05-29 02:13:47] - Added `databaseURL` to Firebase Web options to resolve runtime error.

**Rationale:**
The application was encountering a `FIREBASE FATAL ERROR: Cannot parse Firebase url. Please use https://<YOUR FIREBASE>.firebaseio.com` on the web platform. This indicated that the `databaseURL` was missing or incorrect in the `FirebaseOptions` for the web in [`lib/firebase_options.dart`](lib/firebase_options.dart:1). The project ID is `yacht-f816d`.

**Details:**
- Added the `databaseURL` parameter to the `web` static constant in the `DefaultFirebaseOptions` class in [`lib/firebase_options.dart`](lib/firebase_options.dart:58).
- Set the value of `databaseURL` to `"https://yacht-f816d.firebaseio.com"`.

---
### Decision (Debug)
[2025-05-29] - Resolved "Online Players Count" stuck on "Loading" due to Firebase Realtime Database issues.

**Root Causes & Rationale:**
1.  **Incorrect Database URL:** The primary issue was a mismatch between the Realtime Database URL configured in the application (code and native files like `google-services.json`) and the actual default database URL shown in the Firebase console (`https://yacht-f816d-default-rtdb.firebaseio.com` vs `https://yacht-f816d.firebaseio.com`). This led to Firebase SDK warnings about incorrect URL configuration and prevented successful database operations.
2.  **Overly Restrictive Security Rules:** After correcting the URL, a `permission_denied` error occurred during transactions on the `/online_users_count` path. The security rule `".write": false` for this path was too strict, as Firebase transactions require write permission on the target path.

**Fix Strategy & Details:**
1.  **Corrected Database URLs:**
    *   Updated `databaseURL` in [`lib/services/presence_service.dart`](lib/services/presence_service.dart:182) (within `FirebaseDatabase.instanceFor`) to `https://yacht-f816d-default-rtdb.firebaseio.com`.
    *   Updated `databaseURL` for `web` and `android` platforms in [`lib/firebase_options.dart`](lib/firebase_options.dart:58) to `https://yacht-f816d-default-rtdb.firebaseio.com`.
    *   Updated `firebase_url` in [`android/app/google-services.json`](android/app/google-services.json:4) to `https://yacht-f816d-default-rtdb.firebaseio.com`.
    *   Advised manual update for `DATABASE_URL` in `ios/Runner/GoogleService-Info.plist` if applicable.
2.  **Adjusted Security Rules:**
    *   Modified the Firebase Realtime Database security rule for the `/online_users_count` path from `".write": false` to `".write": "auth != null"`. This allows authenticated users (which `PresenceService` operations run as) to perform transactions while still preventing unauthenticated writes. The updated rules are:
      ```json
      {
        "rules": {
          "online_users": {
            "$uid": {
              ".write": "auth != null && auth.uid == $uid",
              ".read": "auth != null"
            }
          },
          "online_users_count": {
            ".read": "auth != null",
            ".write": "auth != null"
          }
        }
      }
      ```

**Impact:**
- The "Online Players Count" feature now functions correctly, updating in real-time.
- Firebase Realtime Database connections are stable, and security rules allow intended operations while preventing unauthorized access.
