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
## Current Tasks

* [2025-05-23 04:39:16] - Single-player mode polishing and bug fixes completed.
* [2025-05-23 06:03:58] - Implemented internationalization (i18n) with English and Chinese language support, including language switching via settings.

## Next Steps

* Implement Firebase backend and online features (Authentication, Firestore for game state/leaderboard).
* Integrate frontend with Firebase services.
* [2025-05-23 08:08:52] - Implemented "Continue Game" button logic on home screen and updated game screen exit button with confirmation dialog.
* [2025-05-23 08:12:26] - Corrected "Continue Game" button behavior after exiting a game by ensuring `isGameInProgress` is reset.
* [2025-05-23 08:51:44] - Updated German, Spanish, Japanese, Russian, and French localization files with new translations for "Continue Game" and "Exit Game Confirmation" features.