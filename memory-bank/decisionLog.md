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
- ✅ 联机对战核心 Bug 已修复
- 🔧 代码细节优化进行中 (具体数量待定)

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

---
### Decision (App Name Regression Check)
[2025-05-29 12:13:31] - Checked `pubspec.yaml`.

**Action:** Verified `name` field is `simple_yacht`.
**Result:** Matches `expected_flutter_name`. No change needed for this field.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:13:58] - Updated `android/app/build.gradle.kts`.

**Action:**
1. Changed `namespace` from `"com.example.myapp"` to `"com.simpleyacht.app"`.
2. Changed `applicationId` from `"com.example.myapp"` to `"com.simpleyacht.app"`.
**Reason:** Align with new project identifier `com.simpleyacht.app`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:14:24] - Updated `android/app/src/main/AndroidManifest.xml`.

**Action:** Added `package="com.simpleyacht.app"` to the `<manifest>` tag.
**Reason:** To explicitly define the package name in the manifest, aligning with the `applicationId` and `namespace` set in `build.gradle.kts`. The `android:name=".MainActivity"` for the activity is correct as it's relative to this package.
---

---
### Decision (App Name Regression Check)
[2025-05-29 12:14:49] - Checked `android/app/src/main/kotlin/com/simpleyacht/app/MainActivity.kt`.

**Action:** Verified `package` declaration is `com.simpleyacht.app`.
**Result:** Matches `expected_android_app_id`. No change needed. File path is also consistent with the current `applicationId`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:15:22] - Updated `android/app/google-services.json`.

**Action:** Removed the client object associated with the old package name `"com.example.myapp"`.
**Reason:** To ensure only the configuration for the current `applicationId` (`"com.simpleyacht.app"`) is present.
---

---
### Decision (App Name Regression Check)
[2025-05-29 12:15:42] - Skipped iOS specific file checks.

**Action:** Attempted to read `ios/Runner.xcodeproj/project.pbxproj`.
**Result:** File not found. Assuming iOS platform is not configured for this project or the directory does not exist. iOS specific checks (`project.pbxproj`, `Info.plist`, `GoogleService-Info.plist`) will be skipped.
---

---
### Decision (App Name Regression Check)
[2025-05-29 12:15:57] - Checked `l10n.yaml`.

**Action:** Verified configuration values (`arb-dir`, `template-arb-file`, `output-localization-file`, `output-dir`).
**Result:** The configurations are generic (e.g., `template-arb-file: app_en.arb`) and do not contain hardcoded old or current project names that require modification within this file. No change needed for `l10n.yaml` itself. Subsequent checks will focus on `.arb` file content and Dart import paths for generated localization files.
---

---
### Decision (App Name Regression Check)
[2025-05-29 12:16:23] - Checked `.arb` files in `lib/l10n/`.

**Action:** Searched for the old identifier "myapp" within all `lib/l10n/app_*.arb` files.
**Result:** No instances of "myapp" found. No changes needed for the content of these `.arb` files regarding this specific old identifier.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:17:09] - Updated import in `lib/ui_screens/multiplayer_game_screen.dart`.

**Action:** Changed `import 'package:myapp/generated/app_localizations.dart';` to `import 'package:simple_yacht/generated/app_localizations.dart';`.
**Reason:** To align with the current project name `simple_yacht`.
**Note:** This change, as expected, triggered multiple Dart analysis errors across the project, which will be addressed by further import path corrections and code generation steps.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:17:36] - Updated imports in `lib/ui_screens/multiplayer_lobby_screen.dart`.

**Action:**
1. Changed `import 'package:myapp/generated/app_localizations.dart';` to `import 'package:simple_yacht/generated/app_localizations.dart';`.
2. Changed `import 'package:myapp/state_management/providers/user_providers.dart';` to `import 'package:simple_yacht/state_management/providers/user_providers.dart';`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:18:13] - Updated `firebase.json`.

**Action:**
1. Changed `flutter.platforms.android.default.appId` from `"1:60143534744:android:7944f8f59eb363877946ed"` to `"1:60143534744:android:72b20a740b8a90bc7946ed"`.
2. Changed `flutter.platforms.dart."lib/firebase_options.dart".configurations.android` from `"1:60143534744:android:7944f8f59eb363877946ed"` to `"1:60143534744:android:72b20a740b8a90bc7946ed"`.
**Reason:** To align the Firebase Android App ID with the current `applicationId` (`com.simpleyacht.app`) and the corresponding `mobilesdk_app_id` found in `google-services.json`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:19:05] - Updated `README.md`.

