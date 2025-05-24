# Progress

This file tracks the project's progress using a task list format.
2025-05-23 02:56:35 - Log of updates made.

*

## Completed Tasks

* [2025-05-23 03:12:36] - Implemented core Yahtzee game logic in Dart: created `lib/core_logic/game_state.dart`, `lib/core_logic/dice_roller.dart`, and `lib/core_logic/scoring_rules.dart`.
* [2025-05-23 03:22:42] - Implemented basic Yahtzee UI with Flutter: created `lib/ui_screens/home_screen.dart`, `lib/ui_screens/game_screen.dart`, `lib/widgets/dice_widget.dart`, `lib/widgets/scoreboard_widget.dart`. Integrated GoRouter for navigation (`lib/navigation/app_router.dart`, updated `lib/main.dart`) and Riverpod for state management (`lib/state_management/providers/game_providers.dart`). UI connected to core game logic.
* [2025-05-23 03:31:51] - Implemented local storage for personal best score using `shared_preferences`. Created `lib/services/local_storage_service.dart`, updated `lib/state_management/providers/game_providers.dart` to save score, and updated `lib/ui_screens/home_screen.dart` to display score.
* [2025-05-23 03:33:11] - Added dice rolling animation to `lib/widgets/dice_widget.dart`.
* [2025-05-23 03:36:35] - Refined scoreboard UI and interactions in `lib/widgets/scoreboard_widget.dart`. Added `yahtzeeBonusCount` to `lib/core_logic/game_state.dart` and `yahtzeeBonusScoreProvider` to `lib/state_management/providers/game_providers.dart` for correct Yahtzee bonus display.
* [2025-05-23 04:39:16] - Fixed various single-player mode UI/logic issues: dice re-rolling on score selection, dice animation on hold toggle, dice animation for same-value rolls, and dice orientation after animation. This involved adding `rollId` to `GameState` and `GameStateNotifier`, and refactoring `DiceWidget` animation logic.
* [2025-05-23 08:19:30] - Reversed dice selection logic to "select to discard" instead of "select to keep". Updated UI in `lib/widgets/dice_widget.dart` (red border, 'X' icon for dice to be discarded) and core logic in `lib/core_logic/game_state.dart`. Adjusted dice animation logic accordingly. Fixed a subsequent bug where automatic rolls (new game/turn) were not occurring by updating `_performInitialRoll()` in `lib/core_logic/game_state.dart` [2025-05-23 08:22:59]. Added feature to clear all dice discard selections after a manual roll [2025-05-23 08:28:16]. Restored dice rolling animation by introducing `RollEvent` to track dice roll details and updating animation triggers in `DiceWidget` [2025-05-23 08:38:42].
* [2025-05-23 04:39:16] - Single-player mode polishing and bug fixes completed.
* [2025-05-23 06:03:58] - Implemented internationalization (i18n) with English and Chinese language support, including language switching via settings.
* [2025-05-23 08:08:52] - Implemented "Continue Game" button logic on home screen and updated game screen exit button with confirmation dialog.
* [2025-05-23 08:12:26] - Corrected "Continue Game" button behavior after exiting a game by ensuring `isGameInProgress` is reset.
* [2025-05-23 08:51:44] - Updated German, Spanish, Japanese, Russian, and French localization files with new translations for "Continue Game" and "Exit Game Confirmation" features.
* [2025-05-24 11:03:24] - **Architecture Defined:** System architecture for game over UI, leaderboard, username setup, and third-party login removal has been defined.
* [2025-05-24 12:27:09] - **Feature Implementation Complete (Game Over, Leaderboard, Username Setup, Login Removal):**
    * Implemented Game Over UI: Created `GameOverDialog` ([`lib/widgets/game_over_dialog.dart`](lib/widgets/game_over_dialog.dart:1)) and integrated into `GameScreen` ([`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1)). Ensured game reset logic in `GameState` ([`lib/core_logic/game_state.dart`](lib/core_logic/game_state.dart:1)) and `GameStateNotifier` ([`lib/state_management/providers/game_providers.dart`](lib/state_management/providers/game_providers.dart:1)) is correct.
    * Implemented Leaderboard: Created `ScoreEntry` ([`lib/core_logic/score_entry.dart`](lib/core_logic/score_entry.dart:1)), `LeaderboardService` ([`lib/services/leaderboard_service.dart`](lib/services/leaderboard_service.dart:1)), `leaderboard_providers.dart` ([`lib/state_management/providers/leaderboard_providers.dart`](lib/state_management/providers/leaderboard_providers.dart:1)), and `LeaderboardScreen` ([`lib/ui_screens/leaderboard_screen.dart`](lib/ui_screens/leaderboard_screen.dart:1)). Updated `LocalStorageService` ([`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart:1)) for leaderboard persistence. Added navigation in `AppRouter` ([`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1)) and `HomeScreen` ([`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1)).
    * Implemented First User Launch (Username Setup): Created `UserService` ([`lib/services/user_service.dart`](lib/services/user_service.dart:1)), `user_providers.dart` ([`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1)), and `UsernameSetupScreen` ([`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1)). Updated `LocalStorageService` for username persistence. Updated `AppRouter` and `main.dart` ([`lib/main.dart`](lib/main.dart:1)) for initial routing logic.
    * Removed Third-Party Login: Verified no existing third-party login UI, services, or dependencies to remove.

