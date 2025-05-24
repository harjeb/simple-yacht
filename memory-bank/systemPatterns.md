# System Patterns *Optional*

This file documents recurring patterns and standards used in the project.
It is optional, but recommended to be updated as the project evolves.
2025-05-23 02:56:51 - Log of updates made.

*

## Coding Patterns

[2025-05-23 03:08:49] - **Flutter 目录结构:** 采用模块化的目录结构，将核心逻辑、模型、服务、UI 屏幕、小部件、工具和导航分开。详细结构参见 `memory-bank/architecture.md#21-关键模块目录`。
*   

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

## Testing Patterns

*