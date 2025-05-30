# 项目架构文档

## 1. 概述

本文档描述了 [项目名称，从productContext.md获取] 应用的整体架构。

## 2. 前端架构 (Flutter)

### 2.1. 关键模块/目录结构
*   `lib/core_logic/`: 核心游戏逻辑 (例如 `game_state.dart`, `dice_roller.dart`, `scoring_rules.dart`)。
*   `lib/models/`: 数据模型 (例如 `user_profile.dart`, `score_entry.dart`)。
*   `lib/services/`: 服务层，处理外部交互 (例如 [`auth_service.dart`](lib/services/auth_service.dart:1), [`user_service.dart`](lib/services/user_service.dart:1), [`leaderboard_service.dart`](lib/services/leaderboard_service.dart:1), [`local_storage_service.dart`](lib/services/local_storage_service.dart:1))。[`UserService`](lib/services/user_service.dart:1) 负责协调账号删除流程。[`LocalStorageService`](lib/services/local_storage_service.dart:1) 包含 `clearAllUserData()` 方法用于清除所有本地用户数据。
*   `lib/state_management/`: Riverpod providers 和 notifiers。
*   `lib/ui_screens/`: 应用的主要屏幕。[`SettingsScreen`](lib/ui_screens/settings_screen.dart:1) 将包含“清空本地数据”按钮及其处理逻辑。
*   `lib/widgets/`: 可重用的 UI 组件。
*   `lib/navigation/`: GoRouter 配置 (`app_router.dart`)。
*   `lib/l10n/`: 本地化文件 (`.arb` 文件)。
*   `lib/generated/`: 生成的本地化代码。
*   `lib/utils/`: 通用工具类。

### 2.2. 状态管理
*   **方案:** Riverpod
*   **理由:** 编译时安全、可测试性、灵活性、声明式、无需 `BuildContext` 访问 Provider，性能优化。
*   **实现:** Providers 定义在 `lib/state_management/providers/` 目录下。UI 组件通过 `ref.watch` 和 `ref.read` 与状态交互。
    *   **游戏状态 (`gameStateProvider`):** 这是管理核心游戏逻辑状态的关键 Provider。它通过 `GameStateNotifier` ([`lib/state_management/providers/game_providers.dart`](lib/state_management/providers/game_providers.dart:1)) 提供对 `GameState` ([`lib/core_logic/game_state.dart`](lib/core_logic/game_state.dart:1)) 的访问和修改。
        *   **状态重置与初始化:** 当开始新游戏时，`GameStateNotifier.resetAndStartNewGame()` 方法被调用。此方法必须使用 `GameState.initial()` 工厂构造函数来创建一个全新的、干净的 `GameState` 实例，确保所有游戏相关属性（如骰子、剩余投掷次数、当前回合、分数、游戏是否进行中等）都恢复到初始默认值。这是防止旧游戏状态影响新游戏的关键。

### 2.3. 导航策略
*   **方案:** GoRouter
*   **理由:** 声明式路由、深度链接、类型安全路由（通过代码生成）、易于处理复杂场景。
*   **实现:** 路由配置在 [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1)。其 `redirect` 逻辑对于处理用户认证状态变化（包括账号删除后变为未登录）并正确导航至初始屏幕（如创建账号页或启动页）至关重要。
    *   **游戏屏幕路由守卫:** 对于导航到 [`GameScreen`](lib/ui_screens/game_screen.dart:1) 的路由 (例如 `GameScreenRoute`)，可以设置一个 `redirect` 函数。此守卫会读取当前的 `gameStateProvider`。如果 `!gameState.isGameInProgress && !gameState.gameOver`（即游戏既未开始也不处于结束状态），则用户将被重定向回主屏幕 (例如 `HomeScreenRoute`)，防止在无效状态下访问游戏界面。

### 2.4. 用户名创建与管理流程

#### 2.4.1. 概述
用户在首次启动应用时需要设置用户名。此过程涉及客户端验证、后端唯一性检查、数据持久化以及全面的错误处理。目标是提供一个流畅、健壮且用户友好的体验。

#### 2.4.2. 流程步骤

