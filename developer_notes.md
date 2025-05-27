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