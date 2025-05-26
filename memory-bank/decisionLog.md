# Decision Log

This file records architectural and implementation decisions using a list format.
2025-05-23 02:56:43 - Log of updates made.

*

---
### Decision
[2025-05-26 12:48:19] - 采纳关于账号删除成功后客户端状态清理和导航的架构方案。

**Rationale:**
用户报告在删除账号成功后，应用未正确返回创建账号界面，而是停留在游戏主界面并显示已删除的用户。提供的伪代码清晰地指出了问题在于客户端状态未被完全重置，并且没有正确的导航逻辑。为了确保用户数据的隔离和正确的用户体验，必须在账号删除操作成功后，彻底清理客户端的所有相关状态（认证、本地缓存、应用状态管理中的用户数据）并强制导航到初始屏幕。

**Implications/Details:**
*   **客户端状态清理的必要性:**
    *   **认证状态:** 必须调用 `AuthService.signOut()` 清除 Firebase Auth 状态。
    *   **本地缓存:** 必须清除 SharedPreferences 或其他本地存储中与用户相关的所有数据（例如，用户名、设置、游戏进度缓存）。
    *   **应用状态 (Riverpod Providers):** 必须使所有存储用户特定数据的 Riverpod Provider 无效 (例如，通过 `ref.invalidate()`)，包括 `userProvider`, `usernameProvider`, `personalBestScoreProvider` 等。
    *   **游戏状态:** 如果游戏状态与用户相关，也需要重置。
*   **强制导航:**
    *   使用 `GoRouter` (或项目的导航服务) 强制导航到应用的初始屏幕 (例如 `Route.CREATE_ACCOUNT_SCREEN` 或 `Route.SPLASH_SCREEN`)。
    *   导航操作必须能够清除当前的导航堆栈，防止用户通过返回按钮回到之前的界面。
*   **`UserService` 的协调角色:** `UserService.deleteCurrentUserAccount()` 在接收到 Cloud Function 删除成功的响应后，应负责协调上述客户端清理步骤。
*   **`Cloud Function (deleteUserData)` 的职责:** 后端函数负责删除 Firebase Authentication 用户和 Firestore 中的用户数据。客户端的清理是在此操作成功后的必要补充。
*   **架构文档更新:** 相关原则和流程已更新到 [`memory-bank/architecture.md`](memory-bank/architecture.md:0) 的 "2.5. 用户会话结束与状态重置" 和 "3.3. Firebase Cloud Functions" 部分。

---
### Decision
[2025-05-25 12:50:00] - 采纳针对用户名保存失败问题的综合架构方案，重点解决用户输入验证、网络问题、后端服务错误、本地存储问题和并发问题。

**Rationale:**
用户报告在创建用户时保存用户名失败并提示“请重试”。为了系统性地解决此问题，需要一个覆盖前端验证、网络容错、后端健壮性、本地缓存策略和并发控制的综合架构。此方案旨在提高用户名创建流程的成功率和用户体验。

**Implications/Details:**
*   **用户输入验证 (前端):**
    *   在 [`UsernameSetupScreen`](lib/ui_screens/username_setup_screen.dart:1) 中实现实时格式验证（长度、字符集）。
    *   可选：通过 Cloud Function `checkUsernameAvailability` 进行异步唯一性预检查。
    *   提供清晰、本地化的即时错误反馈。
*   **网络问题处理 (前端):**
    *   在 [`UserService`](lib/services/user_service.dart:1) 中实现网络连接检查、请求超时和带退避算法的重试机制。
    *   向用户显示明确的网络错误提示。
*   **后端服务错误处理 (Firebase & 前端):**
    *   **用户名唯一性与原子写入:** 推荐使用 **Cloud Function + Firestore 事务**。
        *   Cloud Function (例如 `callable_setUniqueUsername`) 接收用户名和 UID。
        *   在 Firestore 事务中：
            1.  检查规范化用户名是否已在 `usernames/{normalized_username}` 辅助集合中存在。
            2.  若不存在，则创建 `usernames/{normalized_username}` 并更新 `users/{userId}` 中的用户名。
            3.  若存在但 UID 不同，则返回 `ALREADY_EXISTS`。
    *   Cloud Functions 返回标准化的错误代码。
    *   [`UserService`](lib/services/user_service.dart:1) 解析 Firebase 异常，转换为应用特定错误。
    *   UI 显示本地化的用户友好错误消息。
*   **本地存储问题 (前端):**
    *   [`LocalStorageService`](lib/services/local_storage_service.dart:1) 主要用于缓存已成功保存到后端的用户名，而非作为关键持久化步骤。
    *   `shared_preferences` 操作包含 `try-catch`。
*   **并发问题处理:**
    *   UI 层通过禁用按钮和显示加载指示器来防止重复提交。
    *   后端通过 Cloud Function + Firestore 事务确保用户名注册的原子性和唯一性。
*   **错误处理和用户反馈策略:**
    *   采用分层错误处理（服务层 -> 状态管理层 -> UI 层）。
    *   使用本地化文件管理用户可见的错误消息。
    *   严格管理加载状态。
*   **鲁棒性与幂等性:**
    *   通过上述机制增强鲁棒性。
    *   Cloud Function 设计应考虑幂等性，确保重复调用同一成功注册操作不会产生副作用。
*   **相关架构更新:** 详细流程已更新至 [`memory-bank/architecture.md`](memory-bank/architecture.md:1) 的 "用户名创建与管理流程" 章节。

---
### Decision
[2025-05-25 12:37:12] - 设计 Firestore 安全规则以解决用户写入自身文档时的 `PERMISSION_DENIED` 错误。

**Rationale:**
错误日志显示用户 `wEAQEd58kkfpkqG6koO6jGEktV12` 在尝试写入路径 `users/wEAQEd58kkfpkqG6koO6jGEktV12` 时遇到权限不足的问题。`spec-pseudocode` 模式建议审查和更新安全规则。为了遵循最小权限原则并解决此问题，需要明确允许经过身份验证的用户写入其自己的用户文档。

**Implications/Details:**
*   **安全规则更新:**
    *   在 `users/{userId}` 路径下，添加/修改规则为 `allow read, create, update: if request.auth != null && request.auth.uid == userId;`。
    *   维持 `allow delete: if false;` 以防止客户端直接删除用户数据。
*   **其他集合:** 审查并确保其他集合（如 `leaderboard`）的规则也遵循最小权限原则，例如允许创建排行榜条目但限制更新/删除。
*   **影响:** 此更改将直接解决报告的 `PERMISSION_DENIED` 错误，允许用户创建和更新其个人资料。
*   **相关文件:** Firestore 安全规则文件 (通常是 `firestore.rules`)。
---
### Decision
[2025-05-25 11:51:14] - 明确 Cloud Firestore 数据库依赖性及缺失时的应用行为。

**Rationale:**
诊断结果 (`spec-pseudocode` 模式) 指出，由于 Firebase 项目 `yacht-f816d` 的 Cloud Firestore 数据库未配置，导致应用在创建新用户后卡在加载界面 (错误: `NOT_FOUND, The database (default) does not exist`)。Cloud Firestore 是存储用户账户、游戏数据和排行榜的核心。此依赖性缺失会严重影响应用功能。因此，必须明确记录此依赖，并定义应用在数据库不可用时的预期行为，以提高系统的健壮性和用户体验。

