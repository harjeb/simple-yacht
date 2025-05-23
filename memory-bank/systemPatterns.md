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
*   

## Testing Patterns

*