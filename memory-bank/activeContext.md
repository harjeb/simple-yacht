# Active Context

  This file tracks the project's current status, including recent changes, current goals, and open questions.
  2025-05-23 02:56:27 - Log of updates made.

*

## Current Focus
* [2025-05-27 09:15:00] - **账号恢复功能重构完成:** 成功完成了账号恢复功能的架构重构，从复杂的自定义令牌认证方式改为简单的数据迁移方案。主要改进包括：
  - ✅ 重构 `recoverAccountByTransferCode` Cloud Function，实现数据迁移而非账号切换
  - ✅ 简化客户端恢复逻辑，移除自定义令牌相关代码
  - ✅ 使用 Firestore 事务确保数据迁移的原子性和一致性
  - ✅ 添加重复迁移检测和数据冲突处理
  - ✅ 优化错误处理和用户体验，确保恢复后正确导航
  - ✅ 解决了 Widget 生命周期问题和权限配置复杂性
* [2025-05-27 01:50:15] - **架构设计 ("清空本地数据"功能):** 根据用户请求和 `spec-pseudocode` 模式提供的规范，设计了新的"清空本地数据"功能。此功能允许用户清除设备本地的账户信息，而不影响服务器上的账户数据。明确了其在 [`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart:1)、[`lib/ui_screens/settings_screen.dart`](lib/ui_screens/settings_screen.dart:1) 和状态管理中的实现细节。
* [2025-05-26 19:50:00] - **代码实现 (新游戏流程错误修复):** 完成了"进入新游戏后不显示任何画面"错误的修复。关键更改包括：在 `GameState` 中添加 `initial()` 工厂构造函数，更新 `GameStateNotifier` 以使用此构造函数，增强 `GameScreen` 的健壮性以处理无效游戏状态，并为 `GameScreenRoute` 添加导航守卫。同时修复了由此产生的编译错误和本地化文件格式问题。
* [2025-05-26 13:34:00] - **架构更新 (新游戏流程):** 更新了 [`memory-bank/architecture.md`](memory-bank/architecture.md:1) 以解决"新游戏不显示任何画面"的错误。重点关注游戏状态 (`GameState`) 的正确初始化 (使用 `GameState.initial()`)，[`GameScreen`](lib/ui_screens/game_screen.dart:1) 基于 `isGameInProgress` 和 `gameOver` 的渲染逻辑，以及 [`AppRouter`](lib/navigation/app_router.dart:1) 中相关的导航守卫。
* [{{YYYY-MM-DD HH:MM:SS}}] - **文档更新 (账号删除流程):** 更新了 [`memory-bank/architecture.md`](memory-bank/architecture.md:0) 以准确反映账号删除成功后的新行为，包括用户登出、本地数据清除 ([`LocalStorageService.clearAllUserData()`](lib/services/local_storage_service.dart:44))、应用状态重置 (Riverpod Providers) 以及导航至初始屏幕 ([`/splash`](lib/ui_screens/splash_screen.dart:1))。
* [2025-05-26 12:51:56] - **代码实现 (账号删除流程修复):** 实现了删除账号成功后应用正确返回创建界面的修复。关键更改包括：在 `UserAccountService` 中增加登出和清除本地缓存的逻辑；在 `SettingsScreen` 中增加显式导航到 `/splash` 并使相关 Riverpod Provider 失效。
* [2025-05-26 12:48:02] - **架构更新 (账号删除流程):** 基于提供的伪代码，更新了 [`memory-bank/architecture.md`](memory-bank/architecture.md:0) 以详细说明账号删除成功后客户端状态的正确清理和到初始界面的导航逻辑。重点包括 `UserService` 的协调角色、`AuthService.signOut()` 的调用、本地缓存清理、Riverpod Provider 的重置以及通过 `GoRouter` 进行的强制导航。
* [{{YYYY-MM-DD HH:MM:SS}}] - **问题分析与规范定义 (账号删除流程):** 分析了用户删除账号后应用未正确返回创建账号界面的问题。定义了当前问题流程和期望的修复流程伪代码，重点关注客户端状态重置和导航逻辑。
* [2025-05-25 13:53:23] - **代码修复 (语法错误):** 修复了 [`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1) 中的语法错误，主要是添加了缺失的闭合括号。
* [2025-05-25 12:50:00] - **架构设计 (用户名保存):** 正在为解决用户创建时保存用户名失败（提示"请重试"）的问题设计详细的架构方案。方案将涵盖用户输入验证、网络问题、后端服务错误（包括使用 Cloud Function 和 Firestore 事务确保用户名唯一性）、本地存储问题和并发问题。
* [2025-05-25 12:42:36 UTC] - Firestore `PERMISSION_DENIED` 错误已通过部署新的安全规则解决。 (原记录时间: 2025-05-25 12:37:12)
* [2025-05-25 11:58:51] - 实现 Firestore 数据库未找到 (`NOT_FOUND`) 错误的健壮处理。修改了 `UserService` 以在创建或获取用户配置时检测并抛出此特定错误。更新了 `AnonymousSignInNotifier` 和 `UsernameSetupScreen` 以捕获此错误并向用户显示友好的、本地化的错误消息。确保在异步操作中正确管理加载状态。
* [2025-05-25 06:32:15] - 为 Firebase 匿名登录流程添加详细日志，以帮助诊断 Firebase 不再记录匿名登录的问题。涉及文件：[`lib/services/auth_service.dart`](lib/services/auth_service.dart:1), [`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1), [`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:1).
* [2025-05-25 06:26:18] - 更新 Memory Bank 以反映 Firebase 匿名用户创建后 UI 按钮持续加载问题的修复。重点是新的启动流程 (`SplashScreen`) 和状态管理 (`AnonymousSignInNotifier`)。
* [2025-05-24 12:28:15] - Core local features (Game Over, Leaderboard, Username Setup, Login Removal) implemented. Next: Implement Firebase backend and online features.
* [2025-05-24 12:40:17] - Generating specifications for: 1. Bug fix: "Continue Game" button incorrectly shown for new users. 2. Enhancement: Display username on home screen.
* [2025-05-24 12:44:07] - Defined architecture and updated Memory Bank for: 1. Bug fix: "Continue Game" button incorrectly shown for new users. 2. Enhancement: Display username on home screen.
* [{{TIMESTAMP}}] - TDD: Skipped unit and widget tests for GameOverDialog, Leaderboard, and Username Setup features as per user instruction.
* [2025-05-24 13:29:07] - Defining architecture and updating Memory Bank for displaying personal best score on the home screen.
* [2025-05-24 13:34:29] - Implemented feature to display personal best score on the home screen.
* [2025-05-24 13:38:37] - 审查了在主屏幕右上角使用 `Stack` 和 `Positioned` 显示用户名的伪代码架构。
* [2025-05-24 14:03:00] - Designing and documenting the detailed architecture for Firebase backend integration (Firebase Authentication, Cloud Firestore, Cloud Functions) and the transfer code system for account persistence and recovery.
* [2025-05-25 06:15:00] - 诊断 Flutter 应用中 Firebase 匿名认证后 UI 加载状态持续存在的问题，并制定解决方案架构。
* [2025-05-26 19:50:00] - **代码实现 (新游戏流程错误修复):**
    *   [`lib/core_logic/game_state.dart`](lib/core_logic/game_state.dart:1): 添加了 `GameState.initial()` 工厂构造函数，用于正确初始化新游戏的状态，确保 `isGameInProgress` 设置为 `true`。
    *   [`lib/state_management/providers/game_providers.dart`](lib/state_management/providers/game_providers.dart:1): 更新了 `GameStateNotifier.resetAndStartNewGame()` (原 `resetGame`) 方法，使其调用 `GameState.initial()` 来设置初始游戏状态。
    *   [`lib/widgets/game_over_dialog.dart`](lib/widgets/game_over_dialog.dart:1): 更新了对 `resetGame` 的调用为 `resetAndStartNewGame`。
    *   [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1): 更新了对 `resetGame` 的调用为 `resetAndStartNewGame`。
    *   [`test/widgets/game_over_dialog_test.dart`](test/widgets/game_over_dialog_test.dart:1): 更新了 mock 调用以匹配重命名后的 `resetAndStartNewGame`。
    *   [`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1): 增强了 `GameScreen` 的健壮性，在 `build` 方法开始时检查游戏状态。如果 `!isGameInProgress && !isGameOver`，则显示加载指示器并异步导航回主屏幕 (`/`)。
    *   [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1): 为 `/game` 路由添加了 `redirect` 逻辑。如果 `!gameState.isGameInProgress && !gameState.isGameOver`，则重定向到主屏幕 (`/`)。
    *   本地化文件 (`.arb`): 为 [`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1) 中新的重定向消息添加了 `invalidGameStateRedirecting` 键到所有 `.arb` 文件 ([`lib/l10n/app_en.arb`](lib/l10n/app_en.arb:1) 等)。修复了多个 `.arb` 文件中的 JSON 格式问题。
    *   执行了 `flutter gen-l10n` 命令以重新生成本地化 Dart 文件。