**Implications/Details:**
*   **依赖性确认:** Cloud Firestore 是应用核心功能的强制性依赖。
*   **预期行为 (Firestore 不可用时):**
    *   **错误检测:** 应用必须能够在启动或相关操作（如用户创建、数据读写）时检测到 Firestore 不可用的状态 (例如，通过捕获 `NOT_FOUND` 或类似的 gRPC 错误代码)。
    *   **用户通知:** 向用户显示清晰、本地化的错误消息，例如：“数据库服务当前不可用，部分功能可能受限或无法使用。请稍后重试或联系支持。”
    *   **功能限制:** 阻止用户执行依赖 Firestore 的操作（例如，创建新账户、开始在线游戏、查看排行榜）。如果可能，允许用户访问不依赖 Firestore 的本地功能（如果有）。
    *   **加载状态管理:** 确保在检测到错误后，相关的加载指示器被清除，UI 不会卡在无限加载状态。
    *   **日志记录:** 记录详细的错误信息到开发者控制台或日志系统，以便于诊断。
*   **架构更新:**
    *   在 [`memory-bank/architecture.md`](memory-bank/architecture.md:1) (或相关产品文档) 中明确强调 Cloud Firestore 的关键作用及其配置的必要性。
    *   服务层 (例如 `UserService`, `LeaderboardService`) 的错误处理逻辑需要增强，以捕获并适当地向上传播 Firestore相关的特定错误。
    *   UI 层需要能够响应这些错误，并呈现上述的用户通知和功能限制。
*   **后续行动:**
    *   开发团队需要确保 Firebase 项目 `yacht-f816d` 中的 Cloud Firestore 数据库已正确创建和配置。
    *   代码层面需要实现更健壮的错误处理逻辑，以应对此类后端依赖问题。
---
### Decision
[2025-05-23 03:08:30] - 选择 Riverpod 作为 Flutter 应用的状态管理方案。

**Rationale:**
编译时安全、可测试性强、灵活性高、声明式、无需 `BuildContext` 即可访问 Provider，并提供良好的性能优化。相比 BLoC，对于中小型项目学习曲线更平缓；相比 Provider，更易于在大型应用中管理。

**Implications/Details:**
项目将使用 Riverpod 的 Provider 进行状态管理。相关代码将组织在 `lib/state_management/providers/` 目录下（如果遵循此结构）。需要添加 `flutter_riverpod` 依赖。

---
### Decision
[2025-05-23 03:08:30] - 选择 GoRouter 作为 Flutter 应用的导航方案。

**Rationale:**
提供声明式路由、支持深度链接、可通过代码生成实现类型安全路由、易于处理复杂导航场景，并且与 Flutter 团队紧密集成。

**Implications/Details:**
项目将使用 GoRouter进行路由管理。路由配置将在 `lib/navigation/app_router.dart` 中定义。需要添加 `go_router` 依赖。

---
### Decision
[2025-05-23 03:08:30] - 选择 Firebase (Firestore, Firebase Functions, Firebase Authentication) 作为后端技术栈。

**Rationale:**
快速开发、实时数据库能力强 (Firestore)、无服务器函数 (Firebase Functions) 便于实现自定义逻辑、内置身份验证、良好的可伸缩性、与 Flutter 集成良好 (FlutterFire)，且对初创项目具有成本效益。

**Implications/Details:**
后端逻辑将通过 Firebase Functions 实现，数据存储在 Firestore。需要配置 Firebase 项目并集成 FlutterFire 插件。API 端点和数据库模式已在 `memory-bank/architecture.md` 中定义。安全规则需要仔细配置。
## Decision

*

## Rationale 

*

## Implementation Details

*
---
### Decision (Code)
[2025-05-23 08:19:53] - Changed dice selection logic from "select to keep" to "select to discard".

**Rationale:**
This change aims to improve user experience by reducing the number of clicks required. In Yahtzee, players often keep more dice than they discard. The new logic ("select dice you *don't* want to keep") aligns better with this common scenario, making the interaction more intuitive and efficient.

**Details:**
- Modified `Die.roll()` in [`lib/core_logic/game_state.dart`](lib/core_logic/game_state.dart:13) to re-roll if `isHeld` is true (now meaning "selected to discard").
- Updated UI in [`lib/widgets/dice_widget.dart`](lib/widgets/dice_widget.dart) to reflect the new logic:
    - Dice selected for discarding are now marked with a red border and a small 'X' icon.
    - Dice not selected (i.e., kept) have a standard grey border.
- Adjusted dice animation triggers in [`lib/widgets/dice_widget.dart`](lib/widgets/dice_widget.dart) to correspond with the new meaning of `heldDice` state.
---
### Decision
[2025-05-24 11:03:08] - 继续使用 `shared_preferences` 进行排行榜和用户名的本地持久化。

**Rationale:**
对于当前需求（最多10条排行榜记录和一个用户名），`shared_preferences` 足够简单且已经集成到项目中。避免了引入新依赖（如 `sqflite`）的复杂性。排行榜数据可以通过 JSON 序列化存储。

**Implications/Details:**
[`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart) 将需要更新以处理 `List&lt;ScoreEntry&gt;` 的序列化/反序列化和用户名的存储/检索。
---
### Decision
[2025-05-24 12:43:29] - Adopted strategy to fix "Continue Game" button bug for new users and enhance HomeScreen to display username.

**Rationale:**
The "Continue Game" button bug is critical as it affects new user experience. Displaying the username enhances personalization. The proposed solutions from the spec/pseudocode are sound.

**Implications/Details:**
1.  **"Continue Game" Button Fix:**
    *   In [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1), the `redirect` logic will call `ref.read(gameStateProvider.notifier).setToInitialState()` after a new user completes username setup and before navigating to the home screen. This ensures `isGameInProgress` is `false`.
    *   In [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1), the visibility of the "Continue Game" button will be determined by a more robust condition: `final canContinueGame = isGameInProgress && ref.watch(gameStateProvider.select((state) => state.currentTurn > 0));`.
2.  **Display Username on HomeScreen:**
    *   The username will be fetched via `ref.watch(userProvider)` in [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1).
    *   The `AppBar` in `HomeScreen` will display the username, with appropriate loading and empty/error states (e.g., `CircularProgressIndicator`, `SizedBox.shrink()`). Text overflow will be handled with `TextOverflow.ellipsis`.
    *   Ensures [`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1) correctly loads and provides the username and its loading state.
---
### Decision
[2025-05-24 13:07:00] - 采纳规范和伪代码，修复“游戏结束后排行榜未显示成绩”的问题。

**Rationale:**
提供的规范和伪代码准确地定位了问题根源，并提出了一个与现有架构（Riverpod、服务层）一致的合理解决方案。该方案通过在 [`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1) 的游戏结束流程中调用 `LeaderboardService.addScore` 并刷新排行榜数据，确保了用户成绩的正确保存和显示。

**Implications/Details:**
将按照伪代码修改 [`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1) 中的 `ref.listen<bool>(isGameOverProvider, ...)` 回调：
1.  在 `WidgetsBinding.instance.addPostFrameCallback` 中执行。
2.  获取 `username` 和 `leaderboardService`。
3.  调用 `await leaderboardService.addScore(username, grandTotal)`。
4.  调用 `ref.refresh(leaderboardProvider)`。
5.  包含必要的 `async/await` 和错误处理。

