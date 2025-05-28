# 决策日志

记录项目中的关键架构和实现决策。

## 核心技术决策

### 状态管理
**[2025-05-23]** 选择 Riverpod 作为 Flutter 状态管理方案
- 编译时安全、可测试性强、无需 BuildContext 访问

### 导航系统
**[2025-05-23]** 采用 GoRouter 进行路由管理
- 声明式路由、深度链接支持、类型安全

### 后端架构
**[2025-05-24]** Firebase 后端集成
- Authentication: 匿名认证 + 自定义令牌
- Firestore: 用户数据、排行榜存储
- Cloud Functions: 安全敏感逻辑

## 关键问题修复

### 账号恢复功能
**[2025-05-27]** 修复账号恢复后最高分未显示
- Cloud Function 返回 personalBestScore 字段
- 客户端正确保存到本地存储
- 状态提供者刷新顺序优化

### 认证流程
**[2025-05-25]** 修复 Firebase 认证问题
- 应用启动时自动匿名登录
- 解决 Firestore 权限拒绝错误
- 优化用户名创建流程

### 游戏状态管理
**[2025-05-26]** 修复新游戏不显示画面
- GameState.initial() 工厂构造函数
- 游戏屏幕渲染逻辑优化
- 导航守卫添加

### 数据清理
**[2025-05-26]** 账号删除后状态清理
- 认证状态清除
- 本地数据清理
- Riverpod Provider 重置
- 强制导航到初始屏幕

## 安全决策

### Firestore 安全规则
**[2025-05-25]** 实施最小权限原则
- 用户只能访问自己的数据
- 排行榜写入权限控制
- 用户名唯一性通过 Cloud Function 保证

### 数据验证
**[2025-05-26]** 强化数据完整性
- 服务器端时间戳验证
- 用户名格式验证
- 分数范围限制

## 当前状态

- ✅ 核心游戏功能完整
- ✅ 账号恢复功能正常
- ✅ Firebase 集成稳定
- ✅ 安全规则完善
- 🔧 代码细节优化进行中 (84个问题)

---
### Decision (Debug)
[2025-05-28 10:09:00] - Bug Fix Strategy: Resolved Flutter localization build error by updating l10n.yaml, correcting import statements, and regenerating localization files.

**Rationale:**
The error logs indicated `AppLocalizations` was undefined and `package:flutter_gen/gen_l10n/app_localizations.dart` could not be resolved. This pointed to issues with localization file generation or incorrect import paths. The project name 'myapp' was confirmed, and the import path needed to reflect this. Adding `untranslated-messages-file` to `l10n.yaml` helps in tracking missing translations.

**Details:**
- Modified `l10n.yaml` to include `untranslated-messages-file: untranslated_messages.txt`.
- Updated import statements in `lib/ui_screens/home_screen.dart`, `lib/ui_screens/multiplayer_game_screen.dart`, `lib/widgets/scoreboard_widget.dart` from `package:flutter_gen/gen_l10n/app_localizations.dart` to `package:myapp/generated/app_localizations.dart`.
- Executed `flutter pub get`, `flutter gen-l10n`, `flutter clean`, and `flutter pub get` again.
