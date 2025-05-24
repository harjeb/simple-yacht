# Active Context

  This file tracks the project's current status, including recent changes, current goals, and open questions.
  2025-05-23 02:56:27 - Log of updates made.

*

## Current Focus

* [2025-05-24 12:28:15] - Core local features (Game Over, Leaderboard, Username Setup, Login Removal) implemented. Next: Implement Firebase backend and online features.
* [2025-05-24 12:40:17] - Generating specifications for: 1. Bug fix: "Continue Game" button incorrectly shown for new users. 2. Enhancement: Display username on home screen.
* [2025-05-24 12:44:07] - Defined architecture and updated Memory Bank for: 1. Bug fix: "Continue Game" button incorrectly shown for new users. 2. Enhancement: Display username on home screen.
* [{{TIMESTAMP}}] - TDD: Skipped unit and widget tests for GameOverDialog, Leaderboard, and Username Setup features as per user instruction.
* [2025-05-24 13:29:07] - Defining architecture and updating Memory Bank for displaying personal best score on the home screen.
* [2025-05-24 13:34:29] - Implemented feature to display personal best score on the home screen.
* [2025-05-24 13:38:37] - 审查了在主屏幕右上角使用 `Stack` 和 `Positioned` 显示用户名的伪代码架构。
## Recent Changes

* [2025-05-23 02:56:59] - Memory Bank initialized with core files.
* [2025-05-23 03:12:51] - Implemented core game logic (`game_state.dart`, `dice_roller.dart`, `scoring_rules.dart`).
* [2025-05-23 03:22:59] - Created UI screens: `home_screen.dart`, `game_screen.dart`.
* [2025-05-23 03:22:59] - Created UI widgets: `dice_widget.dart`, `scoreboard_widget.dart`.
* [2025-05-23 03:22:59] - Implemented navigation with GoRouter: `app_router.dart`, updated `main.dart`.
* [2025-05-23 03:22:59] - Implemented state management with Riverpod: `game_providers.dart`.
* [2025-05-23 03:22:59] - Connected UI to core game logic.
* [2025-05-23 03:31:51] - Added `shared_preferences` to `pubspec.yaml`.
* [2025-05-23 03:31:51] - Created `lib/services/local_storage_service.dart` for high score persistence.
* [2025-05-23 03:31:51] - Updated `lib/state_management/providers/game_providers.dart` to save high scores.
* [2025-05-23 03:31:51] - Updated `lib/ui_screens/home_screen.dart` to display high scores.
* [2025-05-23 03:33:11] - Updated `lib/widgets/dice_widget.dart` to include dice rolling animations.
* [2025-05-23 03:36:35] - Added `yahtzeeBonusCount` to `lib/core_logic/game_state.dart`.
* [2025-05-23 03:36:35] - Added `yahtzeeBonusScoreProvider` to `lib/state_management/providers/game_providers.dart`.
* [2025-05-23 03:36:35] - Refined UI and interactions in `lib/widgets/scoreboard_widget.dart`.
* [2025-05-23 04:39:16] - Fixed dice re-rolling issue in `lib/core_logic/game_state.dart`.
* [2025-05-23 04:39:16] - Added `rollId` to `lib/core_logic/game_state.dart` and `lib/state_management/providers/game_providers.dart`.
* [2025-05-23 04:39:16] - Refactored `lib/widgets/dice_widget.dart` to use `rollId` for improved animation control, fixing issues with animation on hold, same-value rolls, and final orientation.
* [2025-05-23 04:39:16] - Corrected `GameScreen` display by fixing routing in `lib/navigation/app_router.dart` and ensuring `ProviderScope` in `lib/main.dart`.
* [2025-05-23 05:06:22] - Implemented automatic first roll on game start and new turn in `lib/core_logic/game_state.dart` and `lib/state_management/providers/game_providers.dart`. Max manual rolls per turn is now 2.
* [2025-05-23 05:20:36] - Added an exit button to `lib/ui_screens/game_screen.dart`.
* [2025-05-23 06:03:58] - Configured `pubspec.yaml`, `l10n.yaml` for internationalization.
* [2025-05-23 06:03:58] - Created `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`.
* [2025-05-23 06:03:58] - Updated `lib/main.dart` for localization delegates and locale resolution.
* [2025-05-23 06:03:58] - Localized text in `lib/ui_screens/home_screen.dart`, `lib/ui_screens/game_screen.dart`, `lib/widgets/scoreboard_widget.dart`.
* [2025-05-23 06:03:58] - Created `lib/state_management/providers/locale_provider.dart` for managing app locale.
* [2025-05-23 06:03:58] - Created `lib/ui_screens/settings_screen.dart` with language switching UI.
* [2025-05-23 06:03:58] - Updated routing in `lib/navigation/app_router.dart` and `lib/ui_screens/home_screen.dart` for settings page.