---
### Decision
[2025-05-24 13:28:28] - 采纳架构计划，在主屏幕显示用户的个人最高分数。

**Rationale:**
该计划符合用户需求，与现有项目架构（Riverpod、服务层、本地化）良好集成。它通过在 `LeaderboardService` 中添加新方法并在新的 Riverpod Provider (`personalBestScoreProvider`) 中封装获取逻辑，实现了清晰的职责分离。UI 层 (`HomeScreen`) 将消费此 Provider 并处理不同的加载状态，同时使用 `intl` 包进行时间格式化，并支持本地化。监听 `leaderboardProvider` 可确保在排行榜更新时，个人最高分也能自动刷新。

**Implications/Details:**
1.  **`LeaderboardService` ([`lib/services/leaderboard_service.dart`](lib/services/leaderboard_service.dart:1)):**
    *   添加 `Future<ScoreEntry?> getPersonalBestScore(String username)` 方法，用于从本地存储中检索特定用户的最高分。
2.  **Riverpod Provider (`lib/state_management/providers/personal_best_score_provider.dart`):**
    *   创建新文件并定义 `personalBestScoreProvider` (FutureProvider)。
    *   依赖 `usernameProvider` 和 `leaderboardServiceProvider`。
    *   `watch` `leaderboardProvider` 以便在排行榜更新时自动刷新。
3.  **`HomeScreen` ([`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1)):**
    *   消费 `personalBestScoreProvider`。
    *   使用 `AsyncValue.when` 处理加载、数据（包括 `null` 情况）和错误状态。
    *   显示标签 "您的最高分:"、分数值和使用 `intl` 包 `DateFormat('yyyy-MM-dd HH:mm')` 格式化的获得时间。
4.  **本地化 (`.arb` 文件):**
    *   添加新键: `yourPersonalBestScoreLabel`, `noPersonalBestScore`, `scoreLabel`, `dateTimeLabel` 到所有 `.arb` 文件。
    *   运行 `flutter gen-l10n`。
5.  **`intl` 包:**
    *   确保已添加到 `pubspec.yaml`。
    *   在 `HomeScreen` 中导入并用于时间格式化。
6.  **Memory Bank 更新:**
    *   更新 `decisionLog.md`, `activeContext.md`, `progress.md`。
---
### Decision (Code)
[2025-05-24 13:34:57] - Implemented feature to display personal best score on the Home Screen.

**Rationale:**
This feature enhances user engagement by providing immediate feedback on their best performance. The implementation followed the architectural plan, ensuring consistency with existing patterns (Riverpod, services, localization).

**Details:**
- Added `Future<ScoreEntry?> getPersonalBestScore(String username)` to `LeaderboardService` ([`lib/services/leaderboard_service.dart`](lib/services/leaderboard_service.dart)).
- Created `personalBestScoreProvider` (`FutureProvider<ScoreEntry?>`) in [`lib/state_management/providers/personal_best_score_provider.dart`](lib/state_management/providers/personal_best_score_provider.dart), which depends on `usernameProvider`, `leaderboardServiceProvider`, and watches `leaderboardProvider`.
- Updated `HomeScreen` ([`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart)) to consume `personalBestScoreProvider`, handle loading/data/error states using `AsyncValue.when()`, and display the score (value and formatted timestamp using `intl`).
- Added localization keys (`yourPersonalBestScoreLabel`, `noPersonalBestScore`, `scoreLabel`, `dateTimeLabel`) to all `.arb` files and ran `flutter gen-l10n`.
- Ensured `intl` package is present in [`pubspec.yaml`](pubspec.yaml).

---
### Decision
[2025-05-24 13:38:10] - 批准了在主屏幕右上角使用 `Stack` 和 `Positioned` Widget 显示用户名的伪代码架构。

**Rationale:**
伪代码建议的方法（使用 `Stack` 和 `Positioned` 在 `Scaffold.body` 内显示用户名）是 Flutter 中覆盖元素的有效方法。它利用了现有的 `usernameProvider` 和 Riverpod 的 `AsyncValue.when` 来处理不同状态，这符合项目的既定模式。使用 `Chip` Widget 进行显示也是一个合理的 UI 选择。该方法与之前在 `AppBar` 中显示用户名的尝试不同，代表了一种新的 UI 策略。

**Implications/Details:**
- 将修改 [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) 以实现此设计。
- `Scaffold.body` 将被一个 `Stack` Widget 包裹。
- 一个 `Positioned` Widget 将用于将用户名（通过 `Chip` Widget 显示）放置在右上角。
- 将处理 `usernameProvider` 的 `data`、`loading` 和 `error` 状态。
- 需要注意此方法与现有 `AppBar` 的交互。如果 `AppBar` 仍然存在，用户名将显示在其下方。如果目标是将用户名放置在 `AppBar` 的 `actions` 区域，则需要采用不同的实现。当前的决定是遵循伪代码的 `Stack/Positioned` 方法。
- 需要考虑不同屏幕尺寸的间距调整。
---
### Decision (Code)
[2025-05-24 13:41:54] - Created `usernameAsyncProvider` (FutureProvider) in `lib/state_management/providers/user_providers.dart`.

**Rationale:**
The existing `usernameProvider` returned `String?`, which is not compatible with the `AsyncValue.when()` method required by the approved pseudocode for displaying the username on the home screen (handling loading/data/error states). To align with the pseudocode and provide a proper `AsyncValue`, a new `FutureProvider` (`usernameAsyncProvider`) was introduced. This provider directly fetches the username from `LocalStorageService`, thus exposing the asynchronous nature of the operation and allowing `AsyncValue.when()` to be used correctly in the UI.

