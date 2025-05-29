# 架构文档

本文档概述了 Simple Yacht 应用的关键架构组件和设计决策。

## 核心技术栈

-   **前端:** Flutter
-   **后端:** Firebase
    -   Firebase Authentication: 用户认证 (匿名)
    -   Cloud Firestore: 主要数据存储 (用户信息、游戏状态、排行榜)
    -   Firebase Realtime Database: 实时数据同步 (在线状态)
    -   Cloud Functions: 服务端逻辑 (例如，安全敏感操作、复杂查询)

## 主要模块

### 1. 用户认证 ([`lib/services/auth_service.dart`](lib/services/auth_service.dart:1))
    - 负责用户匿名登录和会话管理。
    - 与 Firebase Authentication 集成。

### 2. 数据服务
    - **FirestoreService (隐式，通过各具体服务实现)**: 封装与 Cloud Firestore 的交互。
    - **[`PresenceService`](lib/services/presence_service.dart:1):** 管理用户在线状态和全局在线计数。

### 3. 游戏逻辑 ([`lib/core_logic/`](lib/core_logic/))
    - 包含 Yahtzee 游戏的核心规则、计分、回合管理等。

### 4. 状态管理 (Riverpod)
    - 应用广泛使用 Riverpod 进行状态管理，提供响应式的数据流和依赖注入。
    - Providers 定义在 [`lib/state_management/providers/`](lib/state_management/providers/) 目录下。

### 5. UI 层 ([`lib/ui_screens/`](lib/ui_screens/) 和 [`lib/widgets/`](lib/widgets/))
    - 使用 Flutter Material Design 组件构建。
    - 遵循响应式设计原则。

## 在线状态和实时 UI 更新架构 (2025-05-29)

此架构旨在解决数据库在线人数异常计数和 UI 界面不显示数据库实时数据的问题。

### 1. Firebase Realtime Database (RTDB) 结构

-   **/online_users/{userId}**: `(Boolean/Timestamp)`
    -   **用途**: 标记单个用户的在线状态。
    -   **规则**: 用户只能写入自己的状态 (`auth.uid == $userId`)。
-   **/online_users_count**: `(Integer)`
    -   **用途**: 存储全局在线用户总数。
    -   **规则**: 允许认证用户通过事务修改 (`auth != null`)。

### 2. `PresenceService` ([`lib/services/presence_service.dart`](lib/services/presence_service.dart:1))

-   **核心职责**:
    -   管理用户连接/断开连接时的 RTDB 更新。
    -   确保在线计数的幂等性和准确性。
    -   提供在线玩家数量的实时数据流。
-   **关键方法**:
    -   `_goOnline(String userId)`:
        1.  检查 RTDB 中用户是否已在线。
        2.  若未在线，则更新 `/online_users/{userId}` 为 `true`，并通过事务原子性增加 `/online_users_count`。
        3.  设置 `onDisconnect().remove()` on `/online_users/{userId}`。
        4.  设置 `onDisconnect().set(ServerValue.increment(-1))` on `/online_users_count`。
        5.  若已在线，则仅重新设置 `onDisconnect` 钩子。
    -   `_goOffline(String userId)`:
        1.  检查 RTDB 中用户是否在线。
        2.  若在线，则移除 `/online_users/{userId}`，并通过事务原子性减少 `/online_users_count`。
    -   `getOnlinePlayersCountStream() -> Stream<AsyncValue<int>>`:
        -   监听 `/online_users_count` 的变化。
        -   返回一个包含加载、数据、错误状态的流。
-   **集成**:
    -   监听 `FirebaseAuth.instance.authStateChanges()` 以自动调用上线/下线逻辑。
    -   可选地与 Flutter 应用生命周期 (`WidgetsBindingObserver`) 集成。
    -   构造函数接受可选的 `FirebaseDatabase` 实例以支持测试。

### 3. UI 更新机制

-   **Riverpod Provider**:
    -   `onlinePlayersCountProvider = StreamProvider.autoDispose<AsyncValue<int>>`: 暴露来自 `PresenceService` 的在线数量流。
-   **UI Widgets**:
    -   使用 `ConsumerWidget` 或 `ConsumerStatefulWidget`。
    -   通过 `ref.watch(onlinePlayersCountProvider)` 订阅数据。
    -   使用 `AsyncValue.when()` 处理加载、数据和错误状态，实时更新 UI。

### 4. 架构图

```mermaid
graph TD
    subgraph Firebase Realtime Database
        RTDB_USER["/online_users/{userId} (Boolean/Timestamp)"]
        RTDB_COUNT["/online_users_count (Integer)"]
    end

    subgraph Flutter Application
        Auth[AuthService] --> AuthState{User Auth State}
        AuthState -- Authenticated --> PresenceSvc[PresenceService]
        AuthState -- Unauthenticated --> PresenceSvc

        PresenceSvc -- Manages --> RTDB_USER
        PresenceSvc -- Manages (Transactions, onDisconnect) --> RTDB_COUNT
        PresenceSvc -- Stream<AsyncValue<int>> --> RiverpodProvider[Riverpod: onlinePlayersCountProvider]
        RiverpodProvider -- ref.watch() --> UI[UI Widgets (e.g., MultiplayerLobbyScreen)]
        UI -- Displays --> OnlineCountDisplay[Online Player Count]

        AppLifecycleObs[AppLifecycleObserver] --> PresenceSvc
        DBConnState[DBConnectionStateMonitor] --> PresenceSvc
    end

    RTDB_USER -. onDisconnect .-> RTDB_COUNT (decrement)
    RTDB_USER -. onDisconnect .-> RTDB_USER (remove)

    classDef firebase fill:#FFCA28,stroke:#000,stroke-width:2px;
    class RTDB_USER,RTDB_COUNT firebase;
    classDef flutter fill:#40C4FF,stroke:#000,stroke-width:2px;
    class Auth,AuthState,PresenceSvc,RiverpodProvider,UI,OnlineCountDisplay,AppLifecycleObs,DBConnState flutter;
```

此方案确保了在线状态管理的鲁棒性，并通过响应式数据流将实时信息准确地传递到用户界面。
