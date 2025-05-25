# 项目架构文档

## 1. 概述

本文档描述了 [项目名称，从productContext.md获取] 应用的整体架构。

## 2. 前端架构 (Flutter)

### 2.1. 关键模块/目录结构
*   `lib/core_logic/`: 核心游戏逻辑 (例如 `game_state.dart`, `dice_roller.dart`, `scoring_rules.dart`)。
*   `lib/models/`: 数据模型 (例如 `user_profile.dart`, `score_entry.dart`)。
*   `lib/services/`: 服务层，处理外部交互 (例如 `auth_service.dart`, `user_service.dart`, `leaderboard_service.dart`, `local_storage_service.dart`)。
*   `lib/state_management/`: Riverpod providers 和 notifiers。
*   `lib/ui_screens/`: 应用的主要屏幕。
*   `lib/widgets/`: 可重用的 UI 组件。
*   `lib/navigation/`: GoRouter 配置 (`app_router.dart`)。
*   `lib/l10n/`: 本地化文件 (`.arb` 文件)。
*   `lib/generated/`: 生成的本地化代码。
*   `lib/utils/`: 通用工具类。

### 2.2. 状态管理
*   **方案:** Riverpod
*   **理由:** 编译时安全、可测试性、灵活性、声明式、无需 `BuildContext` 访问 Provider，性能优化。
*   **实现:** Providers 定义在 `lib/state_management/providers/` 目录下。UI 组件通过 `ref.watch` 和 `ref.read` 与状态交互。

### 2.3. 导航策略
*   **方案:** GoRouter
*   **理由:** 声明式路由、深度链接、类型安全路由（通过代码生成）、易于处理复杂场景。
*   **实现:** 路由配置在 `lib/navigation/app_router.dart`。

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
    *   `callable_deleteUserData(data, context)`: 删除用户所有相关数据。
    *   Firestore 触发器 (例如，`onUserCreate`, `onScoreSubmit`) 可用于数据聚合或维护。

## 4. 数据流

(根据需要添加序列图或流程图，例如用户注册、游戏流程、排行榜提交流程)

## 5. 系统模式

参考 [`memory-bank/systemPatterns.md`](memory-bank/systemPatterns.md:1) 中定义的编码、架构和测试模式。

## 6. 部署与运维

(描述应用的构建、部署流程，以及监控和维护策略)

---
*上次更新: {{YYYY-MM-DD HH:MM:SS}} - 添加了用户名创建与管理流程的详细架构。*