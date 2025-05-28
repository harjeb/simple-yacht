# 开发者说明：清空本地数据功能

## 功能概述

“清空本地数据”功能允许用户从其设备中删除所有本地存储的账户信息，而不会影响服务器上的实际账户。此操作会登出用户，重置应用状态，并将用户导航至初始屏幕。用户之后仍可使用有效的引继码恢复账户。

## 技术实现

该功能的实现主要涉及以下组件：

1.  **本地存储服务 (`LocalStorageService`)**:
    *   文件路径: [`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart:1)
    *   关键变更: 添加了 `clearAllUserData()` 方法，负责清除所有存储在本地的用户相关数据。

2.  **服务提供者 (`Service Providers`)**:
    *   文件路径: [`lib/state_management/providers/service_providers.dart`](lib/state_management/providers/service_providers.dart:1)
    *   目的: 这个新文件用于管理和提供对各种服务的访问，包括 `LocalStorageService`。

3.  **设置屏幕 (`SettingsScreen`)**:
    *   文件路径: [`lib/ui_screens/settings_screen.dart`](lib/ui_screens/settings_screen.dart:1)
    *   关键变更:
        *   添加了一个新的按钮，标签为“清空此设备上的账户数据”（及其本地化版本）。
        *   实现了按钮的事件处理逻辑，包括调用 `LocalStorageService.clearAllUserData()`。
        *   在执行清除操作前，会显示一个确认对话框，向用户解释操作的后果。

4.  **本地化资源**:
    *   英文本地化文件: [`lib/l10n/app_en.arb`](lib/l10n/app_en.arb:1)
    *   中文本地化文件: [`lib/l10n/app_zh.arb`](lib/l10n/app_zh.arb:1)
    *   目的: 包含了新功能相关的UI文本（如按钮标签、确认对话框文本）的英文和中文翻译。

## 流程简述

1.  用户在 [`SettingsScreen`](lib/ui_screens/settings_screen.dart:1) 点击“清空此设备上的账户数据”按钮。
2.  系统显示一个确认对话框。
3.  用户确认后，调用 [`LocalStorageService`](lib/services/local_storage_service.dart:1) 中的 `clearAllUserData()` 方法。
4.  所有本地用户数据被清除。
5.  用户被登出，应用状态重置，并导航到初始屏幕。
## 问题排查：账户恢复后个人最高分未显示

**问题描述:**

用户通过引继码成功恢复账户后，其个人最高分未能正确显示在应用中。

**根本原因:**

此问题涉及两个层面：

1.  **Cloud Function (`recoverAccountByTransferCode`) 问题 (已修复):**
    *   最初，Cloud Function 在响应中未包含 `personalBestScore` 和 `personalBestScoreTimestamp` 字段。
    *   **修复:** Cloud Function 已更新，现在会从 Firestore 读取并返回这些字段。

2.  **客户端代码 (`_recoverAccount` 方法 - [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1)) 问题 (已修复):**
    *   客户端的 `_recoverAccount` 方法最初错误地期望 `personalBestScore` 是一个 Map 对象。
    *   然而，修复后的 Cloud Function 返回的是一个数字类型的 `personalBestScore`。
    *   此外，即使 Cloud Function 返回了正确的数据类型，客户端也未能将恢复的 `personalBestScore` 和 `personalBestScoreTimestamp` 正确保存到本地存储 ([`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart:1))。这导致后续的 Provider ([`personalBestScoreProvider`](lib/state_management/providers/personal_best_score_provider.dart:1)) 无法从本地获取到分数。

**解决方案:**

1.  **Cloud Function (`recoverAccountByTransferCode` - [`functions/index.js`](functions/index.js:1)):**
    *   已更新为从 Firestore (`originalUserData.gameData?.personalBestScore` 和 `originalUserData.gameData?.personalBestScoreTimestamp`) 读取用户的个人最高分和时间戳。
    *   确保这些值包含在返回给客户端的 `userData` 对象中，字段名分别为 `personalBestScore` 和 `personalBestScoreTimestamp`。

2.  **客户端代码 (`_recoverAccount` 方法 - [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1)):**
    *   更新了 `_recoverAccount` 方法以正确解析从 Cloud Function 返回的 `personalBestScore` (数字) 和 `personalBestScoreTimestamp` (时间戳对象)。
    *   在成功获取这些值后，会创建一个 `ScoreEntry` 对象。
    *   调用 `localStorageService.saveSpecificUserPersonalBest(recoveredUsername, scoreEntry)` 将此 `ScoreEntry` 保存到本地存储。
    *   在数据保存到本地存储后，刷新相关的 Provider (例如 `usernameProvider`，`personalBestScoreProvider`) 以确保 UI 更新。

**关键教训与最佳实践:**

*   **数据契约一致性:** 务必确保后端 (Cloud Functions) 和前端 (客户端代码) 之间对于数据结构和类型的定义保持严格一致。任何一方的更改都可能需要另一方进行相应的调整。
*   **显式数据持久化:** 在账户恢复等关键流程中，从后端获取的数据如果需要在本地持久化以供后续使用（例如，通过 Provider 读取），必须显式地调用相应的本地存储服务方法进行保存。不能仅仅依赖于 Provider 的刷新来自动获取和持久化数据。
*   **彻底测试:** 针对账户恢复等复杂流程，应进行端到端的测试，覆盖各种数据场景，以确保数据在整个链路中正确传递、处理和显示。
*   **详细日志:** 在关键的数据处理和状态更新节点添加详细日志，有助于快速定位和诊断类似问题。