1.  **用户输入 (Flutter - [`UsernameSetupScreen`](lib/ui_screens/username_setup_screen.dart:1)):**
    *   用户在输入框中输入期望的用户名。
    *   **客户端验证:**
        *   实时格式验证：检查长度（例如，3-15个字符）、允许的字符集（例如，字母数字）。通过 `TextFormField` 的 `validator` 实现。
        *   UI 立即显示具体错误信息。
    *   用户点击“保存”或类似按钮。

2.  **保存尝试 (Flutter - [`UserService`](lib/services/user_service.dart:1)):**
    *   UI 层调用 `UserService.saveUsername(String username)`。
    *   **网络连接检查:** (可选，但推荐) 使用 `connectivity_plus` 检查网络。若无网络，提前返回错误。
    *   **UI 加载状态:** 保存按钮禁用，显示加载指示器。

3.  **后端唯一性检查与保存 (Firebase Cloud Function & Firestore):**
    *   `UserService` 调用一个 Firebase Cloud Function (例如，`callable_setUniqueUsername(username)`)。
    *   **Cloud Function (`setUniqueUsername`):**
        *   接收 `username` 和调用者的 `context.auth.uid`。
        *   **Firestore 事务:**
            1.  读取 `usernames/{normalized_username}` 文档 (其中 `normalized_username` 是小写或规范化的用户名，以确保不区分大小写的唯一性)。
            2.  **如果 `usernames/{normalized_username}` 已存在且其存储的 UID 与当前用户 UID 不同:** 用户名已被他人占用。事务中止，函数返回 `ALREADY_EXISTS` 错误。
            3.  **如果 `usernames/{normalized_username}` 已存在且其存储的 UID 与当前用户 UID 相同:** 用户尝试保存已拥有的用户名。可视为成功或无操作。
            4.  **如果 `usernames/{normalized_username}` 不存在:**
                a.  创建 `usernames/{normalized_username}` 文档，内容可包含 `userId: context.auth.uid`。
                b.  更新 `users/{context.auth.uid}` 文档，设置/更新 `username` 字段。
            5.  事务成功提交。函数返回成功。
        *   **错误处理:** Cloud Function 内部使用 `try-catch`，返回标准化的错误代码 (例如 `ALREADY_EXISTS`, `INTERNAL`, `PERMISSION_DENIED`)。

4.  **结果处理 (Flutter - [`UserService`](lib/services/user_service.dart:1) & UI):**
    *   `UserService` 捕获来自 Cloud Function 的响应或异常。
        *   **成功:**
            *   调用 `LocalStorageService.saveUsername(username)` 缓存用户名。
            *   通知 UI (例如，通过 Riverpod Notifier 更新状态)。
            *   UI 清除加载状态，导航到下一屏幕 (例如，主页)。
        *   **失败 (例如，`ALREADY_EXISTS`):**
            *   将错误代码转换为用户友好的本地化消息 (例如，“该用户名已被使用”)。
            *   通知 UI。
            *   UI 清除加载状态，显示错误消息。
        *   **失败 (网络错误/超时/其他 Firebase 错误):**
            *   实现重试逻辑 (例如，最多2-3次，带指数退避)。
            *   多次失败后，转换为用户友好的本地化消息 (例如，“网络错误，请重试”，“保存失败，请稍后重试”)。
            *   通知 UI。
            *   UI 清除加载状态，显示错误消息。

#### 2.4.3. 错误处理策略

*   **分层:** 服务层捕获原始异常并转换为应用特定错误；状态管理层更新错误状态；UI 层显示用户友好的本地化消息。
*   **具体错误消息:** 针对不同错误场景（网络、已存在、权限、服务器内部错误）提供不同的、清晰的提示。
*   **加载状态:** 严格管理 UI 加载状态，确保在操作开始时显示，在结束时（无论成功或失败）清除。

#### 2.4.4. 鲁棒性与幂等性

*   **鲁棒性:** 通过网络检查、超时、重试机制、详细的后端错误处理和清晰的用户反馈实现。
*   **幂等性:** Cloud Function 设计应确保如果用户重复尝试使用已成功注册的用户名进行保存，操作不会产生副作用（如重复创建条目），并能返回一个表示成功或无变化的响应。客户端在调用保存前也可检查本地状态，避免不必要的后端调用。

