# 项目架构文档

## 概述

Simple Yacht 是一个基于 Flutter 的 Yahtzee 游戏应用，采用 Firebase 作为后端服务。

## 前端架构 (Flutter)

### 技术栈
- 状态管理: Riverpod
- 导航: GoRouter
- 本地化: Flutter Intl
- 本地存储: SharedPreferences

## 后端架构 (Firebase)

### Firebase 服务
- Authentication: 匿名认证 + 自定义令牌
- Firestore: 数据存储
- Cloud Functions: 服务端逻辑

## 关键功能流程

### 账号恢复流程
1. 用户输入引继码
2. 调用 Cloud Function 验证
3. 匿名登录 (如需要)
4. 数据迁移和同步
5. 跳转到主界面