**Action:** Changed the main heading from `# myapp` to `# simple_yacht`.
**Reason:** To reflect the current project name.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:19:19] - Updated imports in `test/services/matchmaking_service_test.dart`.

**Action:** Changed three `package:myapp/...` import statements to `package:simple_yacht/...`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:19:34] - Updated import in `test/services/presence_service_test.dart`.

**Action:** Changed `import 'package:myapp/services/presence_service.dart';` to `import 'package:simple_yacht/services/presence_service.dart';`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:19:48] - Updated import in `test/widget_test.dart`.

**Action:** Changed `import 'package:myapp/main.dart';` to `import 'package:simple_yacht/main.dart';`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:20:04] - Updated import and comment in `test/widgets/game_over_dialog_test.mocks.dart`.

**Action:**
1. Changed comment `// in myapp/test/widgets/game_over_dialog_test.dart.` to `// in simple_yacht/test/widgets/game_over_dialog_test.dart.`.
2. Changed `import 'package:myapp/core_logic/game_state.dart' as _i2;` to `import 'package:simple_yacht/core_logic/game_state.dart' as _i2;`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:20:26] - Updated import in `test/widgets/game_over_dialog_test.dart`.

**Action:** Changed `import 'package:myapp/state_management/providers/game_providers.dart';` to `import 'package:simple_yacht/state_management/providers/game_providers.dart';`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:20:40] - Updated comment in `lib/main.dart`.

**Action:** Changed comment `// Assuming myapp is the project name` to `// Assuming simple_yacht is the project name`.
**Reason:** To reflect the current project name.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:20:55] - Updated import in `lib/ui_screens/multiplayer_lobby_screen.dart`.

**Action:** Changed `import 'package:myapp/services/multiplayer_service.dart';` to `import 'package:simple_yacht/services/multiplayer_service.dart';`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:21:12] - Updated imports in `lib/ui_screens/home_screen.dart`.

**Action:** Changed three `package:myapp/...` import statements to `package:simple_yacht/...`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:21:28] - Updated imports in `lib/widgets/scoreboard_widget.dart`.

**Action:** Changed two `package:myapp/...` import statements to `package:simple_yacht/...`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:21:46] - Updated `web/index.html`.

**Action:**
1. Changed `<meta name="apple-mobile-web-app-title" content="myapp">` to `<meta name="apple-mobile-web-app-title" content="Simple Yacht">`.
2. Changed `<title>myapp</title>` to `<title>Simple Yacht</title>`.
**Reason:** To reflect the current project name in user-visible places.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:22:15] - Updated `web/manifest.json`.

**Action:**
1. Changed `name` from `"myapp"` to `"Simple Yacht"`.
2. Changed `short_name` from `"myapp"` to `"SimpleYacht"`.
3. Changed `description` from `"A new Flutter project."` to `"Simple Yacht - A Yahtzee-style dice game."`.
**Reason:** To reflect the current project name and provide a more accurate description in user-visible places for the web application.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:33:39] - Updated import in `lib/ui_screens/home_screen.dart`.

**Action:** Changed `import 'package:myapp/core_logic/game_state.dart';` to `import 'package:simple_yacht/core_logic/game_state.dart';`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:34:02] - Updated import in `lib/widgets/scoreboard_widget.dart`.

**Action:** Changed `import 'package:flutter_gen/gen_l10n/app_localizations.dart';` to `import 'package:simple_yacht/generated/app_localizations.dart';`.
**Reason:** To use the correct import path for generated localization files after project name change and `flutter gen-l10n` execution.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:34:28] - Updated import in `lib/ui_screens/home_screen.dart`.

**Action:** Changed `import 'package:flutter_gen/gen_l10n/app_localizations.dart';` to `import 'package:simple_yacht/generated/app_localizations.dart';`.
**Reason:** To use the correct import path for generated localization files after project name change and `flutter gen-l10n` execution.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:34:49] - Updated import in `test/widgets/game_over_dialog_test.dart`.

**Action:** Changed `import 'package:myapp/widgets/game_over_dialog.dart';` to `import 'package:simple_yacht/widgets/game_over_dialog.dart';`.
**Reason:** To align with the current project name `simple_yacht`.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:36:03] - Updated `lib/main.dart`.

