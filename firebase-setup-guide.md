# Firebase 设置与配置指南

## 1. 简介

Firebase 为本项目提供后端服务，包括用户认证、数据存储 (Cloud Firestore) 以及云函数 (Cloud Functions) 用于执行后端逻辑。本指南将引导您完成 Firebase 项目的设置和配置。

## 2. 前提条件

*   **Firebase 项目**：您需要一个已创建的 Firebase 项目。如果您还没有，请访问 [Firebase 控制台](https://console.firebase.google.com/) 创建一个新项目。
*   **Node.js 和 npm/yarn**：用于 Firebase CLI 和 Cloud Functions 开发。
*   **Firebase CLI**：确保已安装并登录。
*   **Flutter 开发环境**：用于 Flutter 应用集成。

## 3. Firebase 控制台设置步骤

### 3.1 Authentication (认证)

1.  在 Firebase 控制台，导航到您的项目。
2.  在左侧菜单中，选择 “Authentication”。
3.  点击 “Sign-in method” 标签页。
4.  找到并启用 “匿名登录 (Anonymous)” 提供商。点击铅笔图标，切换启用开关，然后保存。

### 3.2 Cloud Firestore (数据库)

1.  在 Firebase 控制台，导航到您的项目。
2.  在左侧菜单中，选择 “Cloud Firestore”。
3.  点击 “创建数据库”。
4.  **选择模式**：选择 “**Native 模式 (Native mode)**”。
5.  **选择位置**：选择一个离您的用户最近的 Firestore 位置。
6.  **安全规则**：
    *   初始设置时，您可以选择 “**以测试模式开始 (Start in test mode)**”，这将允许在开发阶段进行读写操作。
        ```
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            match /{document=**} {
              allow read, write: if request.time < timestamp.date(2025, 12, 31); // 示例：允许到特定日期
            }
          }
        }
        ```
    *   **重要提示**：以上规则仅用于初始开发。生产环境中，您**必须**根据 [`memory-bank/architecture.md`](memory-bank/architecture.md:1) 中定义的 Firestore 安全规则进行细化配置，以确保数据安全。
7.  **集合说明**：
    *   `users`：此集合用于存储用户信息。其具体结构和用途详见 [`memory-bank/architecture.md`](memory-bank/architecture.md:1)。
    *   `leaderboards`：此集合用于存储排行榜数据。其具体结构和用途详见 [`memory-bank/architecture.md`](memory-bank/architecture.md:1)。
    本指南不详述这些集合的内部结构。

### 3.3 Cloud Functions (云函数)

1.  **初始化 Cloud Functions**:
    *   在您的项目根目录下（或您希望存放 `functions` 目录的位置），打开终端并运行 Firebase CLI 命令：
        ```bash
        firebase init functions
        ```
    *   当提示时：
        *   选择 “Use an existing project” 并选中您当前的 Firebase 项目。
        *   选择 “JavaScript” 作为编写函数的语言。
        *   选择 “Yes” 以使用 ESLint 捕获可能的错误和强制执行样式。
        *   选择 “Yes” 以通过 npm 安装依赖项。
    *   这将在您的项目中创建一个 `functions` 目录。

2.  **Node.js 版本**:
    *   Firebase Functions 通常有推荐的 Node.js 版本。请查阅 Firebase 官方文档以获取最新的推荐版本，并在 `functions/package.json` 文件中相应地设置 `engines` 字段。例如：
        ```json
        {
          "name": "functions",
          "scripts": {
            // ...
          },
          "engines": {
            "node": "18" // 或 Firebase 推荐的其他版本
          },
          "main": "index.js",
          "dependencies": {
            // ...
          },
          "devDependencies": {
            // ...
          }
        }
        ```

3.  **部署函数**:
    *   项目中定义的云函数位于 [`functions/index.js`](functions/index.js:1)。主要函数包括：
        *   `generateCustomAuthToken`
        *   `deleteUserData`
    *   要部署这些函数，请在终端中导航到 `functions` 目录，并运行：
        ```bash
        cd functions
        firebase deploy --only functions
        ```
    *   确保您的 [`functions/index.js`](functions/index.js:1) 文件包含了这些函数的导出。

## 4. Firebase CLI (命令行工具)

*   **安装**：如果您尚未安装 Firebase CLI，请按照官方指南进行安装：[Install the Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
*   **登录**：运行以下命令以登录您的 Firebase 账户：
    ```bash
    firebase login
    ```
*   **初始化项目 (firebase init)**：此命令用于在您的本地项目中初始化 Firebase 功能（如 Firestore, Functions, Hosting 等）。我们已在 Cloud Functions 部分使用过 `firebase init functions`。
*   **部署 (firebase deploy)**：此命令用于将您的应用或函数部署到 Firebase。例如，`firebase deploy --only functions` 用于仅部署云函数。

## 5. 将 Firebase 添加到 Flutter 应用

1.  **使用 FlutterFire CLI**：集成 Firebase 到 Flutter 项目的最推荐方法是使用 FlutterFire CLI。
2.  **安装 FlutterFire CLI** (如果尚未安装):
    ```bash
    dart pub global activate flutterfire_cli
    ```
3.  **配置项目**：在您的 Flutter 项目根目录下运行：
    ```bash
    flutterfire configure
    ```
    此命令将引导您选择 Firebase 项目，并为支持的平台（Android, iOS, Web, macOS）自动生成必要的 Firebase 配置文件。
4.  **添加依赖**：根据您需要使用的 Firebase 服务，在 `pubspec.yaml` 文件中添加相应的 FlutterFire 插件依赖（例如 `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_functions`）。
    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      firebase_core: ^latest_version # 替换为最新版本
      firebase_auth: ^latest_version
      cloud_firestore: ^latest_version
      firebase_functions: ^latest_version
      # ... 其他依赖
    ```
    然后运行 `flutter pub get`。
5.  **初始化 Firebase**：在您的 `lib/main.dart` 文件中，确保在应用启动时初始化 Firebase：
    ```dart
    import 'package:firebase_core/firebase_core.dart';
    import 'firebase_options.dart'; // 由 flutterfire configure 生成

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(MyApp());
    }
    ```
6.  **详细指南**：有关将 Firebase 集成到 Flutter 的完整和最新说明，请参阅官方 FlutterFire 文档：[FlutterFire Overview](https://firebase.flutter.dev/docs/overview)。