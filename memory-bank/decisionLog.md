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