**Action:**
1. Renamed class `MyApp` to `SimpleYachtApp`.
2. Renamed class `_MyAppState` to `_SimpleYachtAppState`.
3. Updated references to `MyApp` to `SimpleYachtApp` within the file.
4. Removed `const` from `ProviderScope` child `SimpleYachtApp()` as `SimpleYachtApp` does not have a const constructor.
**Reason:** To align class names with the project name and resolve constructor issues.
---
---
### Decision (App Name Regression Fix)
[2025-05-29 12:36:46] - Updated `test/widget_test.dart`.

**Action:**
1. Changed `await tester.pumpWidget(const MyApp());` to `await tester.pumpWidget(const SimpleYachtApp());`.
2. Subsequently changed `await tester.pumpWidget(const SimpleYachtApp());` to `await tester.pumpWidget(SimpleYachtApp());` to resolve const constructor error.
**Reason:** To align class name with the main application class and resolve constructor issues.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:41:16] - Updated `lib/ui_screens/multiplayer_lobby_screen.dart`.

**Action:**
1. Changed `MultiplayerLobbyScreen` to extend `ConsumerStatefulWidget` and updated `createState`.
2. Moved Scaffold UI logic from `_createRoom` method to the `build` method of `_MultiplayerLobbyScreenState`.
3. Added `_joinRoom` method definition.
4. Scoped `AppLocalizations.of(context)!` calls within methods where `l10n` was undefined or used placeholder strings for missing localization keys (`gameModes`, `pleaseEnterRoomCode`).
**Reason:** To fix widget lifecycle and state management issues, resolve undefined `l10n` references, and address missing method errors. Placeholder strings for localization will need to be added to `.arb` files later.
---

---
### Decision (App Name Regression Fix)
[2025-05-29 12:45:21] - Updated `build` method signature in `_SimpleYachtAppState` in `lib/main.dart`.

**Action:** Changed `Widget build(BuildContext context, WidgetRef ref)` to `Widget build(BuildContext context)`. Access to `ref` will be via `this.ref` as provided by `ConsumerState`.
**Reason:** To resolve the persistent "Error: The method '_SimpleYachtAppState.build' has more required arguments than those of overridden method 'State.build'." error.
---

---
### Decision (App Name Regression Fix / Build Issue)
[2025-05-29 12:50:55] - Updated Android build directory in `android/build.gradle.kts`.

**Action:** Modified `newBuildDir` to point to `/var/tmp/simple_yacht_build` and adjusted subproject build directories accordingly.
**Reason:** To attempt to resolve "No space left on device" errors during Android build by using a different directory for build outputs.
---

---
### Decision (App Name Regression Fix / Build Issue)
[2025-05-29 1:07:54] - Reverted Android build directory changes in `android/build.gradle.kts`.

**Action:** Restored the logic to set the build directory to `../../build` relative to the project root.
**Reason:** To resolve "Gradle build failed to produce an .apk file. It's likely that this file was generated under /home/user/simple-yacht/build, but the tool couldn't find it." error, by ensuring Flutter tool and Gradle agree on the output path. Assumes disk space issues are now mitigated.
---

---
### Decision (Runtime Firebase Error Fix)
[2025-05-29 1:11:49] - Updated Android `appId` in `lib/firebase_options.dart`.

**Action:** Changed `android.appId` from `'1:60143534744:android:7944f8f59eb363877946ed'` to `'1:60143534744:android:72b20a740b8a90bc7946ed'`.
**Reason:** To ensure consistency with the `appId` used in `google-services.json` and `firebase.json` for the current package name `com.simpleyacht.app`. This might help resolve the "Database initialized multiple times" error.
---

---
### Decision (Debug)
[2025-05-29 14:39:00] - Bug Fix Strategy: Unified Firebase Realtime Database initialization in `lib/services/presence_service.dart`.

**Rationale:**
The error "@firebase/database: FIREBASE FATAL ERROR: Database initialized multiple times" suggested that `FirebaseDatabase` was being initialized or configured multiple times with potentially conflicting or redundant setups. `Firebase.initializeApp()` in `main.dart` already configures the default Firebase app instance using `firebase_options.dart`. The `PresenceService` was using `FirebaseDatabase.instanceFor()` with the same database URL, which could be interpreted by the SDK as a separate initialization attempt.

**Details:**
- Modified [`lib/services/presence_service.dart`](lib/services/presence_service.dart:180) to use `final database = FirebaseDatabase.instance;` instead of `FirebaseDatabase.instanceFor(...)`. This ensures that the service uses the already configured default database instance.
- This change led to new errors in [`test/services/presence_service_test.dart`](test/services/presence_service_test.dart:0) ("Undefined class 'FakeFirebaseDatabase'").