## Recent Changes
* [2025-05-26 13:52:53] - **文档审查 (新游戏流程):** 审查了 [`memory-bank/architecture.md`](memory-bank/architecture.md:1) 中关于新游戏启动流程和游戏状态管理的文档。确认文档已准确反映了最新的代码更改，包括 `GameState.initial()` 的使用、`GameStateNotifier.resetAndStartNewGame()` 的更新、`GameScreen` 的健壮性处理以及导航守卫逻辑。无需进一步修改 `architecture.md`。
* [2025-05-26 13:34:00] - **架构更新 (新游戏流程):** 更新了 [`memory-bank/architecture.md`](memory-bank/architecture.md:1) 以详细说明解决"新游戏不显示任何画面"错误的架构调整。这包括对游戏状态初始化 (`GameState.initial()`)、[`GameScreen`](lib/ui_screens/game_screen.dart:1) 渲染逻辑和导航守卫的澄清。
* [2025-05-26 12:51:56] - **代码实现 (账号删除流程修复):**
* [{{YYYY-MM-DD HH:MM:SS}}] - **文档更新 (账号删除流程):** 更新了 [`memory-bank/architecture.md`](memory-bank/architecture.md:0) 以准确反映账号删除成功后的新行为。文档现在明确了用户登出、通过 [`LocalStorageService.clearAllUserData()`](lib/services/local_storage_service.dart:44) 清除本地数据、重置 Riverpod Providers 以及导航至初始屏幕 [`/splash`](lib/ui_screens/splash_screen.dart:1) 的完整流程。关键代码点包括 [`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart:44), [`lib/services/user_service.dart`](lib/services/user_service.dart:1), 和 [`lib/ui_screens/settings_screen.dart`](lib/ui_screens/settings_screen.dart:1)。
    *   [`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart:44): 添加 `clearAllUserData()` 方法。
    *   [`lib/services/user_service.dart`](lib/services/user_service.dart:1): 注入 `AuthService` 和 `LocalStorageService`，并在 `deleteCurrentUserAccount` 成功后调用 `signOut()` 和 `clearAllUserData()`。
    *   [`lib/ui_screens/settings_screen.dart`](lib/ui_screens/settings_screen.dart:1): 在账号删除成功后，显式 `invalidate` 多个用户和游戏相关的 Riverpod providers，并使用 `GoRouter.of(context).go('/splash')` 进行导航。
