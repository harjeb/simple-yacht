# 架构文档

## 在线用户计数器解决方案

### 1. 概述

本文档定义了用于准确跟踪和显示在线用户数量的系统架构。该解决方案旨在解决先前计数器不准确的问题，确保每个唯一用户只被计数一次，无论其登录次数多少。

### 2. 架构图 (Mermaid)

```mermaid
graph TD
    subgraph Firebase Realtime Database
        F_OnlineUsers["/online_users/{userId} (boolean)"]
        F_OnlineCount["/online_users_count (integer)"]
    end

    subgraph Flutter Application
        AuthService["AuthService ([`lib/services/auth_service.dart`](lib/services/auth_service.dart:0))"]
        NewPresenceService["PresenceService ([`lib/services/presence_service.dart`](lib/services/presence_service.dart:0)) - Enhanced"]
        RiverpodProvider["Riverpod Providers (presenceServiceProvider, onlinePlayersCountProvider)"]
        UI_Lobby["MultiplayerLobbyScreen ([`lib/ui_screens/multiplayer_lobby_screen.dart`](lib/ui_screens/multiplayer_lobby_screen.dart:0))"]
        OldOnlinePresenceService["~~OnlinePresenceService ([`lib/services/online_presence_service.dart`](lib/services/online_presence_service.dart:0))~~ - To be DEPRECATED"]
    end

    AuthService -- authStateChanges --> NewPresenceService
    NewPresenceService -- Reads/Writes --> F_OnlineUsers
    NewPresenceService -- Transactions/onDisconnect --> F_OnlineCount
    
    RiverpodProvider -- Provides --> NewPresenceService
    RiverpodProvider -- Provides Stream --> UI_Lobby
    UI_Lobby -- Displays Count from --> RiverpodProvider

    NewPresenceService -.-> AuthService # Reads currentUser

    OldOnlinePresenceService -.-> F_OnlineUsers # Potential Conflict
    OldOnlinePresenceService -.-> F_OnlineCount # Potential Conflict

    style F_OnlineUsers fill:#f9f,stroke:#333,stroke-width:2px
    style F_OnlineCount fill:#f9f,stroke:#333,stroke-width:2px
    style AuthService fill:#ccf,stroke:#333,stroke-width:2px
    style NewPresenceService fill:#cfc,stroke:#333,stroke-width:2px
    style OldOnlinePresenceService fill:#fcc,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5
    style RiverpodProvider fill:#ffc,stroke:#333,stroke-width:2px
    style UI_Lobby fill:#ddf,stroke:#333,stroke-width:2px
```

*Diagram Note: `OnlinePresenceService` is marked for deprecation due to identified conflicts.*

### 3. 组件说明

#### 3.1. `AuthService` ([`lib/services/auth_service.dart`](lib/services/auth_service.dart:0))
*   **职责**: 处理用户认证（登录、登出、认证状态变更）。
*   **交互**: 其 `authStateChanges` 流是 `PresenceService` 的主要触发器。

#### 3.2. `PresenceService` ([`lib/services/presence_service.dart`](lib/services/presence_service.dart:0)) - 核心增强
*   **职责**:
    *   监听认证状态变化。
    *   管理单个用户的在线状态 (`/online_users/{userId}`)。
    *   通过原子事务和 `onDisconnect`处理程序更新全局在线用户计数 (`/online_users_count`)。
    *   提供一个流 (`getOnlinePlayersCountStream`) 以便 UI 实时显示在线数量。
*   **关键特性**:
    *   **重入保护**: 使用 `_isProcessingAuthStateChange` 标志防止 `_onAuthStateChanged` 的并发执行。
    *   **精细化状态处理**: `_handleAuthStateChanged` 方法将仔细处理用户登录、登出和切换的各种场景。
    *   **参数化下线**: `_goOffline` 方法将接受 `userIdToMarkOffline` 和 `specificUserStatusRef`，以确保在用户切换或服务 `dispose` 时操作的准确性。
    *   **`onDisconnect` 管理**: 正确设置 Firebase `onDisconnect` 事件，以便在客户端意外断开连接时自动清理用户状态和调整计数器。
*   **生命周期**: 通过 Riverpod provider 管理。其生命周期应与用户会话对齐，可能使用 `autoDispose` 并在 `dispose` 方法中妥善处理下线逻辑。

#### 3.3. `OnlinePresenceService` ([`lib/services/online_presence_service.dart`](lib/services/online_presence_service.dart:0))
*   **状态**: **待弃用**。
*   **原因**: 该服务在 [`lib/main.dart`](lib/main.dart:37) 中被实例化，并可能操作与新的 `PresenceService` 相同的 Firebase Realtime Database 路径，导致计数冲突和不准确。其功能将被整合或被新的 `PresenceService` 完全取代。