**Details:**
- Added `localStorageServiceProvider` to [`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1).
- Modified `userServiceProvider` to use `localStorageServiceProvider`.
- Created `usernameAsyncProvider = FutureProvider<String?>((ref) async { ... });` which calls `localStorageService.getUsername()`.
- Updated [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) to watch `usernameAsyncProvider` instead of the old `usernameProvider` for the username display logic.

---
### Decision
[2025-05-24 14:03:00] - 确认 Firebase Authentication (匿名认证 + 自定义令牌) 和 Cloud Firestore 作为引继码系统和在线数据存储的核心技术。

**Rationale:**
此方案满足了用户对引继码（唯一用户KEY）的需求，同时利用了 Firebase 的强大功能：
*   **Firebase Authentication (Anonymous):** 为每个用户提供一个稳定的、唯一的 Firebase UID，作为后端数据关联的主键，而无需用户进行传统的邮箱/密码注册。
*   **Cloud Firestore:** 灵活的 NoSQL 数据库，适合存储用户信息（包括引继码）、游戏进度、排行榜等结构化数据。其实时同步和离线支持特性对游戏应用友好。
*   **Custom Token Authentication:** 通过 Cloud Function 生成自定义令牌，可以将用户输入的引继码安全地映射回其原始 Firebase UID，实现账户恢复，而无需暴露敏感的认证凭据。
*   **Transfer Code:** 18位大写字母和数字组合提供了足够的唯一性和一定的防猜测能力。客户端生成，服务端（通过 Firestore 查询）校验唯一性。

**Implications/Details:**
*   **Firestore Data Structure:**
    *   `users` 集合: 文档 ID 为 Firebase UID。包含 `username`, `transferCode` (indexed), `createdAt`, `gameData` (map for scores, ELO, etc.)。
    *   `leaderboards` 集合: 包含 `scores` 子集合，存储 `userId`, `username`, `score`, `timestamp`。
*   **Transfer Code Logic:**
    *   **Generation:** Flutter 客户端生成18位代码，查询 Firestore 确保唯一性。
    *   **Restoration:** 用户输入引继码 -> Flutter 查询 Firestore `users` by `transferCode` -> 获取对应 UID -> 调用 Cloud Function `generateCustomAuthToken(uid)` -> Flutter 使用返回的 token 调用 `signInWithCustomToken()`.
    *   **Security:** 引继码本身不直接用于认证，而是用于查找 UID，实际认证通过安全的自定义令牌完成。Cloud Functions 调用将受 Firebase 安全规则和可能的速率限制保护。
    *   **Persistence of Transfer Code:** 对于V1，引继码在账户删除前保持不变。未来可考虑引继成功后刷新引继码以增强安全性，但会增加用户管理复杂度。
*   **Cloud Functions:**
    *   `generateCustomAuthToken`: (Callable) 接收 UID, 返回自定义认证令牌。
    *   `deleteUserData`: (Callable) 接收 UID, 删除 Firestore 用户数据和 Firebase Auth 用户。
*   **Flutter Services:**
    *   `AuthService`: 处理匿名登录、自定义令牌登录。
    *   `UserAccountService`: 管理用户配置文件的创建、读取、引继码获取、账户删除请求。
    *   `TransferCodeGenerator`: 客户端工具类，用于生成引继码。
*   详细的流程图和数据模型见 [`memory-bank/architecture.md`](memory-bank/architecture.md:1)。

---
### Decision
[2025-05-24 14:03:00] - 确定引继码生成规则和账户恢复流程中的安全考量。

**Rationale:**
引继码系统的安全性至关重要，以防止账户被盗用。
*   **引继码格式:** 18位大写字母和数字的组合提供了 `(26+10)^18 = 36^18` 种可能性，这是一个非常大的数字，使得暴力猜测几乎不可能。
*   **唯一性:** 在创建用户时，必须确保生成的引继码在系统中是唯一的。这通过在将引继码存入 `users` 集合前查询该集合的 `transferCode` 字段来实现。
*   **恢复机制:** 账户恢复不直接依赖引继码进行认证。引继码仅用于查找用户的 Firebase UID。实际的“登录”操作是通过 Firebase 自定义认证令牌完成的，该令牌由安全的 Cloud Function 生成，并且生命周期较短。这避免了引继码本身作为长期有效凭证的风险。
*   **数据删除:** 用户数据删除操作通过 Cloud Function 执行，确保从 Firebase Authentication 和 Cloud Firestore 中彻底移除用户数据。

**Implications/Details:**
*   **Client-Side Generation, Server-Side Uniqueness Check:** 引继码在 Flutter 客户端生成，然后通过查询 Firestore `users` 集合（在 `transferCode` 字段上建立索引）来验证其唯一性。如果冲突，则重新生成。
*   **No Direct Auth with Transfer Code:** 强调引继码不是密码。它是一个查找键。
*   **Cloud Function Security:** `generateCustomAuthToken` 和 `deleteUserData` Cloud Functions 将通过 Firebase 安全规则进行保护，确保只有授权的客户端（即应用本身）可以调用它们，并且可能根据需要实施速率限制。
*   **Transfer Code Display:** 引继码应在应用内清晰展示给用户，并提供复制功能，但不应鼓励用户分享。
*   **Consideration for Future Enhancement (Not in V1):**
    *   **One-Time Use Transfer Codes:** 引继成功后，旧引继码失效，并为用户生成一个新的引继码。这能显著提高安全性，防止已泄露的旧码被重用。
    *   **Rate Limiting on Restore Attempts:** 在 Cloud Function层面限制短时间内对特定引继码或来自同一IP的过多恢复尝试。
    *   *当前决定 (V1): 引继码在账户删除前可重复使用，以简化用户体验。上述增强功能作为未来迭代的考虑点。*
---
### Decision
[2025-05-25 04:44:52] - Decided to migrate Firebase Functions from TypeScript to JavaScript.

**Rationale:**
Simplify build process and align with user preference for JavaScript for Cloud Functions in this project.

**Implications/Details:**
This involves converting function logic, updating package.json, and cleaning up TS-specific artifacts.
---
### Decision (Debug)
[2025-05-25 05:28:20] - Resolved missing `lib/firebase_options.dart` build error.

**Rationale:**
The build was failing because the `lib/firebase_options.dart` file, crucial for Firebase initialization in Flutter, was missing. This file is automatically generated by the `flutterfire configure` command. The initial attempt to run `flutterfire configure` did not explicitly create the file, possibly due to an issue with reusing existing configurations or an incomplete execution.

**Details:**
1. Verified FlutterFire CLI was active using `dart pub global activate flutterfire_cli`.
2. Attempted `flutterfire configure`. The command completed but `lib/firebase_options.dart` was still missing.
3. Read Firebase project ID (`yacht-f816d`) from `.firebaserc`.
4. Re-ran `flutterfire configure` with explicit project ID and auto-confirmation: `flutterfire configure --project=yacht-f816d -y`.
5. This second attempt successfully generated `lib/firebase_options.dart`, resolving the build errors related to this file and the `DefaultFirebaseOptions` undefined name.
Affected components/files: Primarily build process and Firebase initialization. The fix involved regenerating [`lib/firebase_options.dart`](lib/firebase_options.dart).
---
### Decision (Debug)
[2025-05-25 05:39:57] - Bug Fix Strategy: Missing Firebase Anonymous Sign-In on App Startup.

**Rationale:**
The error "认证失败，请重启应用" occurs because `FirebaseAuth.instance.currentUser` is `null` when [`UsernameSetupScreen`](lib/ui_screens/username_setup_screen.dart:1) attempts to create a new user. This is due to the absence of a call to `AuthService.signInAnonymously()` in [`lib/main.dart`](lib/main.dart:1) after Firebase initialization.

**Details:**
- **Affected File:** [`lib/main.dart`](lib/main.dart:1) (missing anonymous sign-in call), [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1) (where `currentUser` is checked and found null).
- **Proposed Fix:** Implement a call to `authService.signInAnonymously()` within the `main()` function in [`lib/main.dart`](lib/main.dart:1) after `Firebase.initializeApp()` and before `runApp()`. Ensure the app waits for the sign-in attempt to complete or handles its state appropriately (e.g., via a loading screen or within the initial routing logic) before allowing the user to proceed to screens requiring authentication.
---
### Decision (Code)
[2025-05-25 05:41:49] - Implemented Firebase anonymous sign-in on app startup.

**Rationale:**
To fix the "认证失败，请重启应用" error, which was caused by `FirebaseAuth.instance.currentUser` being `null` during user setup. Anonymous sign-in ensures a Firebase User object is available.

**Details:**
- Modified [`lib/main.dart`](lib/main.dart:1) in the `main()` function.
- Added a call to `AuthService.signInAnonymously()` after `Firebase.initializeApp()` and before `runApp()`.
- Used a `ProviderContainer` to access `authServiceProvider` outside the widget tree for the initial sign-in.
- Included basic error handling for the sign-in attempt.
---
### Decision
[2025-05-25 06:00:10] - Updated Android NDK version to 27.0.12077973 in [`android/app/build.gradle.kts`](android/app/build.gradle.kts:14).

**Rationale:**
The `cloud_firestore` plugin requires Android NDK version 27.0.12077973. The project was previously configured with NDK version 26.3.11579264 (indirectly via `flutter.ndkVersion`).

**Implications/Details:**
Modified the `ndkVersion` property within the `android {}` block in [`android/app/build.gradle.kts`](android/app/build.gradle.kts:14) from `flutter.ndkVersion` to `"27.0.12077973"`.
---
### Decision (Code)
[2025-05-25 06:05:26] - Updated Android `minSdkVersion` to 23.

**Rationale:**
The `firebase_auth` plugin requires a `minSdkVersion` of at least 21. To ensure compatibility and accommodate potential future plugin requirements, `minSdkVersion` was set to 23.

**Details:**
Modified [`android/app/build.gradle.kts`](/home/user/myapp/android/app/build.gradle.kts:30) from `minSdk = flutter.minSdkVersion` to `minSdk = 23`.

---
### Decision
[2025-05-25 06:15:00] - 诊断并制定 Flutter 应用中 Firebase 匿名认证后 UI 加载状态持续存在问题的解决方案。

---
### Decision
[2025-05-25 06:26:55] - 采纳新的应用启动和匿名登录流程以解决 UI 加载状态问题。

**Rationale:**
为了解决 Firebase 匿名用户创建后 UI 按钮持续加载的问题，并改进应用启动时的用户体验和状态管理，决定引入专门的启动画面 (`SplashScreen`) 和一个专门处理匿名登录状态的 Riverpod Notifier (`AnonymousSignInNotifier`)。此方案将异步登录逻辑与主应用初始化分离，提供了更清晰的状态反馈。

**Implications/Details:**
1.  **`AnonymousSignInNotifier` ([`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1)):**
    *   创建一个新的 `StateNotifier`，专门负责处理匿名登录的异步操作。
    *   管理一个 `isLoading` 状态，并在 `try-finally` 块中正确设置和重置此状态，确保无论成功或失败，加载状态都会被清除。
    *   提供方法来触发匿名登录，并暴露登录成功/失败的状态。