* [{{TIMESTAMP}}] - Skipped unit and widget tests for GameOverDialog, Leaderboard, and Username Setup features as per user instruction.
* [2025-05-24 13:22:42] - **UI Text Update Complete:** Changed home screen high score display text from "Leaderboard" to "High Score" (and translations). Updated all `.arb` files ([`lib/l10n/app_en.arb`](lib/l10n/app_en.arb) etc.), ran `flutter gen-l10n`, and modified [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart).
* [2025-05-24 13:34:44] - **Feature Implementation Complete (Display Personal Best Score):**
   * Updated [`lib/services/leaderboard_service.dart`](lib/services/leaderboard_service.dart) with `getPersonalBestScore` method.
   * Created [`lib/state_management/providers/personal_best_score_provider.dart`](lib/state_management/providers/personal_best_score_provider.dart).
   * Updated [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart) to display the personal best score, including score value and timestamp (formatted using `intl`).
   * Added new localization keys (`yourPersonalBestScoreLabel`, `noPersonalBestScore`, `scoreLabel`, `dateTimeLabel`) to all `.arb` files and regenerated localization files.
   * Verified `intl` package is in [`pubspec.yaml`](pubspec.yaml).
## Current Tasks

* [2025-05-24 12:48:54] - Implemented fix for "Continue Game" button incorrectly shown for new users:
    * Modified [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1) to reset game state via `gameStateProvider.notifier.setToInitialState()` after username setup.
    * Updated [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) to use a more robust condition (`isGameInProgress && (currentRound > 1 || (currentRound == 1 && rollsLeft < 2) || scores.values.any((s) => s != null))`) for showing the "Continue Game" button.
* [2025-05-24 12:48:54] - Implemented enhancement to display current username on the application home screen:
    * Updated [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) to fetch and display the username from `usernameProvider` in the AppBar, including handling for loading (username is null) and empty states.
(No active coding tasks from this request.)
* [2025-05-24 13:38:45] - **架构审查完成:** 审查并批准了在主屏幕右上角使用 `Stack` 和 `Positioned` 显示用户名的伪代码。

* [2025-05-24 13:07:00] - **规范已定义并通过审查:** 修复“游戏结束后排行榜未显示成绩”的问题。解决方案涉及修改 [`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1) 以在游戏结束时保存分数到排行榜。
## Next Steps

* [2025-05-24 12:43:48] - **Architecture Definition:** Define architecture for "Continue Game" button bug fix and "Display Username on Home Screen" enhancement. (This task)
* Implement fix for "Continue Game" button incorrectly shown for new users (see [`memory-bank/decisionLog.md`](memory-bank/decisionLog.md) and [`memory-bank/architecture.md`](memory-bank/architecture.md)).
* Implement enhancement to display current username on the application home screen (see [`memory-bank/decisionLog.md`](memory-bank/decisionLog.md:1) and [`memory-bank/architecture.md`](memory-bank/architecture.md:1)).
* Implement Firebase backend and online features (Authentication, Firestore for game state/leaderboard).
* Integrate frontend with Firebase services.
* [2025-05-24 13:09:09] - **Bug Fix Complete:** Fixed issue "Game Over Leaderboard Not Showing Score". Modified [`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1) to save the user's score to the leaderboard and refresh leaderboard data when the game ends.
* [2025-05-24 13:41:44] - **Feature Implementation Complete (Display Username on Home Screen - Top Right):** Implemented username display in the top-right corner of the home screen using `Stack`, `Positioned`, and `Chip` widgets, following the approved pseudocode. This involved creating a new `usernameAsyncProvider` in [`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1) to provide an `AsyncValue` and updating [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) to consume this provider and handle loading/data/error states with `.when()`.