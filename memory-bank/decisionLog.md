# Decision Log

This file records architectural and implementation decisions using a list format.
2025-05-23 02:56:43 - Log of updates made.

*

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