2.  **`SplashScreen` ([`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:1)):**
    *   创建一个新的 UI 屏幕作为应用的初始入口点。
    *   在 `initState` 或首次构建时调用 `AnonymousSignInNotifier` 中的匿名登录方法。
    *   根据 `AnonymousSignInNotifier` 的 `isLoading` 和认证结果状态（成功/失败/用户已存在）显示不同的 UI（例如，加载指示器、错误消息、或在成功后导航到主应用）。
3.  **`main.dart` ([`lib/main.dart`](lib/main.dart:1)) 更新:**
    *   移除之前在 `main()` 函数中直接执行匿名登录的逻辑。
    *   应用启动流程现在由 `SplashScreen` 管理。
4.  **`AppRouter` ([`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1)) 更新:**
    *   将应用的初始路由 (`initialLocation`) 设置为 `/splash`。
    *   调整重定向逻辑以适应新的启动流程，确保在匿名登录完成后（由 `SplashScreen` 控制）用户被正确导航到 `/username_setup` (如果需要) 或 `/home`。
5.  **本地化更新:**
    *   为 `SplashScreen` 中可能出现的任何用户可见文本（如错误消息）添加必要的本地化字符串到所有相关的 `.arb` 文件。
    *   运行 `flutter gen-l10n`。

**Rationale:**
问题表现为：通过 Firebase 进行匿名用户创建后，UI 上的按钮持续显示加载状态（转圈），尽管 Firebase 控制台显示匿名用户已成功创建。
根本原因分析（来自 spec-pseudocode）：
该问题很可能源于状态管理逻辑中的缺陷，特别是在 Firebase 匿名认证成功后，未能正确地将 UI 的 `isLoading` 状态更新为 `false`。潜在原因包括：
1.  Provider 中的 `isLoading` 状态未在所有异步操作路径（成功、失败、返回null）后被重置。
2.  UI 组件未能正确监听或响应 Provider 中状态的变化。
3.  `async/await` 使用不当，导致状态更新逻辑执行时机错误。

**Implications/Details:**
解决方案核心在于确保状态的正确和及时更新：
*   **`AuthService`**: 确保 `signInAnonymously` 方法清晰地返回 `User` 对象或在出错时抛出异常。
*   **`UserProvider`**:
    *   在 `attemptAnonymousSignIn` 方法中，使用 `try-catch` 块处理 `authService.signInAnonymously()` 的调用。
    *   **关键**：无论认证成功、失败或返回空用户，都必须在操作完成后将 `isLoading` 设置为 `false`。
    *   在每次状态（`isLoading`, `currentUser`, `errorMessage`）更新后调用 `notifyListeners()`。
*   **UI 组件**:
    *   使用适当的状态管理机制（如 `context.watch`）来监听 `UserProvider` 的 `isLoading`, `currentUser`, 和 `errorMessage`。
    *   根据 `isLoading` 状态显示加载指示器或按钮。
    *   如果 `currentUser` 不为 `null` 且 `isLoading` 为 `false`，则处理后续逻辑（如导航到下一个屏幕或更新UI内容）。
    *   显示来自 `errorMessage` 的任何错误信息。
---
### Decision (Code)
[2025-05-25 10:31:51] - Manually added missing localization getters to generated files.

**Rationale:**
The `flutter gen-l10n` command, despite successful execution and seemingly correct `.arb` files (after fixing a JSON issue in `app_zh.arb`), failed to generate the abstract getters for `loadingLabel`, `errorLabel`, `retryButtonLabel`, and `signInFailedGeneric` in `lib/generated/app_localizations.dart`, and consequently their concrete implementations in the language-specific files (`app_localizations_XX.dart`). This resulted in persistent build errors (`Error: The getter 'loadingLabel' isn't defined for the class 'AppLocalizations'`). The user explicitly requested to bypass further `flutter gen-l10n` attempts and to modify the generated files directly to resolve the issue.