**Next Steps:**
- Investigate and resolve the "Undefined class 'FakeFirebaseDatabase'" error in the test file.
---

---
### Decision (Debug)
[2025-05-29 14:48:04] - Bug Fix Strategy: Corrected online user count inflation in `PresenceService`.

**Rationale:**
The `online_users_count` in Firebase Realtime Database was being incremented each time the `_goOnline` method was called for an already logged-in user (e.g., on service restart or repeated login events for the same user), without verifying if the user was already marked as online and counted. This led to an inflated count in the database (e.g., 10) while only one user entry existed in `/online_users`.

**Details:**
- Modified the `_goOnline` method in [`lib/services/presence_service.dart`](lib/services/presence_service.dart:70).
- Before setting the user's status to true and incrementing the global online count, the method now first reads the user's current status from `/online_users/{userId}`.
- If the user is already marked as online (status is true), the method skips incrementing the count and only ensures that the `onDisconnect` handlers are correctly set.
- The count is incremented only if the user was not previously marked as online.
---
### Decision (Debug)
[2025-05-29 15:01:00] - Bug Fix Strategy: Resolved "Undefined class 'FakeFirebaseDatabase'" in `test/services/presence_service_test.dart`.

**Rationale:**
The error "Undefined class 'FakeFirebaseDatabase'" occurred in [`test/services/presence_service_test.dart`](test/services/presence_service_test.dart:0) after [`lib/services/presence_service.dart`](lib/services/presence_service.dart:0) was modified to use `FirebaseDatabase.instance` internally, removing `FirebaseDatabase` from its constructor's required parameters. While the test file had the correct import for `firebase_database_mocks` and the dependency was in [`pubspec.yaml`](pubspec.yaml:0), the primary issue was that the `PresenceService` constructor was no longer set up to accept a `FirebaseDatabase` instance for testing.

**Details:**
1.  **Modified `PresenceService` Constructor**:
    *   The constructor in [`lib/services/presence_service.dart`](lib/services/presence_service.dart:21) was changed from `PresenceService(this._auth, this._database)` to `PresenceService(this._auth, {FirebaseDatabase? database}) : _database = database ?? FirebaseDatabase.instance;`. This allows an optional `FirebaseDatabase` instance to be injected for testing, while defaulting to `FirebaseDatabase.instance` for production.
2.  **Updated Test File Instantiation**:
    *   Calls to `PresenceService` in [`test/services/presence_service_test.dart`](test/services/presence_service_test.dart:41) (and other similar lines) were updated from `PresenceService(mockAuth, fakeDatabase)` to `PresenceService(mockAuth, database: fakeDatabase)`.
3.  **Updated Riverpod Provider**:
    *   The `presenceServiceProvider` in [`lib/services/presence_service.dart`](lib/services/presence_service.dart:197) was updated to call the constructor with the named parameter: `PresenceService(auth, database: database)`.
4.  **Dependency Verification**:
    *   Confirmed `firebase_database_mocks: ^0.7.1` is in [`pubspec.yaml`](pubspec.yaml:56).
    *   Confirmed `import 'package:firebase_database_mocks/firebase_database_mocks.dart';` is in [`test/services/presence_service_test.dart`](test/services/presence_service_test.dart:7).
5.  **Executed `flutter pub get`**: To ensure all dependencies are correctly resolved and the analyzer is updated.

**Impact:**
The test file [`test/services/presence_service_test.dart`](test/services/presence_service_test.dart:0) should now correctly recognize `FakeFirebaseDatabase` and be able to instantiate `PresenceService` with the mock database, allowing tests to run.

---
### Decision (Architecture Refinement)
[2025-05-29 15:07:48] - Refined and detailed the architecture for online presence and UI updates based on spec-pseudocode and existing Memory Bank context.

**Rationale:**
To address database online count inaccuracies and ensure real-time UI updates, by integrating fixes and patterns identified in previous debugging sessions and adhering to established system patterns. This refinement solidifies the implementation approach for `PresenceService` and related UI components.

**Details:**
- **PresenceService Enhancements:**
    - Confirmed idempotent `_goOnline` and `_goOffline` logic, including pre-checking user's current online status before modifying count.
    - Reinforced `onDisconnect` handler setup for both `/online_users/{userId}` and `/online_users_count`.
    - Confirmed constructor with optional `FirebaseDatabase` for testability.
    - Integration with `authStateChanges` and app lifecycle.