### 2.5. 用户会话结束、状态重置与导航

在用户会话结束的关键时刻（例如用户登出、账号删除成功后），应用必须执行彻底的客户端状态清理、导航重置，以确保数据隔离、防止状态泄露并提供正确的用户体验。修复后的流程确保用户在删除账号后被正确登出，本地数据被清除，应用状态被重置，并导航到初始的应用流程（如启动页 [`/splash`](lib/ui_screens/splash_screen.dart:1)，然后是账号创建/用户名设置页 [`UsernameSetupScreen`](lib/ui_screens/username_setup_screen.dart:1)）。此过程涉及以下步骤：

1.  **认证状态清除:**
    *   调用 `AuthService.signOut()` 来清除当前的 Firebase Authentication 凭据和会话。这将通知应用认证状态已改变。
2.  **本地用户数据清除:**
    *   调用 [`LocalStorageService.clearAllUserData()`](lib/services/local_storage_service.dart:44) 方法，清除所有存储在本地的、与特定用户相关的数据（例如，用户名、用户偏好设置、缓存的游戏状态等）。
3.  **应用状态重置 (State Management - Riverpod):**
    *   使所有与用户特定数据相关的 Riverpod Providers 无效。这可以通过 `ref.invalidate(providerName)` 实现，确保它们在下次被读取时会重置到其初始状态。
    *   关键 Providers 包括但不限于：`userProvider`, `usernameProvider`, `personalBestScoreProvider`, `currentAuthStatusProvider` (如果存在)，以及任何其他存储用户特定信息的 Provider。
    *   如果游戏状态 (`gameStateProvider`) 与特定用户绑定，也应将其重置。
4.  **导航至初始屏幕:**
    *   使用 `NavigationService` (GoRouter) 强制导航到应用的初始屏幕，例如 [`/splash`](lib/ui_screens/splash_screen.dart:1) (启动页)，随后应用逻辑会引导用户至账号创建页 ([`UsernameSetupScreen`](lib/ui_screens/username_setup_screen.dart:1)) 或类似界面。
    *   关键在于使用能够清理当前导航堆栈的导航方法 (例如，GoRouter 中的 `go()` 或 `replace()` 方法，并确保路由配置能处理 `replaceAll: TRUE` 的效果)，防止用户通过返回按钮回到之前的、与已删除用户相关的界面。
5.  **UI 反馈 (可选):**
    *   可以短暂显示一个全局消息（例如 Snackbar），告知用户操作已成功完成，并且正在返回初始界面。

### 2.6. 游戏界面 (`GameScreen`) 渲染逻辑

[`GameScreen`](lib/ui_screens/game_screen.dart:1) 的构建逻辑 (`build` 方法) 严重依赖于从 `gameStateProvider` 获取的当前 `GameState`。
*   **状态依赖:** UI 组件（如骰子、计分板、回合指示器）的显示和行为都基于 `gameState` 的属性。
*   **无效状态处理:** 在 `build` 方法的早期，应检查 `gameState.isGameInProgress` 和 `gameState.gameOver`。
    *   如果 `!gameState.isGameInProgress && !gameState.gameOver`，这可能表示状态异常或用户不应在此屏幕。此时，可以考虑：
        *   使用 `WidgetsBinding.instance.addPostFrameCallback` 异步导航回主屏幕 (例如 `context.go(HomeScreenRoute)`)，以避免在构建期间直接导航。
        *   或者，显示一个加载指示器或错误消息，而不是尝试渲染游戏界面。
*   **游戏结束逻辑:** 当 `gameState.gameOver` 为 `true` 时，应显示游戏结束对话框或相关UI。

### 2.7. 开始新游戏流程

当用户触发“开始新游戏”操作时（例如，在 [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) 中点击按钮），会发生以下关键步骤：

1.  **状态重置:** 调用 `ref.read(gameStateProvider.notifier).resetAndStartNewGame()`。
    *   这会触发 `GameStateNotifier` 中的 `resetAndStartNewGame` 方法。
    *   该方法的核心是 `state = GameState.initial();`，确保使用工厂构造函数创建一个全新的、干净的 `GameState` 实例。所有游戏相关的属性（骰子、回合、分数、`isGameInProgress` 等）都被设置为初始值。`isGameInProgress` 通常在此处设置为 `true`。