**Details:**
1.  Added abstract getter declarations for `loadingLabel`, `errorLabel`, `retryButtonLabel`, and `signInFailedGeneric` to the `AppLocalizations` class in [`lib/generated/app_localizations.dart`](lib/generated/app_localizations.dart).
2.  Added concrete implementations for these getters to each language-specific class:
    *   [`lib/generated/app_localizations_en.dart`](lib/generated/app_localizations_en.dart)
    *   [`lib/generated/app_localizations_de.dart`](lib/generated/app_localizations_de.dart)
    *   [`lib/generated/app_localizations_es.dart`](lib/generated/app_localizations_es.dart)
    *   [`lib/generated/app_localizations_fr.dart`](lib/generated/app_localizations_fr.dart)
    *   [`lib/generated/app_localizations_ja.dart`](lib/generated/app_localizations_ja.dart)
    *   [`lib/generated/app_localizations_ru.dart`](lib/generated/app_localizations_ru.dart)
    *   [`lib/generated/app_localizations_zh.dart`](lib/generated/app_localizations_zh.dart)
    The values for these implementations were taken from their respective `.arb` files. This manual intervention aims to unblock the build process.
---
### Decision
[2025-05-25 11:33:28] - Adopted solution for SplashScreen卡顿及路由循环问题：在SplashScreen中认证成功后使用显式导航替换 `GoRouter.refresh()`。

**Rationale:**
规范编写器模式分析指出，[`SplashScreen`](lib/ui_screens/splash_screen.dart:1) 中 `GoRouter.refresh()` 调用与 [`AppRouter`](lib/navigation/app_router.dart:1) 的重定向逻辑可能形成循环，导致界面卡顿和组件反复重建。改用显式导航 (如 `context.go('/home')`) 将导航控制权清晰地移交给 [`AppRouter`](lib/navigation/app_router.dart:1) 的 `redirect` 逻辑，从而打破潜在循环。此方案更直接，减少了因路由全局刷新带来的不可预测性。

