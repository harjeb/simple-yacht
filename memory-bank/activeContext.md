# Active Context

  This file tracks the project's current status, including recent changes, current goals, and open questions.
  2025-05-23 02:56:27 - Log of updates made.

*

## Current Focus

* [2025-05-23 06:03:58] - Implemented internationalization (i18n) with English/Chinese support and language switching via settings. Single-player mode is now polished and localized. Next: Implement Firebase backend and online features.

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
## Open Questions/Issues

*
* [2025-05-23 08:08:27] - Updated home screen to show "Continue Game" button if a game is in progress. Updated game screen exit button to 'X' icon and added a confirmation dialog before exiting a game. Updated relevant localization files.
* [2025-05-23 08:12:11] - Fixed bug where "Continue Game" button was still shown after exiting a game. Implemented `setToInitialState` in `GameStateNotifier` to correctly reset `isGameInProgress` to false when exiting.
* [2025-05-23 08:51:29] - Updated localization files (de, es, ja, ru, fr) with new entries for 'continueGame' and 'exitGameConfirmation'.