- **UI Update Mechanism:**
    - `PresenceService.getOnlinePlayersCountStream()` to return `Stream<AsyncValue<int>>`.
    - Riverpod `StreamProvider` (`onlinePlayersCountProvider`) to expose this stream.
    - UI widgets to use `ref.watch` and `AsyncValue.when` for loading/data/error handling.
- **Firebase RTDB Rules:**
    - Re-confirmed rules for `/online_users/{userId}` (user-specific write) and `/online_users_count` (authenticated transaction write).
- **Alignment:** Ensured consistency with Riverpod patterns from `systemPatterns.md` and previous decisions in `decisionLog.md`.

---
### Decision (Code)
[2025-05-29 15:14:11] - Refined `PresenceService` stream and provider for online player count.

**Rationale:**
To correctly implement the pattern where `StreamProvider` handles `AsyncValue` wrapping, the underlying service stream should emit raw data or throw errors. The previous implementation had the service stream (`getOnlinePlayersCountStream`) itself emitting `AsyncValue<int>`, leading to a nested `AsyncValue<AsyncValue<int>>` when consumed by the `StreamProvider<AsyncValue<int>>`.

**Details:**
- Modified `getOnlinePlayersCountStream` in [`lib/services/presence_service.dart`](lib/services/presence_service.dart:154) to return `Stream<int>`.
    - On successful data events, it emits the integer count.
    - On error (e.g., null database reference or unexpected data type), it throws an error, which `StreamProvider` will convert to `AsyncValue.error`.
- Changed `onlinePlayersCountProvider` in [`lib/services/presence_service.dart`](lib/services/presence_service.dart:244) to `StreamProvider.autoDispose<int>`.
- This ensures that `ref.watch(onlinePlayersCountProvider)` in the UI ([`lib/ui_screens/multiplayer_lobby_screen.dart`](lib/ui_screens/multiplayer_lobby_screen.dart:109)) correctly yields an `AsyncValue<int>`, and its `.when` data callback receives an `int`.

**Impact:**
Corrects the data flow for online player count, ensuring the UI receives and processes `AsyncValue<int>` as intended, resolving type errors in `MultiplayerLobbyScreen`.

---
### Decision (Architecture - Online User Counter Refinement)
[2025-05-29 15:26:00] - Refined architecture for online user counting in `PresenceService` based on new specifications.

**Rationale:**
To address persistent inaccuracies in the online user counter by implementing robust state management, re-entrancy protection, and eliminating service conflicts. This ensures that each unique user is counted exactly once, regardless of login frequency or client state transitions.

**Details & Key Architectural Decisions:**
1.  **Re-entrancy Protection in `PresenceService`**:
    *   **Decision**: Implement a boolean flag `_isProcessingAuthStateChange` within [`lib/services/presence_service.dart`](lib/services/presence_service.dart:0).
    *   **Purpose**: To prevent concurrent execution of the `_onAuthStateChanged` logic, particularly during rapid login/logout sequences or account switching. This ensures atomic processing of authentication state changes.
2.  **Dedicated State Handling Method**:
    *   **Decision**: Move the core logic from `_onAuthStateChanged` into a new private asynchronous method `_handleAuthStateChanged(newUser)`.
    *   **Purpose**: To provide a clear, focused method for managing the complexities of user state transitions (null -> user, user -> different user, user -> null), ensuring correct parameters and internal state (`_currentUser`, `_userStatusRef`) are used when calling `_goOnline` and `_goOffline`.
3.  **Parameterized `_goOffline` Method**:
    *   **Decision**: The `_goOffline` method in [`lib/services/presence_service.dart`](lib/services/presence_service.dart:0) will accept `userIdToMarkOffline` and `specificUserStatusRef` as parameters.
    *   **Purpose**: To ensure precise offline marking, especially critical during user account switches (where the `_currentUser` might have already changed) or when the service's `dispose` method needs to mark the last known user offline using a specific database reference.
4.  **Deprecation of `OnlinePresenceService`**:
    *   **Decision**: The existing [`lib/services/online_presence_service.dart`](lib/services/online_presence_service.dart:0) (found to be instantiated in [`lib/main.dart`](lib/main.dart:37)) will be deprecated and its usage removed.
    *   **Purpose**: To eliminate potential conflicts and redundant operations on the same Firebase Realtime Database paths (`/online_users`, `/online_users_count`) that the enhanced `PresenceService` will manage. This resolves hypothesis H4.