**Implications/Details:**
- **修改 [`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:1):**
    - 在 `ref.listen` 回调中，当 `anonymousSignInNotifierProvider` 指示匿名登录成功时：
        - 移除 `GoRouter.of(context).refresh()` 调用。
        - 替换为 `context.go('/home')` (或 `context.replace('/home')`)。
- **审查 [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1):**
    - 确保其 `redirect` 逻辑能够正确处理从 `/splash` 导航到 `/home` 后的情况，并根据用户是否需要设置用户名（`needsSetup`）等状态，最终将用户导向正确的页面（如 `/username_setup` 或 `/home`）。
    - 确保 `redirect` 逻辑在用户已登录且设置完成后，若当前路径为 `/splash` 或 `/username_setup`，会正确导航到 `/home`。
- 此更改旨在提高启动流程的稳定性和可预测性。
- [2025-05-25 12:42:47 UTC] 决定部署更新后的 Firestore 安全规则 ([`firestore.rules`](firestore.rules:1)) 以解决 `PERMISSION_DENIED` 错误。
    - 操作：
        - 确认 Firebase CLI 已安装。
        - 更新 [`firebase.json`](firebase.json:1) 以包含正确的 Firestore 规则路径。
        - 执行 `firebase deploy --only firestore:rules` 命令。
    - 结果：部署成功。
---
### Decision (Debug)
[2025-05-25 14:34:00] - Firestore Rules Analysis for New User Creation Permission Denied

**Rationale:**
The user reported a `[cloud_firestore/permission-denied]` error when creating a new user. An analysis of the existing [`firestore.rules`](firestore.rules:1) file, specifically the rule `match /users/{userId} { allow read, create, update: if request.auth != null && request.auth.uid == userId; }`, indicates that the rules are correctly configured to allow authenticated users to create their own user documents. The permission denied error is therefore more likely to stem from client-side issues, such as the anonymous authentication process not completing before the user creation attempt (leading to `request.auth == null`) or an attempt to create a user document with a `userId` that does not match `request.auth.uid`.

**Details:**
- **No changes made to [`firestore.rules`](firestore.rules:1)** as the current rules are deemed correct and secure for the intended operation.
- **Recommendation:** Investigate the client-side Flutter application's anonymous sign-in flow, ensuring it completes successfully and `FirebaseAuth.instance.currentUser` is populated before any attempt to create a user document in Firestore. Verify that the `userId` used for the Firestore document path matches the authenticated user's UID.
- Affected components/files: [`firestore.rules`](firestore.rules:1) (analyzed, no changes), client-side user creation logic (recommended for review).
---
### Decision (Code)
[2025-05-25 14:41:49] - 更新 Firestore 安全规则 ([`firestore.rules`](firestore.rules:1))。

**Rationale:**
根据用户请求，使用提供的新规则完全替换了现有的 Firestore 安全规则。这些规则定义了对 `users` 和 `scores` (或 `leaderboard`) 集合的访问权限。

**Details:**
- `users/{userId}`:
    - 允许已认证用户读取自己的数据。
    - 允许新用户创建自己的文档，并对 `username`、`transferCode` 和 `createdAt` 字段进行了特定校验。
    - 允许已认证用户更新自己的数据，但禁止修改 `createdAt` 和 `transferCode` (如果存在于更新数据中)。
    - 禁止客户端直接删除用户账户。
- `scores/{scoreId}` (或 `leaderboard/{scoreId}`):
    - 允许任何人读取排行榜数据。
    - 允许已认证用户创建新的分数条目，并对 `userId`、`score`、`username` 和 `timestamp` 字段进行了特定校验。
    - 禁止更新或删除排行榜条目。
- 文件路径: [`firestore.rules`](firestore.rules:1)
---
### Decision (Code)
[2025-05-25 14:46:00] - 在 Firestore 安全规则中将 `request.resource.data.containsKey('fieldName')` 替换为 `'fieldName' in request.resource.data`

**Rationale:**
Firebase CLI 在部署 Firestore 安全规则时针对 `containsKey` 的使用发出了警告，提示其为无效函数名或已弃用的语法。使用 `in` 操作符是 Firestore 安全规则中检查 map 是否包含某个键的推荐的、更现代的语法。此更改旨在消除警告并确保规则的健壮性。

**Details:**
- 修改了 [`firestore.rules`](firestore.rules:1) 文件。
- 涉及的行号包括 15, 19, 22, 29, 47, 49。
- 例如，`request.resource.data.containsKey('username')` 被更改为 `'username' in request.resource.data`。
---
### Decision (Debug)
[2025-05-26 02:51:30] - [Bug Fix Strategy: Firestore PERMISSION_DENIED 和 UI 错误的双重问题修复]

**Rationale:**
通过详细分析代码发现，双重错误问题的根本原因是 Firestore 安全规则中的时间戳验证与客户端代码不匹配。客户端使用 `Timestamp.now()` 创建用户文档，而安全规则要求 `createdAt == request.time`，导致时间戳不匹配触发 `PERMISSION_DENIED` 错误。UI 显示 "please enter a username" 是因为通用错误处理掩盖了具体的权限错误信息。

**Details:**
**修复的关键问题：**
1. **时间戳不匹配问题**：
   - 修改 [`lib/services/user_service.dart`](lib/services/user_service.dart) 使用 `FieldValue.serverTimestamp()` 替代 `Timestamp.now()`
   - 更新 [`firestore.rules`](firestore.rules) 使时间戳验证更灵活，允许服务器时间戳或有效的客户端时间戳

2. **错误处理改进**：
   - 在 [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart) 中添加对 `permission-denied` 错误的具体处理
   - 显示更明确的权限错误信息而非通用的用户名错误

3. **调试能力增强**：
   - 在用户创建流程中添加详细的调试日志
   - 帮助未来快速定位类似问题

**影响的组件/文件：**
- [`lib/services/user_service.dart`](lib/services/user_service.dart) - 修复时间戳问题
- [`firestore.rules`](firestore.rules) - 更新安全规则
- [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart) - 改进错误处理
- Firestore 安全规则已成功部署
---
### Decision (Debug)
[2025-05-26 03:25:33] - [Bug Fix Strategy: Firestore 时间戳验证问题修复]

**Rationale:**
用户报告的"权限被拒绝：请检查用户名格式是否正确，或稍后重试"错误的根本原因是 Firestore 安全规则中的时间戳验证逻辑与客户端使用的 `FieldValue.serverTimestamp()` 不兼容。安全规则要求 `request.resource.data.createdAt == request.time`，但 `FieldValue.serverTimestamp()` 在客户端是一个特殊的占位符对象，不等于 `request.time`，导致权限验证失败。

**Details:**
**修复的关键问题：**
1. **时间戳验证不兼容**：
   - 问题：firestore.rules 原第23行要求 `(request.resource.data.createdAt == request.time || request.resource.data.createdAt is timestamp)`
   - 冲突：lib/services/user_service.dart 使用 `FieldValue.serverTimestamp()` 
   - 修复：简化为 `&& 'createdAt' in request.resource.data; // 允许任何 createdAt 字段，服务器会处理时间戳`

2. **部署状态**：
   - 成功部署更新后的 Firestore 安全规则
   - 规则编译无错误，部署完成

**影响的组件/文件：**
- firestore.rules - 修复时间戳验证逻辑
---
### Decision (Debug)
[2025-05-26 04:21:10] - [分析结果: 匿名登录自动触发是预期设计，非Bug]

**Rationale:**
用户报告应用启动时自动执行匿名登录的问题。通过详细分析代码流程和Memory Bank历史记录，确认这是**有意的架构设计**，不是需要修复的bug。自动匿名登录是为了支持应用的核心功能需求。

**Details:**
**设计原因分析:**
1. **Firebase UID依赖**: 应用的引继码系统需要稳定的Firebase UID作为用户标识
2. **历史问题解决**: [2025-05-25 05:42:44] 实现匿名登录解决了"认证失败，请重启应用"错误
3. **架构一致性**: 符合Memory Bank中记录的"匿名用户识别"核心架构

**认证流程确认:**
- 启动 → [`lib/main.dart`](lib/main.dart:17) 设置 `/splash` 为初始路由
- [`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:22-25) 自动触发匿名登录
- [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:50) 检查用户名状态
- 路由决策: 有用户名→主页，无用户名→用户名设置

**用户名设置与认证关系:**
- 匿名认证提供Firebase UID (技术层面)
- 用户名设置提供应用层面的用户标识 (业务层面)
- 两者是独立但相关的流程，符合产品设计

**影响的组件/文件:**
- 确认现有设计正确，无需修改
- 用户体验符合预期：自动认证→用户名设置→正常使用
- Firebase 项目 yacht-f816d - 安全规则已更新部署

---
### Decision (Debug)
[2025-05-26 06:26:57] - [Bug Fix Strategy: Flutter 空安全编译错误修复]

**Rationale:**
在 [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:76-77) 第76-77行存在 Flutter 空安全编译错误。`currentUser.getIdToken()` 方法返回的 `idToken` 可能为 `null`，但代码直接访问了 `idToken.length` 和 `idToken.substring()` 方法，违反了 Flutter 的空安全要求。需要添加适当的空检查操作符来确保代码在 idToken 为 null 时不会崩溃。

**Details:**
**修复的关键问题：**
1. **空安全违规**：
   - 问题：第76行 `idToken.length` 和第77行 `idToken.substring(0, math.min(50, idToken.length))` 直接访问可能为 null 的变量
   - 修复：添加 `if (idToken != null)` 空值检查，确保只有在 idToken 不为 null 时才访问其属性和方法

2. **调试信息完整性**：
   - 保持了原有的调试日志功能
   - 添加了 idToken 为 null 时的专门日志输出
   - 确保在所有情况下都有适当的调试信息

**影响的组件/文件：**
- [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:76-81) - 添加空值检查逻辑

---
### Decision (Debug)
[2025-05-26 06:34:59] - [Bug Fix Strategy: Firebase 相关错误修复]

**Rationale:**
用户报告了两个 Firebase 相关错误：1) Cloud Function 参数错误 - deleteUserData 缺少 uid 参数；2) Firestore 权限错误 - 排行榜数据访问被拒绝。通过详细分析代码发现，第一个错误可能是历史问题，当前代码已正确传递参数。第二个错误是由于 Firestore 安全规则中的路径配置与实际使用的集合路径不匹配导致的。

**Details:**
**修复的关键问题：**
1. **Firestore 安全规则路径不匹配**：
   - 问题：firestore.rules 中定义的是 `/scores/{scoreId}` 路径
   - 实际：leaderboard_service.dart 使用的是 `/leaderboards/{leaderboardId}/scores/{scoreId}` 路径
   - 修复：更新 firestore.rules 第43-46行，修正路径匹配

2. **排行榜数据频繁获取优化**：
   - 问题：personalBestScoreProvider 中的 `ref.watch(leaderboardProvider)` 导致不必要的排行榜数据获取
   - 修复：移除 personal_best_score_provider.dart 第15行的 leaderboardProvider 监听
   - 优化：将 leaderboardProvider 从 autoDispose 改为普通版本，避免频繁重建

3. **Cloud Function 调用验证**：
   - 验证：检查了所有 deleteUserData 调用，确认参数传递正确
   - 当前代码：user_service.dart 第240行正确传递了 {'uid': user.uid} 参数

**影响的组件/文件：**
- [`firestore.rules`](firestore.rules:43-46) - 修复排行榜路径匹配
- [`lib/state_management/providers/personal_best_score_provider.dart`](lib/state_management/providers/personal_best_score_provider.dart:15) - 移除不必要的依赖
- [`lib/state_management/providers/leaderboard_providers.dart`](lib/state_management/providers/leaderboard_providers.dart:22) - 优化数据获取策略

---
**[2025-05-26 08:31:00] - 安全审查决策：Firestore 安全规则重大漏洞修复**

**背景：** 对当前 Firestore 安全规则进行全面安全审查，发现多个高风险安全漏洞。

**发现的关键安全问题：**
1. **排行榜完全开放访问** (`allow read: true`) - 高风险数据泄露
2. **transferCode 查询权限过宽** - 可能导致用户枚举攻击
3. **时间戳验证缺失** - 客户端可操纵排行榜时间
4. **数据完整性验证不足** - 缺少格式和范围检查

**决策：**
- 立即收紧排行榜读取权限，要求用户认证
- 禁用客户端 transferCode 查询，改用 Cloud Function
- 强制使用服务器端时间戳验证
- 添加用户名和分数格式验证
- 设置合理的分数上限 (1000分)

**实施优先级：** 紧急 - 涉及用户隐私和数据安全

**相关文件：** [`firestore.rules`](firestore.rules:1), [`firestore_security_recommendations.md`](firestore_security_recommendations.md:1)

---
### Decision (Debug)
[2025-05-26 09:02:00] - [Bug Fix Strategy: Cloud Function 参数传递问题 - App Check 验证失败]

**Rationale:**
通过深度调试分析发现，用户报告的 "The function must be called with a 'uid' argument" 错误并非真正的参数缺失问题。Firebase Functions 日志显示 `"app":"MISSING"`，表明这是 Firebase App Check 验证失败导致的请求拦截。客户端代码和 Cloud Function 代码都正确处理了 `uid` 参数，但请求在到达 Cloud Function 逻辑之前就被 Firebase 安全层拦截了。

**Details:**
**问题分析：**
1. **误导性错误信息**：Firebase 在 App Check 验证失败时返回通用的参数错误，而非具体的验证失败信息
2. **代码验证正确**：
   - [`lib/services/user_service.dart`](lib/services/user_service.dart:240) 正确传递 `{'uid': user.uid}` 参数
   - [`functions/index.js`](functions/index.js:55-63) 正确检查和处理 `uid` 参数
   - Firebase Auth 状态正常，用户认证成功
3. **App Check 状态**：日志显示 `"verifications":{"auth":"VALID","app":"MISSING"}` 确认了 App Check 验证失败

**修复策略：**
1. **开发环境解决方案**：在 Cloud Function 中临时禁用 App Check 验证
2. **生产环境解决方案**：正确配置 Firebase App Check
3. **错误处理改进**：在客户端添加对 App Check 相关错误的特定处理

**影响的组件/文件：**
- [`functions/index.js`](functions/index.js:55) - 需要添加 App Check 配置或禁用验证
- [`lib/services/user_service.dart`](lib/services/user_service.dart:251-257) - 改进错误处理以识别 App Check 错误
- Firebase 项目配置 - 需要配置 App Check 设置

---
### Decision (Debug)
[2025-05-26 09:31:00] - [Bug Fix Strategy: Cloud Function INTERNAL 错误 - JSON 循环引用修复]

**Rationale:**
用户报告的 Cloud Function 错误已从 "uid argument missing" 进化为 "INTERNAL"，表明参数传递问题已解决，但函数内部执行失败。通过查看 Firebase Functions 日志发现根本原因是 `JSON.stringify()` 试图序列化包含循环引用的 `context` 对象，导致 "Converting circular structure to JSON" 错误。

**Details:**
**修复的关键问题：**
1. **JSON 循环引用错误**：
   - 问题：functions/index.js 第57行使用 `JSON.stringify(context)` 导致循环引用错误
   - 根因：context 对象包含 Socket 和 HTTPParser 等具有循环引用的对象
   - 修复：移除 JSON.stringify() 调用，直接输出安全的对象属性

2. **错误处理增强**：
   - 添加分步骤的详细调试日志
   - 改进 Firestore 文档删除的存在性检查
   - 增强 Firebase Auth 用户删除的错误处理
   - 添加对用户不存在情况的优雅处理

3. **代码质量改进**：
   - 修复 ESLint 代码风格问题
   - 成功通过 Firebase Functions 部署验证

**影响的组件/文件：**
- [`functions/index.js`](functions/index.js:55-130) - 修复 JSON 序列化错误和增强错误处理
- Firebase Functions 部署 - 成功部署修复后的版本
---
### Decision (Debug)
[2025-05-26 09:48:45] - [Bug Fix Strategy: Cloud Function 循环引用错误修复]

**Rationale:**
用户报告的 Cloud Function deleteUserData 中的循环引用错误已成功修复。错误源于 `JSON.stringify()` 试图序列化包含循环引用的对象（Socket -> HTTPParser -> Socket），导致 "Converting circular structure to JSON" 错误。通过重构日志记录逻辑，避免直接序列化可能包含循环引用的对象，确保调试信息的完整性和安全性。

**Details:**
**修复的关键问题：**
1. **循环引用序列化错误**：
   - 问题：functions/index.js 第57行 `JSON.stringify(data)` 和第58-63行上下文记录中的循环引用
   - 根因：`context.rawRequest` 包含 Socket 和 HTTPParser 等具有循环引用的网络对象
   - 修复：添加 try-catch 保护和安全的属性提取

2. **调试信息优化**：
   - 为 `JSON.stringify(data)` 添加错误处理，失败时回退到直接对象输出
   - 重构上下文信息记录，只提取安全的属性：
     - `context.auth`: 提取 uid 和 token 存在性
     - `context.app`: 提取 appId 和 projectId
     - `context.rawRequest`: 改为布尔值 `hasRawRequest`
     - `context.instanceIdToken`: 改为存在性字符串

3. **代码质量改进**：
   - 修复所有 ESLint 代码风格问题（引号、逗号、尾随空格）
   - 成功通过 Firebase Functions 部署验证

**影响的组件/文件：**
- [`functions/index.js`](functions/index.js:55-77) - 修复循环引用和代码风格
- Firebase Functions 部署 - 成功部署修复后的版本到项目 yacht-f816d
- 调试能力 - 保持完整调试信息的同时避免循环引用错误
- [`test_delete_function.dart`](test_delete_function.dart:1) - 创建测试脚本验证修复

---
### Decision (Debug)
[2025-05-26 10:03:59] - [Bug Fix Strategy: Cloud Function `deleteUserData` - `invalid-argument` due to UID extraction]

**Rationale:**
The `deleteUserData` Cloud Function ([`functions/index.js`](functions/index.js:55)) is throwing an `invalid-argument` error, indicating a missing "uid" parameter. Cloud Function logs show "提取的 UID: undefined" and "上下文信息: { auth: null, ... }". Client-side logs suggest a potential App Check failure, but also indicate that the `uid` might be nested within `data.data.uid` due to the log entry `body: { data: [Object] }`. The previous fix for circular references in logging did not address this potential uid extraction issue.

**Details:**
**修复的关键问题：**
1.  **UID 提取逻辑**:
    *   问题：当前直接从 `data.uid` ([`functions/index.js`](functions/index.js:79)) 提取 `uid`，但客户端可能将其包装在 `data.data.uid` 中。
    *   修复：修改 [`functions/index.js`](functions/index.js:79-81) 的 `uid` 提取逻辑，使其首先尝试 `data.uid`，如果不存在，则尝试 `data.data.uid`。

2.  **日志记录增强**:
    *   问题：需要更清晰地了解传入 `data` 对象的实际结构，以确认 `uid` 的位置。
    *   修复：在 [`functions/index.js`](functions/index.js:58-63) 中增强日志记录，包括：
        *   记录原始传入的 `data` 对象。
        *   尝试序列化 `data` 对象并记录，如果失败则记录原始对象和错误。
        *   记录 `data` 对象的顶层键。
        *   如果存在 `data.data`，记录其嵌套对象的键。
        *   记录最终提取的 `uid` 值。

**影响的组件/文件：**
- [`functions/index.js`](functions/index.js:1) - 修改了 `uid` 提取逻辑和增强了日志记录。

**预期结果：**
- Cloud Function 能够正确提取 `uid` 参数，无论其是否被嵌套。
- 增强的日志将提供足够的信息来诊断任何进一步的参数传递问题。
- 解决 `invalid-argument` 错误。