* [2025-05-23 08:19:15] - Modified dice selection logic: players now select dice to discard (not keep). UI updated with red selection box and 'X' icon for discarded dice. Animation logic adjusted accordingly. Files changed: `lib/core_logic/game_state.dart`, `lib/widgets/dice_widget.dart`.
* [2025-05-23 08:22:59] - Fixed issue where automatic dice rolls (on new game/new turn) were not occurring after the dice selection logic change. Modified `_performInitialRoll()` in `lib/core_logic/game_state.dart` to directly set dice values and ensure `isHeld` is `false` for all dice, aligning with the new "select to discard" logic.
* [2025-05-23 08:28:16] - Implemented feature: After a manual dice roll (`Roll Dice` button), all dice selections (for discarding) are cleared. This was achieved by setting `die.isHeld = false` for all dice at the end of the `rollDice()` method in `lib/core_logic/game_state.dart`.
* [2025-05-23 08:38:42] - Fixed dice rolling animation. Replaced `rollId` with a `RollEvent` object (containing `id`, `rolledIndices`, `isInitialRoll`) in `GameState` and relevant providers. Updated `DiceWidget` to use `RollEvent` to correctly trigger animations for dice that were part of the roll. Files changed: `lib/core_logic/game_state.dart`, `lib/state_management/providers/game_providers.dart`, `lib/widgets/dice_widget.dart`.
* [2025-05-24 10:59:00] - Defined specifications and pseudocode for: game over UI with reset, enhanced local leaderboard (top 10 scores), mandatory username setup on first launch, and removal of all third-party login functionalities.
* [2025-05-24 11:03:53] - Completed system architecture design for game over UI, leaderboard, username setup, and third-party login removal. Updated relevant Memory Bank files ([`memory-bank/architecture.md`](memory-bank/architecture.md), [`memory-bank/decisionLog.md`](memory-bank/decisionLog.md), [`memory-bank/progress.md`](memory-bank/progress.md)).
* [2025-05-24 12:28:15] - Implemented core features: Game Over UI, local leaderboard (top 10 with username via `shared_preferences`), mandatory username setup on first launch, and verified removal of third-party login elements. Created/updated files: [`lib/widgets/game_over_dialog.dart`](lib/widgets/game_over_dialog.dart:1), [`lib/core_logic/score_entry.dart`](lib/core_logic/score_entry.dart:1), [`lib/services/local_storage_service.dart`](lib/services/local_storage_service.dart:1), [`lib/services/leaderboard_service.dart`](lib/services/leaderboard_service.dart:1), [`lib/state_management/providers/leaderboard_providers.dart`](lib/state_management/providers/leaderboard_providers.dart:1), [`lib/ui_screens/leaderboard_screen.dart`](lib/ui_screens/leaderboard_screen.dart:1), [`lib/services/user_service.dart`](lib/services/user_service.dart:1), [`lib/state_management/providers/user_providers.dart`](lib/state_management/providers/user_providers.dart:1), [`lib/ui_screens/username_setup_screen.dart`](lib/ui_screens/username_setup_screen.dart:1). Updated [`lib/ui_screens/game_screen.dart`](lib/ui_screens/game_screen.dart:1), [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1), [`lib/main.dart`](lib/main.dart:1), and relevant localization files.
* [2025-05-24 12:49:21] - Applied bug fix and enhancement:
    * **Bug Fix (Continue Game Button):** Modified [`lib/navigation/app_router.dart`](lib/navigation/app_router.dart:1) to call `setToInitialState()` on `gameStateProvider` after new user setup. Updated [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) "Continue Game" button visibility logic to `isGameInProgress && (currentRound > 1 || (currentRound == 1 && rollsLeft < 2) || scores.values.any((s) => s != null))`.
    * **Enhancement (Display Username):** Modified [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart:1) AppBar to display username from `usernameProvider`, with loading (username null) and empty string handling. Imported `GameState` class into `home_screen.dart`.
