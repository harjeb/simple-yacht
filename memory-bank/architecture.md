# Architecture Document

## 1. Overview

This document outlines the software architecture for the Yahtzee-style game application. It details the core components, their interactions, data models, and key architectural decisions.

## 2. Core Components and Interactions

The system is composed of the following core components:

*   **`UIManager`**:
    *   **Responsibilities**: Manages game over UI, first-time username setup, leaderboard display, and removal of third-party login UI elements.
    *   **Interactions**: Communicates with `GameStateManager`, `ScoreManager`, `UserManager`, and `NavigationService`.
*   **`GameStateManager`** (Extends [`lib/core_logic/game_state.dart`](lib/core_logic/game_state.dart) & [`lib/state_management/providers/game_providers.dart`](lib/state_management/providers/game_providers.dart)):
    *   **Responsibilities**: Detects game end, triggers game over events, manages game reset.
    *   **Interactions**: Notifies `UIManager` and `ScoreManager` on game end; resets game state.
*   **`ScoreManager`** (New):
    *   **Responsibilities**: Receives final scores, associates scores with usernames, interacts with `StorageService` for persistence, maintains leaderboard logic (top 10).
    *   **Interactions**: Gets scores from `GameStateManager`, username from `UserManager`, uses `StorageService` for data, provides leaderboard data to `UIManager`.
*   **`UserManager`** (New):
    *   **Responsibilities**: Manages username setup and retrieval, interacts with `StorageService` for persistence, handles first-launch username input flow with `UIManager`.
    *   **Interactions**: Uses `StorageService` for username data, provides username to `ScoreManager`, collaborates with `UIManager` for setup.
*   **`StorageService`** (Extends [`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart)):
    *   **Responsibilities**: Provides persistence for leaderboard data and usernames using `shared_preferences`.
    *   **Interactions**: Called by `ScoreManager` and `UserManager`.
*   **`ThirdPartyLoginRemover`** (Refactoring Task):
    *   **Responsibilities**: Identifies and removes all code, dependencies, and UI related to third-party logins.

## 3. Data Models

*   **`ScoreEntry`**:
    *   `username: String`
    *   `score: int`
    *   `timestamp: DateTime` (Optional)
*   **`Leaderboard`**:
    *   `scores: List<ScoreEntry>` (Top 10, sorted by score)
*   **`User`**:
    *   `username: String`

## 4. Process Flows (Mermaid)

### 4.1. Game Over Flow
```mermaid
sequenceDiagram
    participant GS as GameStateManager
    participant UI as UIManager
    participant SM as ScoreManager
    participant USR as UserManager
    participant ST as StorageService

    GS->>UI: Game Over Event (with final score)
    UI->>USR: Get Current Username
    USR-->>UI: Return Username
    UI->>SM: Submit Score (username, final score)
    SM->>ST: Save Score Record (username, final score)
    ST-->>SM: Save Successful
    SM->>ST: Get Leaderboard Data
    ST-->>SM: Return Leaderboard Data (Top 10)
    SM-->>UI: Return Leaderboard Data
    UI->>UI: Display Game Over Popup (score, leaderboard, celebration)
    Note over UI: Includes "Reset Game" button
```

### 4.2. First User Launch Flow
```mermaid
sequenceDiagram
    participant App as Application
    participant USR as UserManager
    participant ST as StorageService
    participant UI as UIManager
    participant NAV as NavigationService

    App->>USR: App Start, Check Username
    USR->>ST: Attempt to Get Stored Username
    ST-->>USR: Return Username (or null)
    alt Username Does Not Exist (First Launch)
        USR->>UI: Notify Username Setup Needed
        UI->>NAV: Navigate to Username Setup Screen
        activate UI
        UI->>UI: Display Username Input Screen
        Note over UI: User inputs and submits username
        UI->>USR: User Submitted Username
        deactivate UI
        USR->>ST: Save Username
        ST-->>USR: Save Successful
        USR->>NAV: Navigate to Main Screen
    else Username Exists
        USR->>App: Username Set, Proceed with Normal Launch
    end
```

### 4.3. View Leaderboard Flow
```mermaid
sequenceDiagram
    participant UI as UIManager
    participant SM as ScoreManager
    participant ST as StorageService

    UI->>SM: Request Leaderboard Data
    SM->>ST: Get Leaderboard Data
    ST-->>SM: Return Leaderboard Data (Top 10)
    SM-->>UI: Return Leaderboard Data
    UI->>UI: Display Leaderboard Screen
```

## 5. Potential Impacts on Existing Code Structure

*   **[`lib/core_logic/game_state.dart`](lib/core_logic/game_state.dart)**: Add game end detection, event emission, and reset logic.
*   **[`lib/state_management/providers/game_providers.dart`](lib/state_management/providers/game_providers.dart)**: Update `GameStateNotifier`; potentially new providers for `ScoreManager`, `UserManager`.
*   **[`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart)**: Extend for `List<ScoreEntry>` and `String` (username) persistence via JSON serialization with `shared_preferences`.
*   **UI Screens** ([`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart), [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart), new screens):
    *   `GameScreen`: Integrate game over popup.
    *   `HomeScreen`: Add leaderboard entry point. Implement display of current username in the AppBar. Modify "Continue Game" button visibility logic to be more robust (check `isGameInProgress` AND `currentTurn > 0`).
    *   New Screens: `UsernameSetupScreen`, `LeaderboardScreen`.
    *   Remove third-party login UI.
*   **[`lib/navigation/app_router.dart`](lib/navigation/app_router.dart)**: Add routes for new screens; logic for initial navigation to `UsernameSetupScreen`. The `redirect` logic will include a call to reset `GameState` via `gameStateProvider.notifier.setToInitialState()` after new user setup is complete and before navigating to the home screen.
*   **[`lib/main.dart`](lib/main.dart)**: Initial username check for routing.
*   **`pubspec.yaml`**: Remove third-party login dependencies.
*   **Platform-Specific Configs (Android/iOS)**: Remove third-party login configurations.

## 6. Removal of Third-Party Login

This involves a thorough audit and removal of:
*   Any Firebase Authentication methods used for third-party providers.
*   Dependencies like `google_sign_in`, `flutter_facebook_auth`, etc.
*   UI elements (buttons, settings) related to these login methods.
*   Associated logic in view models, services, or providers.
*   Platform-specific configurations (e.g., `google-services.json` entries, `Info.plist` modifications, URL schemes) if solely for these providers.

2025-05-24 11:01:51 - Initial architecture document for game over, leaderboard, username setup, and third-party login removal.

2025-05-24 12:43:15 - Updated HomeScreen UI details for username display and "Continue Game" button logic. Updated AppRouter to include GameState reset after new user setup.