2.  **导航:** 调用 `context.go(GameScreenRoute)` (或等效的导航命令) 将用户导航到 [`GameScreen`](lib/ui_screens/game_screen.dart:1)。
3.  **路由守卫 (如果配置):** [`AppRouter`](lib/navigation/app_router.dart:1) 中的 `redirect` 守卫会检查新的 `GameState`。由于 `isGameInProgress` 此时应为 `true`，导航通常会成功。
4.  **`GameScreen` 渲染:** [`GameScreen`](lib/ui_screens/game_screen.dart:1) 读取已正确初始化的 `GameState` 并渲染游戏界面。由于 `isGameInProgress` 为 `true`，游戏界面会正常显示。

这个流程确保了每次开始新游戏时，都有一个干净、独立的游戏状态，避免了之前游戏会话的数据干扰。

### 2.8. 清空本地数据功能

此功能允许用户从当前设备清除所有本地存储的账户相关数据，而不删除后端服务器上的实际账户。用户仍可通过引继码恢复账户。

**流程:**

1.  **用户触发 (UI - [`lib/ui_screens/settings_screen.dart`](lib/ui_screens/settings_screen.dart:1)):**
    *   用户在设置屏幕点击“清空此设备上的账户数据”按钮。
    *   显示确认对话框，解释操作后果（仅本地数据，账户可恢复）。
2.  **确认操作:**
    *   用户确认清除。
3.  **执行清除 (UI 调用服务层):**
    *   `isLoading` 状态设置为 `true`。
    *   调用 `ref.read(localStorageServiceProvider).clearAllUserData()`。
        *   **[`LocalStorageService.clearAllUserData()`](lib/services/local_storage_service.dart:1):** 此方法将调用内部的各个具体清除方法，例如 `clearUsername()`, `clearTransferCode()`, `clearUID()`, `clearGameSettings()` 等，以删除所有存储在 `shared_preferences` 或其他本地存储中的用户数据。
    *   调用 `ref.read(authServiceProvider).signOut()`。
        *   **[`AuthService.signOut()`](lib/services/auth_service.dart:1):** 清除 Firebase Authentication 的本地会话。
    *   调用 `resetUserSpecificProviders(ref)` (一个在 UI 层或状态管理层定义的辅助函数)。
        *   **`resetUserSpecificProviders(ref)`:** 使所有用户相关的 Riverpod Provider（如 `userProvider`, `usernameProvider`, `personalBestScoreProvider` 等）失效 (`ref.invalidate()`)，确保它们在下次读取时重置为初始状态。
4.  **导航:**
    *   使用 `GoRouter.of(context).go('/splash')` (或类似方法) 导航到初始屏幕，并清除导航堆栈。
5.  **用户反馈:**
    *   显示操作成功的提示信息 (例如 Snackbar)。
    *   `isLoading` 状态设置为 `false`。
6.  **错误处理:**
    *   在 `try-catch` 块中执行上述操作，捕获任何潜在错误。
    *   如果发生错误，显示错误提示信息 (例如 Snackbar)。
    *   确保 `isLoading` 状态在 `finally` 块中设置为 `false`。

**关键点:**

*   **无后端交互:** 此操作纯粹是客户端行为，不与 Firebase 后端通信以删除数据。
*   **数据可恢复性:** 用户的账户在服务器上保持不变，可以通过引继码在任何设备上恢复。
*   **与账户删除的区别:** “账户删除”功能会调用后端 Cloud Function 删除服务器数据和 Firebase Auth 用户记录，是永久性操作。

## 3. 后端架构 (Firebase)

### 3.1. Firebase Authentication
*   **用途:** 匿名用户认证，为每个用户提供唯一的 UID。未来可扩展至其他登录方式。
*   **引继码系统:** 结合自定义令牌认证，允许用户通过引继码恢复账户。
    *   Cloud Function `generateCustomAuthToken(uid)`: 生成自定义令牌。
    *   客户端使用 `signInWithCustomToken()`。