* [2025-05-24 13:22:42] - Updated home screen UI text for high score display from "Leaderboard" to "High Score" (or equivalent translations). This involved:
    * Adding new key `highScoreDisplay` to all `.arb` localization files ([`lib/l10n/app_en.arb`](lib/l10n/app_en.arb), [`lib/l10n/app_zh.arb`](lib/l10n/app_zh.arb), [`lib/l10n/app_de.arb`](lib/l10n/app_de.arb), [`lib/l10n/app_es.arb`](lib/l10n/app_es.arb), [`lib/l10n/app_fr.arb`](lib/l10n/app_fr.arb), [`lib/l10n/app_ja.arb`](lib/l10n/app_ja.arb), [`lib/l10n/app_ru.arb`](lib/l10n/app_ru.arb)).
    * Regenerating localization classes using `flutter gen-l10n`.
    * Updating the `Text` widget in [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart) to use `localizations.highScoreDisplay`.
## Open Questions/Issues

*
* [2025-05-23 08:08:27] - Updated home screen to show "Continue Game" button if a game is in progress. Updated game screen exit button to 'X' icon and added a confirmation dialog before exiting a game. Updated relevant localization files.
* [2025-05-23 08:12:11] - Fixed bug where "Continue Game" button was still shown after exiting a game. Implemented `setToInitialState` in `GameStateNotifier` to correctly reset `isGameInProgress` to false when exiting.
* [2025-05-23 08:51:29] - Updated localization files (de, es, ja, ru, fr) with new entries for 'continueGame' and 'exitGameConfirmation'.
* [2025-05-24 13:07:00] - 审查并确认了“游戏结束后排行榜未显示成绩”问题的规范和伪代码。解决方案与现有架构一致，准备实施。
* [2025-05-24 13:08:59] - Modified `lib/ui_screens/game_screen.dart` to save score to leaderboard when game is over. Added calls to `leaderboardService.addScore` and `ref.refresh(leaderboardProvider)` within the `isGameOverProvider` listener.
* [2025-05-24 13:34:29] - Updated [`lib/services/leaderboard_service.dart`](lib/services/leaderboard_service.dart) to add `getPersonalBestScore` method.
* [2025-05-24 13:34:29] - Created [`lib/state_management/providers/personal_best_score_provider.dart`](lib/state_management/providers/personal_best_score_provider.dart) for personal best score.
* [2025-05-24 13:34:29] - Updated [`lib/ui_screens/home_screen.dart`](lib/ui_screens/home_screen.dart) to display personal best score using the new provider and `intl` for date formatting.
* [2025-05-24 13:34:29] - Added new localization keys (`yourPersonalBestScoreLabel`, `noPersonalBestScore`, `scoreLabel`, `dateTimeLabel`) to all `.arb` files ([`lib/l10n/app_en.arb`](lib/l10n/app_en.arb), [`lib/l10n/app_zh.arb`](lib/l10n/app_zh.arb), [`lib/l10n/app_de.arb`](lib/l10n/app_de.arb), [`lib/l10n/app_es.arb`](lib/l10n/app_es.arb), [`lib/l10n/app_fr.arb`](lib/l10n/app_fr.arb), [`lib/l10n/app_ja.arb`](lib/l10n/app_ja.arb), [`lib/l10n/app_ru.arb`](lib/l10n/app_ru.arb)) and ran `flutter gen-l10n`.
* [2025-05-24 13:41:30] - Implemented username display on the home screen's top-right corner using Stack, Positioned, and Chip widgets. Modified user_providers.dart to add `usernameAsyncProvider` (FutureProvider) to correctly use `AsyncValue.when()` for loading/error/data states as per pseudocode. Updated home_screen.dart to use the new provider.