* [2025-05-26 12:48:02] - **架构更新 (账号删除流程):** 更新了 [`memory-bank/architecture.md`](memory-bank/architecture.md:0) 以包含账号删除后客户端状态重置和导航的详细架构。强调了 `UserService`、`AuthService`、本地缓存清理、Provider 重置和导航服务在确保正确流程中的作用。
* [2025-05-25 14:41:49] - **代码实现 (Firestore 安全规则):** 根据用户提供的规范，完全重写了 [`firestore.rules`](firestore.rules:1) 文件的内容。新规则定义了对 `users` 和 `scores` (或 `leaderboard`) 集合的访问权限，包括创建、读取、更新和删除操作的条件。
* [2025-05-25 14:02:00] - **代码修复 (路由错误):** 修复了 [`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:49) 中的导航错误，将目标路径从 `/home` 更改为正确的 `/`。
* [2025-05-25 12:50:00] - **架构更新 (用户名保存流程):**
    *   更新了 [`memory-bank/architecture.md`](memory-bank/architecture.md:1) 新增 "用户名创建与管理流程" 章节，详细描述了从前端验证到后端唯一性检查（推荐 Cloud Function + Firestore 事务）及错误处理的完整流程。
    *   更新了 [`memory-bank/decisionLog.md`](memory-bank/decisionLog.md:1) 记录了采纳此综合架构方案的决策，包括对各故障点的具体策略。
    *   更新了 [`memory-bank/systemPatterns.md`](memory-bank/systemPatterns.md:1) 新增 "使用 Cloud Function 和 Firestore 事务实现唯一性约束" 的架构模式。
* [2025-05-25 12:11:12] - **架构更新 (Firestore 数据模型):** 为 `users` 和 `leaderboard` 集合设计了详细的数据模型，并更新了 [`memory-bank/architecture.md`](memory-bank/architecture.md:1) 以包含此设计。明确了模型与现有安全规则 ([`memory-bank/security_rules.md`](memory-bank/security_rules.md:1)) 的对应关系。
* [2025-05-25 12:04:14] - **架构更新 (Firestore 安全规则):** 基于应用需求审查并设计了一套更安全的 Firestore 安全规则。新规则遵循最小权限原则，并考虑了用户认证和基本数据验证。将详细的安全规则及其设计原则记录在新的 Memory Bank 文件 [`memory-bank/security_rules.md`](memory-bank/security_rules.md:1) 中。同时，更新了 [`memory-bank/architecture.md`](memory-bank/architecture.md:1) 以包含对新安全规则文档的引用。指出了复杂唯一性约束（如用户名唯一性）应通过 Cloud Functions 实现。
* [2025-05-25 11:58:51] - **代码实现 (Firestore NOT_FOUND 错误处理):**
    *   修改了 [`lib/services/user_service.dart`](lib/services/user_service.dart:1) 中的 `createNewUser` 和 `getUserProfile` 方法，以捕获 `FirebaseException` (code `not-found`) 并重新抛出，以便调用方可以专门处理它。添加了对 `e.message` 的空值检查。
    *   修改了 [`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1) 中的 `AnonymousSignInNotifier`，在其 `attemptAnonymousSignIn` 方法中，在匿名登录成功后尝试调用 `_userAccountService.getUserProfile`。如果此调用因 Firestore 数据库未找到而失败，则设置特定的错误消息 (`firestoreDatabaseNotConfiguredError`)。
    *   修改了 [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1) 中的 `_createNewAccount` 方法，以捕获从 `createNewUser` 抛出的 `FirebaseException` (code `not-found`)，并显示本地化的 `firestoreDatabaseNotConfiguredError` 消息。
    *   为所有 `.arb` 本地化文件 ([`lib/l10n/app_en.arb`](lib/l10n/app_en.arb:1) 等) 添加了新的本地化键 `firestoreDatabaseNotConfiguredError` 及其翻译。
    *   运行了 `flutter gen-l10n` 以更新生成的本地化 Dart 文件。
