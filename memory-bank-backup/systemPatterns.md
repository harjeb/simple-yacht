# System Patterns *Optional*

This file documents recurring patterns and standards used in the project.
It is optional, but recommended to be updated as the project evolves.
2025-05-23 02:56:51 - Log of updates made.

*

## Coding Patterns

[2025-05-23 03:08:49] - **Flutter 目录结构:** 采用模块化的目录结构，将核心逻辑、模型、服务、UI 屏幕、小部件、工具和导航分开。详细结构参见 `memory-bank/architecture.md#21-关键模块目录`。
*
---
### [异步操作与加载状态管理 (Flutter/Riverpod)]
[2025-05-25 06:15:00] - **模式描述:** 在执行异步操作（例如，网络请求、Firebase 调用）时，正确管理 UI 的加载状态 (`isLoading`) 至关重要，以提供清晰的用户反馈并防止意外行为。
    *   **触发:** 任何可能耗时的异步操作开始时。
    *   **逻辑:**
        1.  **启动加载:** 在异步操作开始前，立即将相关的状态（例如，Provider 中的 `isLoading` 标志）设置为 `true`。
        2.  **通知 UI:** 如果使用状态管理库（如 Riverpod），确保在状态更改后调用 `notifyListeners()` (对于 `ChangeNotifier`) 或等效方法，以触发 UI 重建。
        3.  **执行异步操作:** 使用 `try-catch-finally` 块来包裹异步调用。
            *   `try`: 执行异步操作。
            *   `catch`: 处理任何潜在的错误，更新错误状态（例如 `errorMessage`），并通知 UI。
            *   `finally`: **关键步骤** - 无论异步操作成功、失败还是返回 `null`，都必须在此块中将 `isLoading` 状态设置为 `false`。再次通知 UI。
        4.  **UI 响应:** UI 组件应监听 `isLoading`、数据和错误状态。
            *   当 `isLoading` 为 `true` 时，显示加载指示器（例如 `CircularProgressIndicator`）。
            *   当 `isLoading` 为 `false` 且数据可用时，显示数据。
            *   当 `isLoading` 为 `false` 且发生错误时，显示错误信息。
    *   **关键组件/概念:**
        *   Riverpod Providers (例如 `StateNotifierProvider`, `FutureProvider`)
        *   `isLoading` 标志 (布尔值)
        *   `try-catch-finally` 块
        *   `notifyListeners()` (或等效的 UI 更新触发器)
        *   UI 组件中的条件渲染 (例如 `context.watch`, `AsyncValue.when`)
    *   **示例场景:** 用户认证、从 API 获取数据、向数据库提交数据。
    *   **重要性:** 确保 UI 准确反映应用的当前状态，防止用户在操作仍在进行时执行冲突操作，并提供错误反馈。

## Architectural Patterns