5.  **Coordination of Initial State**:
    *   **Decision**: The `PresenceService` constructor will primarily set up subscriptions. The initial `_goOnline` call for the starting user (if any) will be handled by the first invocation of the `_onAuthStateChanged_wrapper` -> `_handleAuthStateChanged` flow.
    *   **Purpose**: To avoid race conditions between constructor logic and the initial auth state event.

**Impact:**
-   Improved accuracy and reliability of the online user counter.
-   Simplified state management logic within `PresenceService`.
-   Elimination of potential conflicts from redundant presence services.
-   Clearer and more robust handling of various authentication and connection scenarios.

---
### Decision (Code - Presence Service Refinement)
[2025-05-29 23:33:00] - Implemented refined `PresenceService` logic and deprecated `OnlinePresenceService`.

**Rationale:**
To fix inaccuracies in the online user counter, as per the architectural decision logged on [2025-05-29 15:26:00]. This involved enhancing `PresenceService` with re-entrancy protection, a dedicated auth state handler, and a parameterized `_goOffline` method. The conflicting `OnlinePresenceService` was removed to prevent redundant operations.

**Details:**
- Modified [`lib/services/presence_service.dart`](lib/services/presence_service.dart:0):
    - Added `_isProcessingAuthStateChange` boolean flag.
    - Implemented `_onAuthStateChanged_wrapper(User? newUser)` to manage the flag and call `_handleAuthStateChanged`.
    - Created `_handleAuthStateChanged(User? newUser)` with detailed logic for user login, logout, and switch scenarios.
    - Modified `_goOffline(String userIdToMarkOffline, DatabaseReference specificUserStatusRef)` to accept specific user ID and database reference.
    - Updated `dispose()` method to use the parameterized `_goOffline`.
    - Ensured constructor and `authStateChanges` subscription use the new wrapper.
- Removed `OnlinePresenceService`:
    - Deleted file [`lib/services/online_presence_service.dart`](lib/services/online_presence_service.dart:0).
    - Updated [`lib/main.dart`](lib/main.dart:0) to remove instantiation and usage of `OnlinePresenceService`, relying solely on the Riverpod-managed `PresenceService`.

**Impact:**
- Improved reliability of online user counting.
- Reduced potential for race conditions during auth state changes.
- Eliminated conflicting presence management logic.
- Note: Test errors related to `FakeFirebaseDatabase` in [`test/services/presence_service_test.dart`](test/services/presence_service_test.dart:0) persist and will require separate investigation, potentially involving `flutter pub get` or deeper debugging of the `firebase_database_mocks` package integration.

---
### Decision (Presence Service - Online Count Fix Review)
[2025-05-30 01:05:34] - Reviewed and approved pseudocode for `PresenceService._goOnline` method fix to prevent online player count inflation.

**Rationale:**
The previous implementation of `_goOnline` could increment the global online player count each time it was called for a user, even if that user was already marked as online in the database. This led to an inflated count, especially if the service restarted or the method was invoked multiple times for an active session. The fix ensures the count is incremented only if the user is not already online or their status node doesn't exist.

**Implementation Details (based on reviewed pseudocode):**
- Before incrementing the global count, `_goOnline` now checks the user's current status at `_userStatusRef`.
- If `user_status_snapshot.exists` is true and `user_status_snapshot.value` is true, the global count is NOT incremented. `onDisconnect` handlers are re-applied to ensure robustness.
- The global count is incremented (via transaction) only if:
   - The user's status node (`_userStatusRef`) does not exist.
- If the user's status node exists but its value is not true, the count is also NOT incremented to prevent inflation from inconsistent states, and `onDisconnect` handlers are re-applied.
- `onDisconnect` handlers for both the user's status and the global count are set in all successful execution paths.

**Impact:**
- Corrects the online player count, ensuring it accurately reflects unique online users.
- Improves the robustness of the presence system against repeated `_goOnline` calls for the same active user.

---
### Decision (Code)
[2025-05-30 01:08:46] - Refined `PresenceService._goOnline` to fix online player count inflation.

**Rationale:**
The `_goOnline` method was incorrectly incrementing the global online player count if the user's status node existed but was not explicitly true, or if the method was called multiple times for an already online user. The fix ensures the count is incremented only when a user truly transitions to an online state for the first time in a session or if their status node didn't exist.