* [2025-05-25 11:39:30] - **代码实现 (SplashScreen 导航修复):** 修改了 [`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:1) 中的导航逻辑。在匿名登录成功后，将 `GoRouter.of(context).refresh()` 替换为 `context.go('/home')`，以解决潜在的路由循环和卡顿问题。审查了 [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1) 的 `redirect` 逻辑，确认其能够正确处理新的导航流程。
* [2025-05-25 06:32:15] - **代码实现 (日志添加):** 在以下文件中添加了 `developer.log` 语句以追踪匿名登录流程：[`lib/services/auth_service.dart`](lib/services/auth_service.dart:1), [`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1) (AnonymousSignInNotifier), [`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:1).
* [2025-05-25 06:26:18] - **代码实现:** 修复了 Firebase 匿名用户创建后 UI 按钮持续加载的问题。引入了 `AnonymousSignInNotifier` ([`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1)) 和 `SplashScreen` ([`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:1))。更新了 [`lib/main.dart`](lib/main.dart:1) 和 [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1) 以及相关的本地化文件。
* [2025-05-25 06:15:00] - **架构更新:** 针对 Flutter 应用中 Firebase 匿名认证后 UI 加载状态持续存在的问题，更新了 Memory Bank ([`memory-bank/decisionLog.md`](memory-bank/decisionLog.md), [`memory-bank/progress.md`](memory-bank/progress.md), [`memory-bank/systemPatterns.md`](memory-bank/systemPatterns.md), [`memory-bank/activeContext.md`](memory-bank/activeContext.md)).
* [2025-05-25 05:42:31] - **Bug Fix:** Implemented Firebase anonymous sign-in on app startup in [`lib/main.dart`](lib/main.dart:1) to resolve "认证失败，请重启应用" error. This ensures `currentUser` is not null during username setup. Updated [`memory-bank/decisionLog.md`](memory-bank/decisionLog.md:1) and [`memory-bank/architecture.md`](memory-bank/architecture.md:1).
* [2025-05-25 05:10:02] - Updated [`.gitignore`](.gitignore) to include `node_modules/`.
* [2025-05-24 15:06:27] - **翻译文件准备完成:** 为德语 (de), 西班牙语 (es), 法语 (fr), 日语 (ja), 俄语 (ru) 更新了 `.arb` 文件。添加了缺失的键，并确保需要翻译的键已标记 `(NEEDS TRANSLATION)`。执行了 `flutter gen-l10n`.
* [2025-05-24 14:55:00] - 评估项目中未完成的翻译任务。此任务主要影响本地化文件，对整体架构影响较小。

* [2025-05-23 02:56:59] - Memory Bank initialized with core files.
* [2025-05-23 03:12:51] - Implemented core game logic (`game_state.dart`, `dice_roller.dart`, `scoring_rules.dart`).
* [2025-05-23 03:22:59] - Created UI screens: `home_screen.dart`, `game_screen.dart`.
* [2025-05-23 03:22:59] - Created UI widgets: `dice_widget.dart`, `scoreboard_widget.dart`.
* [2025-05-23 03:22:59] - Implemented navigation with GoRouter: `app_router.dart`, updated `main.dart`.
* [2025-05-23 03:22:59] - Implemented state management with Riverpod: `game_providers.dart`.
* [2025-05-23 03:22:59] - Connected UI to core game logic.
* [2025-05-23 03:31:51] - Added `shared_preferences` to `pubspec.yaml`.
* [2025-05-23 03:31:51] - Created `lib/services/local_storage_service.dart` for high score persistence.
* [2025-05-23 03:31:51] - Updated `lib/state_management/providers/game_providers.dart` to save high scores.
* [2025-05-23 03:31:51] - Updated `lib/ui_screens/home_screen.dart` to display high scores.
* [2025-05-23 03:33:11] - Updated `lib/widgets/dice_widget.dart` to include dice rolling animations.
* [2025-05-23 03:36:35] - Added `yahtzeeBonusCount` to `lib/core_logic/game_state.dart`.
* [2025-05-23 03:36:35] - Added `yahtzeeBonusScoreProvider` to `lib/state_management/providers/game_providers.dart`.
* [2025-05-23 03:36:35] - Refined UI and interactions in `lib/widgets/scoreboard_widget.dart`.
* [2025-05-23 04:39:16] - Fixed dice re-rolling issue in `lib/core_logic/game_state.dart`.
* [2025-05-23 04:39:16] - Added `rollId` to `lib/core_logic/game_state.dart` and `lib/state_management/providers/game_providers.dart`.
* [2025-05-23 04:39:16] - Refactored `lib/widgets/dice_widget.dart` to use `rollId` for improved animation control, fixing issues with animation on hold, same-value rolls, and final orientation.
* [2025-05-23 04:39:16] - Corrected `GameScreen` display by fixing routing in `lib/navigation/app_router.dart` and ensuring `ProviderScope` in `lib/main.dart`.
* [2025-05-23 05:06:22] - Implemented automatic first roll on game start and new turn in `lib/core_logic/game_state.dart` and `lib/state_management/providers/game_providers.dart`. Max manual rolls per turn is now 2.
* [2025-05-23 05:20:36] - Added an exit button to `lib/ui_screens/game_screen.dart`.
* [2025-05-23 06:03:58] - Configured `pubspec.yaml`, `l10n.yaml` for internationalization.
* [2025-05-23 06:03:58] - Created `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`.
* [2025-05-23 06:03:58] - Updated `lib/main.dart` for localization delegates and locale resolution.
* [2025-05-23 06:03:58] - Localized text in `lib/ui_screens/home_screen.dart`, `lib/ui_screens/game_screen.dart`, `lib/widgets/scoreboard_widget.dart`.
* [2025-05-23 06:03:58] - Created `lib/state_management/providers/locale_provider.dart` for managing app locale.
* [2025-05-23 06:03:58] - Created `lib/ui_screens/settings_screen.dart` with language switching UI.
* [2025-05-23 06:03:58] - Updated routing in `lib/navigation/app_router.dart` and `lib/ui_screens/home_screen.dart` for settings page.

* [2025-05-23 08:19:15] - Modified dice selection logic: players now select dice to discard (not keep). UI updated with red selection box and 'X' icon for discarded dice. Animation logic adjusted accordingly. Files changed: `lib/core_logic/game_state.dart`, `lib/widgets/dice_widget.dart`.
* [2025-05-23 08:22:59] - Fixed issue where automatic dice rolls (on new game/new turn) were not occurring after the dice selection logic change. Modified `_performInitialRoll()` in `lib/core_logic/game_state.dart` to directly set dice values and ensure `isHeld` is `false` for all dice, aligning with the new "select to discard" logic.
* [2025-05-23 08:28:16] - Implemented feature: After a manual dice roll (`Roll Dice` button), all dice selections (for discarding) are cleared. This was achieved by setting `die.isHeld = false` for all dice at the end of the `rollDice()` method in `lib/core_logic/game_state.dart`.
* [2025-05-23 08:38:42] - Fixed dice rolling animation. Replaced `rollId` with a `RollEvent` object (containing `id`, `rolledIndices`, `isInitialRoll`) in `GameState` and relevant providers. Updated `DiceWidget` to use `RollEvent` to correctly trigger animations for dice that were part of the roll. Files changed: `lib/core_logic/game_state.dart`, `lib/state_management/providers/game_providers.dart`, `lib/widgets/dice_widget.dart`.
* [2025-05-24 10:59:00] - Defined specifications and pseudocode for: game over UI with reset, enhanced local leaderboard (top 10 scores), mandatory username setup on first launch, and removal of all third-party login functionalities.
* [2025-05-24 11:03:53] - Completed system architecture design for game over UI, leaderboard, username setup, and third-party login removal. Updated relevant Memory Bank files ([`memory-bank/architecture.md`](memory-bank/architecture.md), [`memory-bank/decisionLog.md`](memory-bank/decisionLog.md), [`memory-bank/progress.md`](memory-bank/progress.md)).
* [2025-05-24 12:28:15] - Implemented core features: Game Over UI, local leaderboard (top 10 with username via `shared_preferences`), mandatory username setup on first launch, and verified removal of third-party login elements. Created/updated files: [`lib/widgets/game_over_dialog.dart`](lib/widgets/game_over_dialog.dart:1), [`lib/core_logic/score_entry.dart`](lib/core_logic/score_entry.dart:1), [`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart:1), [`lib/services/leaderboard_service.dart`](lib/services/leaderboard_service.dart:1), [`lib/state_management/providers/leaderboard_providers.dart`](lib/state_management/providers/leaderboard_providers.dart:1), [`lib/ui_screens/leaderboard_screen.dart`](lib/ui_screens/leaderboard_screen.dart:1), [`lib/services/user_service.dart`](lib/services/user_service.dart:1), [`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1), [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1). Updated [`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1), [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1), [`lib/main.dart`](lib/main.dart:1), and relevant localization files.
* [2025-05-24 12:49:21] - Applied bug fix and enhancement:
    * **Bug Fix (Continue Game Button):** Modified [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1) to call `setToInitialState()` on `gameStateProvider` after new user setup. Updated [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) "Continue Game" button visibility logic to `isGameInProgress && (currentRound > 1 || (currentRound == 1 && rollsLeft < 2) || scores.values.any((s) => s != null))`.
    * **Enhancement (Display Username):** Modified [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) AppBar to display username from `usernameProvider`, with loading (username null) and empty string handling. Imported `GameState` class into `home_screen.dart`.
* [2025-05-24 13:22:42] - Updated home screen UI text for high score display from "Leaderboard" to "High Score" (or equivalent translations). This involved:
    * Adding new key `highScoreDisplay` to all `.arb` localization files ([`lib/l10n/app_en.arb`](lib/l10n/app_en.arb), [`lib/l10n/app_zh.arb`](lib/l10n/app_zh.arb), [`lib/l10n/app_de.arb`](lib/l10n/app_de.arb), [`lib/l10n/app_es.arb`](lib/l10n/app_es.arb), [`lib/l10n/app_fr.arb`](lib/l10n/app_fr.arb), [`lib/l10n/app_ja.arb`](lib/l10n/app_ja.arb), [`lib/l10n/app_ru.arb`](lib/l10n/app_ru.arb)).
    * Regenerating localization classes using `flutter gen-l10n`.
    * Updating the `Text` widget in [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart) to use `localizations.highScoreDisplay`.
* [2025-05-26 08:31:00] - **安全审查完成 (Firestore 规则):** 发现并记录了当前 Firestore 安全规则中的多个高风险漏洞，包括排行榜完全开放访问 (`allow read: true`)、transferCode 查询权限过宽、时间戳验证缺失等问题。创建了详细的安全改进建议文档 [`firestore_security_recommendations.md`](firestore_security_recommendations.md:1)，并更新了 [`memory-bank/decisionLog.md`](memory-bank/decisionLog.md:1)。建议立即实施安全修复以防止数据泄露和恶意攻击。
## Open Questions/Issues
* [2025-05-25 14:02:00] - [Debug Status Update: Issue Resolved] 解决了 "Error no routes for location：/home" 路由错误。通过修改 [`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:49) 将导航目标从 `/home` 更改为 `/`。

* [2025-05-26 10:08:28] - [Debug Status Update: Fixing ESLint error in `deleteUserData`] Removed trailing whitespace from line 99 of [`functions/index.js`](functions/index.js:99) to resolve ESLint error "Trailing spaces not allowed" that was blocking Cloud Function deployment.
* [2025-05-26 10:02:51] - [Debug Status Update: Investigating `deleteUserData` `invalid-argument` error] Applied changes to [`functions/index.js`](functions/index.js:1) to improve `uid` extraction logic (checking `data.uid` and `data.data.uid`) and enhance logging for incoming `data` structure to diagnose "uid" argument issue in `deleteUserData` Cloud Function.
*
* [2025-05-23 08:08:27] - Updated home screen to show "Continue Game" button if a game is in progress. Updated game screen exit button to 'X' icon and added a confirmation dialog before exiting a game. Updated relevant localization files.
* [2025-05-23 08:12:11] - Fixed bug where "Continue Game" button was still shown after exiting a game. Implemented `setToInitialState` in `GameStateNotifier` to correctly reset `isGameInProgress` to false when exiting.
* [2025-05-23 08:51:29] - Updated localization files (de, es, ja, ru, fr) with new entries for 'continueGame' and 'exitGameConfirmation'.
* [2025-05-24 13:07:00] - 审查并确认了"游戏结束后排行榜未显示成绩"问题的规范和伪代码。解决方案与现有架构一致，准备实施。
* [2025-05-24 13:08:59] - Modified `lib/ui_screens/game_screen.dart` to save score to leaderboard when game is over. Added calls to `leaderboardService.addScore` and `ref.refresh(leaderboardProvider)` within the `isGameOverProvider` listener.
* [2025-05-24 13:34:29] - Updated [`lib/services/leaderboard_service.dart`](lib/services/leaderboard_service.dart) to add `getPersonalBestScore` method.
* [2025-05-24 13:34:29] - Created [`lib/state_management/providers/personal_best_score_provider.dart`](lib/state_management/providers/personal_best_score_provider.dart) for personal best score.
* [2025-05-24 13:34:29] - Updated [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart) to display personal best score using the new provider and `intl` for date formatting.
* [2025-05-24 13:34:29] - Added new localization keys (`yourPersonalBestScoreLabel`, `noPersonalBestScore`, `scoreLabel`, `dateTimeLabel`) to all `.arb` files ([`lib/l10n/app_en.arb`](lib/l10n/app_en.arb), [`lib/l10n/app_zh.arb`](lib/l10n/app_zh.arb), [`lib/l10n/app_de.arb`](lib/l10n/app_de.arb), [`lib/l10n/app_es.arb`](lib/l10n/app_es.arb), [`lib/l10n/app_fr.arb`](lib/l10n/app_fr.arb), [`lib/l10n/app_ja.arb`](lib/l10n/app_ja.arb), [`lib/l10n/app_ru.arb`](lib/l10n/app_ru.arb)) and ran `flutter gen-l10n`.
* [2025-05-24 13:41:30] - Implemented username display on the home screen's top-right corner using Stack, Positioned, and Chip widgets. Modified user_providers.dart to add `usernameAsyncProvider` (FutureProvider) to correctly use `AsyncValue.when()` for loading/error/data states as per pseudocode. Updated home_screen.dart to use the new provider.
* [2025-05-24 14:03:00] - Completed detailed architecture design for Firebase backend integration and transfer code system. Updated [`memory-bank/architecture.md`](memory-bank/architecture.md:1), [`memory-bank/productContext.md`](memory-bank/productContext.md:1), and [`memory-bank/decisionLog.md`](memory-bank/decisionLog.md:1).
* [2025-05-24 {{HH:MM:SS}}] - **本地化字符串补充完成:** 为 [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1) 和 [`lib/ui_screens/settings_screen.dart`](lib/ui_screens/settings_screen.dart:1) 中因 Firebase 和引继码功能新增的文本元素补充了本地化支持。所有相关键已在 `.arb` 文件中验证/添加，并重新生成了本地化类。
* [2025-05-25 04:58:34] - Firebase Cloud Functions successfully migrated from TypeScript to JavaScript. Related configurations and documentation updated.
* [2025-05-25 05:27:56] - [Debug Status Update: Resolved] Build failure due to missing `lib/firebase_options.dart` resolved by running `flutterfire configure --project=yacht-f816d -y`.
* [2025-05-25 05:39:35] - [Debug Status Update: Issue Identified] Identified root cause of "认证失败，请重启应用" error: Missing Firebase anonymous sign-in call during app startup in `lib/main.dart`. This leads to `currentUser` being null in `UsernameSetupScreen`.
* [2025-05-25 10:17:12] - 修复了因 [`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart) 中本地化键 (`loadingLabel`, `errorLabel`, `retryButtonLabel`, `signInFailedGeneric`) 缺失或值不正确导致的 Flutter 构建错误。更新了 [`lib/l10n/app_en.arb`](lib/l10n/app_en.arb) 中的 `signInFailedGeneric` 值。检查并确认了其他语言文件 ([`lib/l10n/app_de.arb`](lib/l10n/app_de.arb), [`lib/l10n/app_es.arb`](lib/l10n/app_es.arb), [`lib/l10n/app_fr.arb`](lib/l10n/app_fr.arb), [`lib/l10n/app_ja.arb`](lib/l10n/app_ja.arb), [`lib/l10n/app_ru.arb`](lib/l10n/app_ru.arb)) 中的键已存在且已正确翻译。清理了 [`lib/l10n/app_zh.arb`](lib/l10n/app_zh.arb) 中的重复条目并修复了其 JSON 格式问题。成功执行了 `flutter gen-l10n`.
* [2025-05-25 10:31:24] - 手动修复生成的本地化文件 ([`lib/generated/app_localizations.dart`](lib/generated/app_localizations.dart) 及各语言版本如 [`lib/generated/app_localizations_en.dart`](lib/generated/app_localizations_en.dart))，以包含缺失的 `loadingLabel`, `errorLabel`, `retryButtonLabel`, `signInFailedGeneric` 的抽象声明和具体实现。此前 `flutter gen-l10n` 未能正确生成这些键，尽管 `.arb` 文件看起来配置正确。
* [2025-05-25 11:34:07] - **架构决策:** 采纳了解决 SplashScreen 卡顿和路由循环问题的方案。核心是在 [`SplashScreen`](lib/ui_screens/splash_screen.dart:1) 中，当匿名登录成功后，使用显式导航（例如 `context.go('/home')`）替代 `GoRouter.refresh()`，以避免不必要的路由刷新和组件重建循环。相关决策已记录在 [`memory-bank/decisionLog.md`](memory-bank/decisionLog.md:1)。
* [2025-05-25 13:05:00] - [Debug Status Update: Issue Investigation] 开始调查 "failedToSaveUsername" 错误。日志分析指出 `GoogleApiManager SecurityException: Unknown calling package name 'com.google.android.gms'` 和 `ProviderInstaller module load failure` 可能是根本原因。将优先排查 Google Play 服务集成和配置问题。
* [2025-05-25 14:31:00] - [Debug Status Update: Investigating Firestore permission denied error during new user creation. Current rules in `firestore.rules` seem correct, suspecting client-side auth timing or `userId` mismatch during the create operation.]
---
Timestamp: 5/25/2025, 2:43:58 PM (UTC, UTC+0:00)
Context: Firestore Security Rules Deployment
Status: Deployed with warnings
Details:
  - Firebase CLI command `firebase deploy --only firestore:rules` executed successfully.
  - Firestore rules file [`firestore.rules`](firestore.rules) was reported as already up to date.
  - Warnings were issued for "Invalid function name: containsKey" on multiple lines (15, 19, 22, 29, 47, 49) in [`firestore.rules`](firestore.rules). This might indicate potential issues or deprecated syntax that should be reviewed.
---
* [2025-05-25 14:45:40] - **代码修改 (Firestore 规则):** 修改了 [`firestore.rules`](firestore.rules:1) 文件，将所有 `request.resource.data.containsKey('fieldName')` 的实例替换为 `'fieldName' in request.resource.data`，以修复部署警告并使用推荐的语法。
* [2025-05-26 02:51:30] - [Debug Status Update: Root Cause Identified and Fixed] 双重错误问题的根本原因已确定并修复：
  1. **Firestore PERMISSION_DENIED 错误**：由于客户端使用 `Timestamp.now()` 而安全规则要求 `request.time` 导致时间戳不匹配
  2. **UI "please enter a username" 错误**：权限错误被通用错误处理掩盖，未显示具体的权限拒绝信息
  3. **修复措施**：
     - 修改 [`lib/services/user_service.dart`](lib/services/user_service.dart) 使用 `FieldValue.serverTimestamp()` 确保服务器端时间戳
     - 更新 [`firestore.rules`](firestore.rules) 使时间戳验证更灵活
     - 改进 [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart) 错误处理，显示具体的权限错误
     - 添加详细调试日志帮助后续问题诊断
     - 成功部署更新后的 Firestore 安全规则
* [2025-05-26 04:20:31] - [Debug Status Update: Issue Analysis Complete] 匿名登录自动触发问题分析完成。确认这是**预期的设计行为**，不是bug。应用启动时自动执行匿名登录是为了：1) 获得稳定的Firebase UID用于数据关联；2) 支持引继码系统；3) 解决之前的认证失败问题。认证流程：启动 → SplashScreen自动匿名登录 → 检查用户名 → 路由到相应页面。用户名设置是在匿名认证成功后的独立流程。
* [2025-05-26 03:25:33] - [Debug Status Update: Issue Resolved] 权限被拒绝问题已解决。根本原因是 Firestore 安全规则中的时间戳验证逻辑与 `FieldValue.serverTimestamp()` 不兼容。修复措施：简化了 [`firestore.rules`](firestore.rules:22) 第22行的时间戳验证，移除了严格的时间戳匹配要求，允许服务器处理时间戳。已成功部署更新后的安全规则。
* [2025-05-26 06:26:57] - [Debug Status Update: Issue Resolved] 修复了 [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:76-78) 中的 Flutter 空安全编译错误。问题出现在第76-77行，`idToken` 变量可能为 null 但代码直接访问了其 `length` 属性和 `substring` 方法。通过添加空值检查 (`if (idToken != null)`) 解决了编译错误，确保代码在 idToken 为 null 时不会崩溃，同时保持了调试信息的完整性。
* [2025-05-26 06:34:59] - [Debug Status Update: Firebase 错误修复完成] 成功修复了两个 Firebase 相关错误：
  1. **Firestore 权限错误修复**：更新了 [`firestore.rules`](firestore.rules:43-46) 中排行榜集合的路径配置，从 `/scores/{scoreId}` 修正为 `/leaderboards/{leaderboardId}/scores/{scoreId}`，与 [`lib/services/leaderboard_service.dart`](lib/services/leaderboard_service.dart:23-27) 中实际使用的路径匹配
  2. **排行榜数据获取优化**：
     - 移除了 [`lib/state_management/providers/personal_best_score_provider.dart`](lib/state_management/providers/personal_best_score_provider.dart:15) 中对 `leaderboardProvider` 的不必要监听
     - 将 [`lib/state_management/providers/leaderboard_providers.dart`](lib/state_management/providers/leaderboard_providers.dart:22) 中的 `leaderboardProvider` 从 `autoDispose` 改为普通版本
     - 解决了排行榜数据频繁获取的性能问题
  3. **Cloud Function 调用验证**：确认 [`lib/services/user_service.dart`](lib/services/user_service.dart:240) 中 `deleteUserData` 函数调用正确传递了 `uid` 参数