### 3.2. Cloud Firestore
*   **用途:** 主要数据库，存储用户信息、游戏数据、排行榜等。
*   **数据模型示例:**
    *   `users/{userId}`:
        *   `username`: String (唯一，通过 Cloud Function 强制)
        *   `normalizedUsername`: String (用于不区分大小写的唯一性检查，索引)
        *   `transferCode`: String (索引)
        *   `createdAt`: Timestamp
        *   `gameData`: Map (例如，`highScores`, `elo`)
    *   `usernames/{normalizedUsername}`: (用于确保用户名唯一性的辅助集合)
        *   `userId`: String (指向 `users` 集合的 UID)
    *   `leaderboards/{gameMode}`:
        *   `scores`: Subcollection
            *   `{scoreId}`: `userId`, `username`, `score`, `timestamp`
*   **安全规则 ([`firestore.rules`](firestore.rules:1)):**
    *   遵循最小权限原则。
    *   用户只能读写自己的 `users/{userId}` 文档。
    *   `usernames` 集合的写入由 Cloud Function 控制。
    *   排行榜写入规则根据具体逻辑设定。

### 3.3. Firebase Cloud Functions ([`functions/src/index.ts`](functions/src/index.ts:1) 或 `index.js`)
*   **用途:** 实现安全敏感的后端逻辑、原子操作、与其他 Firebase 服务或外部 API 的集成。
*   **关键函数示例:**
    *   `callable_setUniqueUsername(data, context)`: 处理用户名注册，确保唯一性（使用 Firestore 事务）。
    *   `callable_generateCustomAuthToken(data, context)`: 为账户恢复生成自定义认证令牌。
    *   `callable_deleteUserData(data, context)`: 删除用户所有相关数据 (Firestore 中的用户数据、Firebase Authentication 中的用户记录等)。**此函数仅处理后端数据删除。**
        *   **客户端后续操作（由 [`UserService.deleteCurrentUserAccount()`](lib/services/user_service.dart:1) 和 [`SettingsScreen._deleteAccount()`](lib/ui_screens/settings_screen.dart:1) 协调）：** 在 `deleteUserData` Cloud Function 成功返回后，客户端应用执行以下操作：
            1.  [`UserService.deleteCurrentUserAccount()`](lib/services/user_service.dart:1) 调用 [`AuthService.signOut()`](lib/services/auth_service.dart:1) 清除 Firebase Auth 状态。
            2.  [`UserService.deleteCurrentUserAccount()`](lib/services/user_service.dart:1) 调用 [`LocalStorageService.clearAllUserData()`](lib/services/local_storage_service.dart:44) 清除本地存储的用户数据。
            3.  [`SettingsScreen._deleteAccount()`](lib/ui_screens/settings_screen.dart:1) 方法负责重置相关的 Riverpod Providers (例如通过 `ref.invalidate(providerName)` 或调用特定的重置方法)。
            4.  [`SettingsScreen._deleteAccount()`](lib/ui_screens/settings_screen.dart:1) 方法执行强制导航到初始屏幕 [`/splash`](lib/ui_screens/splash_screen.dart:1)，并清空导航堆栈。应用将从启动页开始，引导用户至账号创建/设置流程。
            5.  参考上述 `2.5. 用户会话结束、状态重置与导航` 部分的详细步骤。
     *   `callable_recoverAccountByTransferCode(data, context)`: (Cloud Function) 接收引继码，查询 Firestore `users` 集合以找到匹配的 `transferCode`。如果找到，则获取对应的 `userId` 和存储的 `personalBestScore` (以及其他需要恢复的数据如 `username`, `elo` 等)。返回包含这些数据的对象给客户端。
     *   Firestore 触发器 (例如，`onUserCreate`, `onScoreSubmit`) 可用于数据聚合或维护。

### 3.4. 账户恢复流程中的数据同步与状态更新 (最高分问题相关)

**问题:** 用户通过引继码恢复账户后，最高分未在主屏幕显示。

**核心流程与数据同步点:**

1.  **客户端请求恢复 (Flutter - [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1) 或相关服务):**
    *   用户输入引继码。
    *   客户端调用 Cloud Function `recoverAccountByTransferCode`，传递引继码。

2.  **后端处理 (Cloud Function - `recoverAccountByTransferCode` - [`functions/index.js`](functions/index.js:1)):**
    *   函数查询 Firestore `users` 集合，查找与引继码匹配的文档。
    *   **关键:** 确保此函数在其返回给客户端的数据中包含 `personalBestScore` 字段 (以及 `username` 和其他必要数据)。