**Details:**
- Modified `_goOnline` in [`lib/services/presence_service.dart`](lib/services/presence_service.dart:100) to align with the provided pseudocode.
- The method now checks if the user's status node (`_userStatusRef`) exists and its value.
- Global count increment (`_onlineCountRef`) is conditional:
    - Incremented if `userStatusSnapshot.exists` is false.
    - Not incremented if `userStatusSnapshot.exists` is true but `userStatusSnapshot.value` is not true (to prevent inflation from inconsistent states).
    - Not incremented if `userStatusSnapshot.exists` is true and `userStatusSnapshot.value` is true (user already online).
- `onDisconnect` handlers are consistently applied in all relevant paths.

---
### Decision (Debug)
[2025-05-30 08:27:59] - Bug Fix Strategy: Resolved Flutter compilation error in `lib/ui_screens/multiplayer_lobby_screen.dart`.

**Rationale:**
The compilation initially failed due to non-ASCII characters being used as identifiers in `lib/ui_screens/multiplayer_lobby_screen.dart`. Subsequent attempts to remove these characters introduced syntax errors, primarily related to malformed `try-catch-finally` blocks and incorrect `ScaffoldMessenger.of(context).showSnackBar` calls within the `_createRoom` and `_joinRoom` methods.

**Details:**
1. Identified non-ASCII characters at the beginning of `lib/ui_screens/multiplayer_lobby_screen.dart` using the `flutter build apk --debug` output.
2. Removed the offending lines (1-54) using `apply_diff`.
3. Analyzed new Dart errors reported after the initial fix.
4. Corrected syntax errors in the `_createRoom` method, specifically ensuring the `finally` block was correctly structured and the `showSnackBar` call was properly terminated.
5. Corrected syntax errors in the `_joinRoom` method, ensuring the `finally` block was correctly structured, the `showSnackBar` call was properly terminated, and the `catch (e)` clause was correctly defined to make the exception variable `e` available.
6. Confirmed the fix by successfully running `flutter build apk --debug`.

---
### Decision (Debug)
[2025-05-30 08:44:29] - Bug Fix Strategy: Modified `GameRoom.fromMap` for safer type casting to address Dart Web compilation error 'InvalidType'.

**Rationale:**
The 'InvalidType' error during Dart Web compilation, particularly with stack traces involving `FutureOrNormalizer` and `ProgramCompiler._emitType`, suggested issues with type inference or handling of `dynamic`, `FutureOr`, or nullable types, especially during Firestore data deserialization. Direct `as` casts for `Map` types (`gameState`, `scores`) in `GameRoom.fromMap` were identified as potential points of failure if the actual data structure from Firestore didn't perfectly match or was null, leading to compiler confusion.

**Details:**
- Modified `GameRoom.fromMap` in [`lib/models/game_room.dart`](lib/models/game_room.dart:43) to use explicit null checks and `Map.from()` for `gameState` and `scores` fields.
  - Changed `gameState: map['gameState'] as Map<String, dynamic>?` to `gameState: map['gameState'] == null ? null : Map<String, dynamic>.from(map['gameState'] as Map)`.
  - Changed `scores: map['scores'] != null ? Map<String, int>.from(map['scores'] as Map) : null` to `scores: map['scores'] == null ? null : Map<String, int>.from(map['scores'] as Map)`.
This provides more explicit type handling, potentially resolving the compiler's inability to determine a valid type.

---
### Decision (Code)
[2025-05-30 08:56:00] - Updated default ELO and win rate settings.

**Rationale:**
To align with user requirements for default ELO (1000) and win rate (50%).

**Details:**
- Modified default ELO in [`lib/services/matchmaking_service.dart`](lib/services/matchmaking_service.dart:26), [`lib/services/matchmaking_service.dart`](lib/services/matchmaking_service.dart:98), [`lib/services/matchmaking_service.dart`](lib/services/matchmaking_service.dart:106), [`lib/services/matchmaking_service.dart`](lib/services/matchmaking_service.dart:108), [`lib/services/matchmaking_service.dart`](lib/services/matchmaking_service.dart:151).
- Modified default ELO in [`lib/models/matchmaking_queue.dart`](lib/models/matchmaking_queue.dart:37).
- Modified placeholder ELO and win rate in [`lib/ui_screens/multiplayer_lobby_screen.dart`](lib/ui_screens/multiplayer_lobby_screen.dart:176).
- Modified default ELO in [`lib/ui_screens/matchmaking/matchmaking_screen.dart`](lib/ui_screens/matchmaking/matchmaking_screen.dart:26).
- Attempted to modify default ELO in [`lib/services/user_service.dart`](lib/services/user_service.dart) but tool execution failed.