[2025-05-23 03:09:02] - **状态管理 (Flutter):** 使用 Riverpod 进行状态管理。详细理由和影响参见 `memory-bank/decisionLog.md` 和 `memory-bank/architecture.md#22-状态管理`。
[2025-05-23 03:09:02] - **导航 (Flutter):** 使用 GoRouter 进行声明式路由和导航。详细理由和影响参见 `memory-bank/decisionLog.md` 和 `memory-bank/architecture.md#23-导航策略`。
[2025-05-23 03:09:02] - **后端架构:** 采用 Firebase (Firestore, Firebase Functions, Firebase Authentication) 作为后端即服务 (BaaS)。详细理由和组件参见 `memory-bank/decisionLog.md` 和 `memory-bank/architecture.md#3-后端架构`。
[2025-05-23 03:09:02] - **数据流模式:** 关键操作 (如双人游戏掷骰子、提交排行榜分数) 的数据流已在 `memory-bank/architecture.md#4-数据流` 中使用序列图定义。
[2025-05-24 12:28:41] - **首次用户启动设置流程 (例如，用户名设置):**
    *   **触发:** 应用启动时。
    *   **逻辑:**
        1.  检查持久化存储 (例如 `shared_preferences` 通过 `UserService` ([`lib/services/user_service.dart`](lib/services/user_service.dart:1))) 中是否存在必要的设置（例如，用户名）。
        2.  如果设置不存在，使用导航器 (例如 `GoRouter` 的 `redirect` 功能在 [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1) 中配置) 将用户重定向到一个专门的设置屏幕 (例如 [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1))。
        3.  设置屏幕强制用户输入并保存所需信息。
        4.  保存后，用户被重定向到应用的主界面 (例如 `/`)。
        5.  如果设置已存在，则正常加载主界面。
    *   **关键组件:** `UserService`, `user_providers` ([`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1)), `UsernameSetupScreen`, `GoRouter.redirect`。
*
---
### [使用 Cloud Function 和 Firestore 事务实现唯一性约束 (例如用户名)]
[2025-05-25 12:50:00] - **模式描述:** 在分布式数据库如 Firestore 中强制跨文档的唯一性约束（例如，确保用户名在整个系统中是唯一的）通常需要服务器端逻辑。此模式利用 Firebase Cloud Functions 和 Firestore 事务来实现原子性的检查和写入操作。
    *   **触发:** 需要创建或更新一个具有唯一性要求的字段时（例如，用户注册新用户名）。
    *   **逻辑:**
        1.  **客户端请求:** 客户端 (Flutter 应用) 调用一个可调用的 Cloud Function (例如 `callable_setUniqueUsername`)，传递需要设为唯一的字段值 (例如 `username`) 和相关标识符 (例如 `userId`)。
        2.  **Cloud Function 执行:**
            a.  **规范化 (可选但推荐):** 对输入值进行规范化处理（例如，转换为小写，去除多余空格）以确保一致的唯一性检查（例如，`NormalizedUsername = username.toLowerCase()`)。
            b.  **Firestore 事务启动:** Cloud Function 启动一个 Firestore 事务。
            c.  **唯一性检查 (事务内):**
                *   读取一个专门用于跟踪唯一值的辅助集合中的文档 (例如，`db.collection('usernames').doc(NormalizedUsername)`)。
                *   如果该文档存在：
                    *   检查其关联的 `userId` (如果存储了) 是否与当前请求的 `userId` 相同。如果是，则用户尝试更新为自己已有的值，可视为成功或无操作。
                    *   如果 `userId` 不同，则表示该值已被其他用户占用。事务中止，函数返回一个明确的错误 (例如 `ALREADY_EXISTS`)。
            d.  **数据写入 (事务内):**
                *   如果唯一性检查通过 (文档不存在或属于同一用户)：
                    *   在辅助集合中创建/更新文档 (例如，`db.collection('usernames').doc(NormalizedUsername).set({ userId: currentUserId })`)。
                    *   在主数据集合中创建/更新包含该唯一字段的文档 (例如，`db.collection('users').doc(currentUserId).update({ username: originalUsername, normalizedUsername: NormalizedUsername })`)。
            e.  **事务提交:** 尝试提交事务。
        3.  **响应客户端:** Cloud Function 根据事务的结果（成功或特定错误）向客户端返回响应。
    *   **关键组件/概念:**
        *   Firebase Cloud Functions (Callable).
        *   Firestore Transactions (`admin.firestore().runTransaction(...)`).
        *   辅助集合 (例如 `usernames`)，其文档 ID 为需要确保唯一的规范化值。
        *   主数据集合 (例如 `users`)。
        *   规范化逻辑。
        *   明确的错误代码 (例如 `ALREADY_EXISTS`, `INTERNAL_ERROR`).
    *   **示例场景:** 用户名注册、确保邮箱地址唯一、创建唯一的优惠券代码。
    *   **重要性:**
        *   **原子性:** 事务确保唯一性检查和数据写入要么全部成功，要么全部失败，防止数据不一致。
        *   **并发安全:** Firestore 事务能够处理并发请求，确保数据完整性。
        *   **服务器端逻辑:** 将关键的唯一性校验逻辑放在服务器端，更安全、更可靠。
    *   **相关文件:** [`functions/src/index.ts`](functions/src/index.ts:1) (或 `.js`), [`memory-bank/architecture.md`](memory-bank/architecture.md:1) (用户名创建流程部分)。

---
### [使用启动画面 (Splash Screen) 处理初始异步操作 (例如认证)]
[2025-05-25 06:27:12] - **模式描述:** 为了在应用启动时提供流畅的用户体验并有效管理初始的异步操作（如用户认证、加载配置等），推荐使用启动画面 (Splash Screen)。此模式将耗时的启动任务与主 UI 分离，并提供明确的加载反馈。
    *   **触发:** 应用启动时。
    *   **逻辑:**
        1.  **设置初始路由:** 将应用的初始路由指向一个专门的 `SplashScreen` UI 组件 (例如，在 [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1) 中设置 `initialLocation: '/splash'`)。
        2.  **专用状态管理器 (可选但推荐):** 创建一个专门的 Riverpod Notifier (例如 `AnonymousSignInNotifier` 在 [`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1)) 来处理特定的异步操作（如匿名登录）。此 Notifier 负责管理其自身的 `isLoading` 状态和操作结果。
        3.  **`SplashScreen` UI ([`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:1)):**
            *   在 `initState` 或首次构建时，调用状态管理器（或直接服务）以启动异步操作。
            *   监听状态管理器的 `isLoading` 状态，并显示相应的加载指示器 (例如 `CircularProgressIndicator`)。
            *   监听操作结果（成功、失败、特定错误代码）。
            *   根据结果：
                *   **成功:** 导航到应用的主界面 (例如 `/home`) 或下一个必要的设置屏幕 (例如 `/username_setup`)。
                *   **失败:** 显示错误消息，并可能提供重试选项。
        4.  **主应用逻辑 (`main.dart`):** 从 `main()` 函数中移除直接的异步启动逻辑，将其委托给 `SplashScreen`。
    *   **关键组件/概念:**
        *   `SplashScreen` UI 组件。
        *   Riverpod Notifier (例如 `StateNotifier`，专门用于处理启动任务的状态)。
        *   `GoRouter` (或其他导航库) 用于初始路由和后续导航。
        *   `isLoading` 标志和错误状态管理。
    *   **示例场景:** 匿名用户认证、获取远程配置、检查更新、加载必要的本地数据。
    *   **重要性:**
        *   改善用户体验：避免应用启动时出现卡顿或无响应的界面。
        *   清晰的状态管理：将复杂的启动逻辑封装起来，易于维护和测试。
        *   提供明确的反馈：用户知道应用正在加载或遇到了问题。

## Testing Patterns

*