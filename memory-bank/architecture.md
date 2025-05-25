# 应用架构

本文档描述了应用的关键架构组件和设计决策。

## 1. 概述

该应用是一个基于 Flutter 的 Yahtzee 风格游戏，后端采用 Firebase。

## 2. 前端架构 (Flutter)

### 2.1. UI 层

*   **屏幕 ([`lib/ui_screens/`](lib/ui_screens/)):** 包含应用的主要用户界面，如 `SplashScreen`、`HomeScreen`、`GameScreen`、`UsernameSetupScreen` 等。
*   **小部件 ([`lib/widgets/`](lib/widgets/)):** 可重用的 UI 组件。

### 2.2. 状态管理 ([`lib/state_management/providers/`](lib/state_management/providers/))

*   使用 **Riverpod** 进行状态管理。
*   **`anonymousSignInNotifierProvider` ([`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1)):** 负责处理应用启动时的匿名 Firebase 登录流程。其状态由 `SplashScreen` 监听。

### 2.3. 导航 ([`lib/navigation/`](lib/navigation/))

*   使用 **GoRouter** ([`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1)) 进行声明式路由。
*   包含 `redirect` 逻辑，根据认证状态和用户设置（如用户名是否已设置）管理导航流。

### 2.4. 服务层 ([`lib/services/`](lib/services/))

*   **`AuthService` ([`lib/services/auth_service.dart`](lib/services/auth_service.dart:1)):** 封装 Firebase Authentication 相关操作，如匿名登录。

## 3. 启动流程与 SplashScreen 循环问题分析

### 3.1. 相关组件

*   **`SplashScreen` ([`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:1)):**
    *   职责：在应用启动时执行匿名 Firebase 登录。
    *   行为：监听 `anonymousSignInNotifierProvider` 的状态。在检测到登录成功后，之前通过调用 `GoRouter.of(context).refresh()` ([`lib/ui_screens/splash_screen.dart:49`](lib/ui_screens/splash_screen.dart:49)) 来触发路由更新。
*   **`AppRouter` ([`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1)):**
    *   职责：定义路由和 `redirect` 逻辑。
    *   行为：`GoRouter.refresh()` 会强制 `AppRouter` 重新评估 `redirect` 逻辑。
*   **`anonymousSignInNotifierProvider` ([`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1)):**
    *   职责：管理匿名登录的状态（`isLoading`, `currentUser`, `errorMessage`）。

### 3.2. 问题描述：启动循环

应用启动时，`SplashScreen` 在匿名登录成功后调用 `GoRouter.refresh()`。如果 `AppRouter` 的 `redirect` 逻辑导致 `SplashScreen` 被重建，并且 `SplashScreen` 的监听器再次因检测到“已登录”状态而调用 `GoRouter.refresh()`，则会形成一个无限循环，导致应用卡在启动画面。

### 3.3. 推荐的架构调整（解决方案）

**核心变更：** 在 `SplashScreen` ([`lib/ui_screens/splash_screen.dart`](lib/ui_screens/splash_screen.dart:1)) 中，将登录成功后调用的 `GoRouter.of(context).refresh()` ([`lib/ui_screens/splash_screen.dart:49`](lib/ui_screens/splash_screen.dart:49)) 替换为明确的导航操作，例如 `context.go('/home')` 或 `context.replace('/home')`。

**理由：**

1.  **打破循环：** `SplashScreen` 在完成认证后，将导航控制权显式移交给 `AppRouter`。`AppRouter` 的 `redirect` 逻辑会基于新的目标路径和完整的应用状态（认证、用户名设置等）决定最终页面。
2.  **职责分离：** `SplashScreen` 专注于初始认证。后续路由决策由 `AppRouter` 统一处理。

**`AppRouter` (`redirect` 逻辑) 的健壮性要求：**

*   必须能够清晰处理用户从未登录到已登录（但可能未完成用户名设置）再到完全初始化的状态转换。
*   **未登录：** 导航至 `/splash` (如果不在该路径)。
*   **已登录，需设置用户名：** 导航至 `/username_setup` (如果不在该路径，或刚从 `/splash` 导航过来)。
*   **已登录，已设置用户名：** 导航至 `/home` (如果当前在 `/splash` 或 `/username_setup`)。
*   避免将已完成设置的用户重定向回 `/splash` 或 `/username_setup`。

**数据流 (解决后):**

1.  App Start -> `AppRouter` -> `/splash` (`SplashScreen` loads)
2.  `SplashScreen` triggers `anonymousSignInNotifierProvider.signInAnonymously()`
3.  `anonymousSignInNotifierProvider` updates state (isLoading=true)
4.  `SplashScreen` shows loading indicator
5.  `anonymousSignInNotifierProvider` updates state (isLoading=false, currentUser=User)
6.  `SplashScreen` listener detects `currentUser != null`
7.  `SplashScreen` calls `context.go('/home')`
8.  `AppRouter.redirect` logic is invoked with target `/home`:
    *   IF user needs username setup: `redirect` returns `/username_setup`
    *   ELSE (username setup complete): `redirect` returns `/home` (or `null` if already on a valid post-login page and target was `/home`)
9.  User is navigated to the correct screen (`/username_setup` or `/home`).

---
[2025-05-25 11:26:16] - 初始化 architecture.md 并记录 SplashScreen 循环问题的分析及推荐解决方案。