#### 3.4. Firebase Realtime Database
*   **`/online_users/{userId}` (Boolean/Timestamp)**: 存储各个用户的在线状态。
    *   写入: 用户登录时设置为 `true`。
    *   移除: 用户登出或通过 `onDisconnect` 自动移除。
*   **`/online_users_count` (Integer)**: 存储当前在线的唯一用户总数。
    *   更新: 通过 `PresenceService` 中的 Firebase 事务 (`ServerValue.increment(1)` 或 `ServerValue.increment(-1)`) 进行原子更新。
    *   `onDisconnect`: 当用户连接意外断开时，通过 `onDisconnect().set(ServerValue.increment(-1))` 自动递减。

#### 3.5. Riverpod Providers
*   **`presenceServiceProvider`**: 提供 `PresenceService` 的实例。
*   **`onlinePlayersCountProvider`**: 一个 `StreamProvider`，暴露从 `PresenceService.getOnlinePlayersCountStream()` 获取的在线用户数量流，供 UI 消费。

#### 3.6. UI (`MultiplayerLobbyScreen` - [`lib/ui_screens/multiplayer_lobby_screen.dart`](lib/ui_screens/multiplayer_lobby_screen.dart:0))
*   **职责**: 显示实时在线用户数量。
*   **交互**: 消费 `onlinePlayersCountProvider` 并使用 `AsyncValue.when` 来处理加载、数据和错误状态。

### 4. 解决的问题和策略

*   **H1: `_onAuthStateChanged` 逻辑缺陷**: 通过引入 `_isProcessingAuthStateChange` 标志和细化 `_handleAuthStateChanged` 中的状态转换逻辑来解决。
*   **H2: `PresenceService` 实例生命周期问题**: 通过 Riverpod provider 进行管理，确保其生命周期与用户会话一致，并在 `dispose` 时正确清理。
*   **H3: `onDisconnect` 处理不及时或失败**: 依赖 Firebase `onDisconnect` 机制的稳健性，并在 `_goOnline` 中确保其正确配置。
*   **H4: 另一个服务 (`OnlinePresenceService`) 的干扰**: 确认 [`lib/services/online_presence_service.dart`](lib/services/online_presence_service.dart:0) 的存在和使用。该服务将被弃用，其在 [`lib/main.dart`](lib/main.dart:37) 中的实例化将被移除，以避免与新的 `PresenceService` 冲突。

### 5. 数据流

1.  用户通过 `AuthService` 登录/登出。
2.  `AuthService` 发出 `authStateChanges` 事件。
3.  `PresenceService` 监听到事件，并通过 `_onAuthStateChanged_wrapper` -> `_handleAuthStateChanged` 处理。
4.  **用户上线**:
    *   `PresenceService` 检查用户是否已标记在线。
    *   如果未在线，则在 `/online_users/{userId}` 设置为 `true`。
    *   通过事务递增 `/online_users_count`。
    *   设置 `onDisconnect` 处理器以在连接丢失时移除用户条目并递减计数。
5.  **用户下线**:
    *   `PresenceService` 移除 `/online_users/{userId}`。
    *   通过事务递减 `/online_users_count`。
    *   （如果适用）取消 `onDisconnect` 处理器。
6.  `PresenceService` 通过 `getOnlinePlayersCountStream` 暴露 `/online_users_count` 的实时流。
7.  `onlinePlayersCountProvider` 将此流提供给 UI。
8.  `MultiplayerLobbyScreen` 订阅 provider 并显示计数。

### 6. 关键决策点

*   **原子性**: 认证状态变更处理的原子性由 `_isProcessingAuthStateChange` 保证。数据库计数的原子性由 Firebase 事务保证。
*   **幂等性**: `_goOnline` 和 `_goOffline` 操作应设计为幂等的，即多次调用同一状态不会产生意外的副作用（例如，多次将同一用户标记为在线不会多次增加计数器）。
*   **弃用冲突服务**: 必须移除或整合 [`lib/services/online_presence_service.dart`](lib/services/online_presence_service.dart:0) 以确保系统行为的一致性。

## 联机对战：匹配与房间管理

本节详细介绍联机对战中玩家匹配和游戏房间管理的系统架构，旨在解决用户报告的匹配失败和无法加入房间的问题。

### 1. 架构图 (Mermaid)

```mermaid
graph TD
    subgraph Firebase Firestore
    