* [2025-05-26 09:02:00] - [Debug Status Update: Cloud Function 参数传递问题深度分析完成] 完成对 `deleteUserData` Cloud Function 参数传递问题的全面调试分析：
  1. **问题确认**：错误信息 "The function must be called with a 'uid' argument" 与实际代码不符
  2. **根本原因**：Firebase Functions 日志显示 `"app":"MISSING"`，表明 App Check 验证失败导致请求被拦截
  3. **代码验证**：
     - 客户端代码 [`lib/services/user_service.dart`](lib/services/user_service.dart:240) 正确传递 `{'uid': user.uid}` 参数
     - Cloud Function 代码 [`functions/index.js`](functions/index.js:55-63) 正确检查 `uid` 参数
     - Firebase Auth 状态正常，匿名登录成功
  4. **实际问题**：App Check 配置缺失或不正确，导致 Cloud Function 调用被 Firebase 安全层拦截
  5. **解决方案**：需要配置 Firebase App Check 或在开发环境中禁用 App Check 验证
* [2025-05-26 09:31:00] - [Debug Status Update: Cloud Function INTERNAL 错误修复完成] 成功诊断并修复了 `deleteUserData` Cloud Function 的 INTERNAL 错误：
  1. **根本原因确认**：Cloud Function 内部的 `JSON.stringify()` 调用试图序列化包含循环引用的 `context` 对象，导致 "Converting circular structure to JSON" 错误
  2. **错误定位**：Firebase Functions 日志显示错误发生在 `/workspace/index.js:57:31`，正是我们的调试日志代码
  3. **修复措施**：
     - 移除 [`functions/index.js`](functions/index.js:58) 中的 `JSON.stringify()` 调用，直接输出对象
     - 增强错误处理和日志记录，添加分步骤的详细调试信息
     - 改进 Firestore 和 Firebase Auth 删除操作的错误处理
     - 添加对用户不存在情况的优雅处理
  4. **部署状态**：✅ 修复后的 Cloud Function 已成功部署到 Firebase 项目 yacht-f816d
* [2025-05-26 09:48:45] - [Debug Status Update: Issue Resolved] 成功修复了 Cloud Function deleteUserData 中的循环引用错误：
  1. **问题定位**：第57行 `JSON.stringify(data)` 和第58-63行上下文日志记录中的 `context.rawRequest` 包含循环引用（Socket -> HTTPParser -> Socket）
  2. **修复措施**：
     - 为 `JSON.stringify(data)` 添加 try-catch 错误处理，避免循环引用崩溃
     - 重构上下文信息记录，移除可能包含循环引用的 `context.rawRequest` 直接访问
     - 改为记录安全的属性：`hasRawRequest: !!context.rawRequest`
     - 优化 `context.app` 记录，只提取 `appId` 和 `projectId` 等安全属性
     - 修复所有 ESLint 代码风格问题（引号、逗号、空格等）
  3. **部署状态**：✅ 修复后的 Cloud Function 已成功部署到 Firebase 项目 yacht-f816d
  4. **调试信息保持**：确保修复后仍保持完整的调试信息和可读性，同时避免循环引用错误
  5. **测试准备**：创建了 [`test_delete_function.dart`](test_delete_function.dart:1) 测试脚本用于验证修复效果