3.  **客户端接收与处理 (Flutter - [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1) - `_recoverAccount` 方法):**
    *   成功从 Cloud Function 接收到恢复的数据 (包括 `recoveredUsername`, `recoveredPersonalBestScore`)。
    *   **关键数据持久化:**
        *   调用 `localStorageService.saveUsername(recoveredUsername)` 保存用户名。
        *   调用 `localStorageService.saveSpecificUserPersonalBest(recoveredUsername, recoveredPersonalBestScore)` 将恢复的最高分保存到本地存储。**这是确保后续能正确读取最高分的关键步骤。**
    *   **状态刷新:**
        *   `ref.refresh(userProvider)` (或等效的 provider，如 `userProfileProvider`)。
        *   `ref.refresh(usernameProvider)`。
        *   `ref.refresh(personalBestScoreProvider)`。**此 provider 依赖于 `usernameProvider` 和 `LeaderboardService` (后者从本地存储读取最高分)。**

4.  **状态管理 (`PersonalBestScoreProvider` - [`lib/state_management/providers/personal_best_score_provider.dart`](lib/state_management/providers/personal_best_score_provider.dart:1)):**
    *   此 Provider 依赖于 `usernameProvider` 来获取当前用户名。
    *   它调用 `LeaderboardService.getPersonalBestScore(String username)`。
    *   **[`LeaderboardService.getPersonalBestScore(String username)`](lib/services/leaderboard_service.dart:1):** 此服务方法从本地存储 (通过 `LocalStorageService`) 读取指定用户的个人最高分。

5.  **UI 显示 (`HomeScreen` - [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1)):**
    *   `HomeScreen` 监听 `personalBestScoreProvider`。
    *   当 `personalBestScoreProvider` 状态更新（在账户恢复并刷新后），UI 应能正确显示恢复的最高分。

**诊断要点:**

*   **后端数据返回:** 确认 `recoverAccountByTransferCode` Cloud Function 确实返回了 `personalBestScore`。
*   **客户端数据保存 (核心问题点):** **首要确认在账户恢复逻辑 ([`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1) `_recoverAccount` 方法) 中，从后端获取的 `personalBestScore` 是否被正确地、无遗漏地使用 `localStorageService.saveSpecificUserPersonalBest()` 保存到了本地存储。`spec-pseudocode` 分析指出这很可能是当前问题的根源。**
*   **Provider 依赖与刷新顺序:** 确保 `personalBestScoreProvider` 在其依赖的 `usernameProvider` 更新之后，并且在本地最高分数据写入之后被刷新。
*   **`LeaderboardService` 读取逻辑:** 确认 `LeaderboardService.getPersonalBestScore` 能从本地存储正确读取数据。

## 4. 数据流

(根据需要添加序列图或流程图，例如用户注册、游戏流程、排行榜提交流程)

## 5. 系统模式

参考 [`memory-bank/systemPatterns.md`](memory-bank/systemPatterns.md:1) 中定义的编码、架构和测试模式。

## 6. 部署与运维

(描述应用的构建、部署流程，以及监控和维护策略)

---
*上次更新: 2025-05-26 13:06:20 - 更新了账号删除流程的文档，以反映最新的代码更改：明确了 `LocalStorageService.clearAllUserData()` 的调用，`UserService` 对登出和本地数据清除的协调，以及 `SettingsScreen` 在成功删除账号后重置状态并导航到 `/splash` 的行为。*
*上次更新: 2025-05-26 13:25:00 - 更新了前端架构部分，详细说明了新游戏开始时的游戏状态管理 (`GameState.initial()`)、`GameScreen` 的渲染逻辑（依赖 `isGameInProgress` 和 `gameOver` 标志）以及相关的导航守卫逻辑，以解决“新游戏不显示任何画面”的错误。*
*上次更新: 2025-05-27 15:02:29 - 添加了 "3.4. 账户恢复流程中的数据同步与状态更新 (最高分问题相关)" 部分，详细描述了在账户恢复后确保最高分正确显示所需的后端、客户端数据持久化和状态管理流程。