---
### Decision (Debug)
[2025-06-01 03:13:00] - Identified root causes for matchmaking and room joining failures.

**Rationale & Findings:**

**1. Matchmaking Failure ("两个玩家同时匹配无法找到对方"):**
   - **Root Cause:** The `MatchmakingService` ([`lib/services/matchmaking_service.dart`](lib/services/matchmaking_service.dart:1)) lacks the core logic to actually match players from the `matchmakingQueue`. Players are added to the queue, but no process exists to find suitable opponents and create game rooms for them.
   - **Evidence:** Review of `MatchmakingService` code shows `joinQueue` and `watchMatchmakingStatus` but no active matching algorithm.

**2. Room Joining Failure ("创建房间后，玩家无法进入房间进行对战"):**
   - **Root Cause 1 (Firestore Rules):** The Firestore security rule for updating `/gameRooms/{roomId}` ([`firestore.rules:34`](firestore.rules:34)) `request.resource.data.guestId == resource.data.guestId` prevents the `guestId` field from being changed from `null` to a player's UID. This effectively blocks any player from joining an empty room.
   - **Evidence:** Analysis of `firestore.rules` line 34.
   - **Root Cause 2 (Non-Transactional Join - Secondary):** The `MultiplayerService.joinRoom()` method ([`lib/services/multiplayer_service.dart`](lib/services/multiplayer_service.dart:41)) does not use a Firestore transaction for reading and updating the room document. This could lead to race conditions if multiple users attempt to join simultaneously (though the Firestore rule is the primary blocker).
   - **Evidence:** `MultiplayerService.joinRoom()` implementation.
   - **Associated Issue (Broken Room Code Join):** The "join by room code" feature is non-functional because the `GameRoom` model ([`lib/models/game_room.dart`](lib/models/game_room.dart:1)) does not have a `roomCode` field, and `MultiplayerService.createRoom()` ([`lib/services/multiplayer_service.dart`](lib/services/multiplayer_service.dart:12)) does not store one. `MultiplayerService.joinRoomByCode()` ([`lib/services/multiplayer_service.dart`](lib/services/multiplayer_service.dart:198)) queries a non-existent field.
   - **Evidence:** `GameRoom` model, `createRoom` and `joinRoomByCode` implementations.
   - **Associated Issue (Inconsistent Enum Serialization):** `MultiplayerService` uses `GameRoomStatus.waiting.toString().split('.').last` for status updates/queries, while the `GameRoom` model uses `status.name` for serialization. This inconsistency could lead to failed status checks or updates.
   - **Evidence:** Comparison of enum handling in `MultiplayerService` and `GameRoom` model.

**Details:**
- Analyzed `MatchmakingService`, `MultiplayerService`, `GameRoom` model, and `firestore.rules`.
- The matchmaking

---
### Decision (Debug)
[2025-06-03 01:16:01] - Bug Fix Strategy: Resolved Flutter build errors in `lib/services/matchmaking_service.dart`.

**Rationale:**
The build failed due to several syntax errors in `lib/services/matchmaking_service.dart`:
1. Missing closing brace `}` for the `getMatchStats` method.
2. Missing closing brace `}` for the `MatchmakingService` class.
3. Incomplete logic and missing semicolon in the `getMatchStats` method at line 374 (`final currentElo = eloDoc.exists && eloD`).
4. The `getMatchStats` method was not guaranteed to return a non-null `Map<String, dynamic>`.

**Details:**
- Added the missing closing brace for the `getMatchStats` method.
- Added the missing closing brace for the `MatchmakingService` class.
- Corrected the logic in `getMatchStats` to properly access ELO data from `eloDoc.data()`, provide default values if data is missing, and ensure it returns a `Map<String, dynamic>`.
- Specifically, `eloD` was corrected to `eloDoc.data()`, and the method now initializes `currentElo`, `gamesPlayed`, and `wins` with default values, then updates them if `eloDoc` exists and contains data.
- The method now consistently returns a map containing `currentElo`, `gamesPlayed`, and `wins`.

**Affected components/files:**
- [`lib/services/matchmaking_service.dart`](lib/services/matchmaking_service.dart)