import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core_logic/game_state.dart';
import 'package:myapp/core_logic/scoring_rules.dart'; // Required for calculateScore
// import 'package:myapp/services/local_storage_service.dart'; // No longer directly used here for high score

// Notifier for the game state
class GameStateNotifier extends StateNotifier<GameState> {
  // final LocalStorageService _localStorageService = LocalStorageService(); // Removed
  int _rollCounter = 0; // Internal counter for unique RollEvent IDs

  GameStateNotifier() : super(GameState()); // GameState constructor sets isGameInProgress = false

  // This method is now called explicitly when a new game starts or a turn starts.
  void _performInitialRollAndUpdateState({bool isNewGame = false, required GameState baseState}) {
    // Use copyWith to ensure we're working with a new instance for modification,
    // preserving other properties not directly related to the roll.
    final workingState = baseState.copyWith(
      dice: baseState.dice.map((d) => Die(value: d.value, isHeld: d.isHeld)).toList(), // Deep copy
      scores: Map.from(baseState.scores), // Deep copy
      isGameInProgress: true, // Explicitly set to true as a game is starting/continuing
      rollsLeft: 3, // Initial rolls for a new game/turn before auto-roll
      currentRound: isNewGame ? 1 : baseState.currentRound,
      yahtzeeBonusCount: isNewGame ? 0 : baseState.yahtzeeBonusCount,
      // lastRollEvent will be set below
    );

    workingState.updateDiceForInitialRoll(); // This updates dice values and sets isHeld to false
    workingState.rollsLeft = 2; // After initial roll, 2 rolls left

    final initialRollEvent = RollEvent(
      id: _rollCounter++,
      rolledIndices: {0, 1, 2, 3, 4}, // All dice are rolled initially
      isInitialRoll: true,
    );
    
    state = workingState.copyWith(lastRollEvent: initialRollEvent);
  }


  // Rolls the dice if rolls are left
  void rollDice() {
    if (state.rollsLeft > 0) {
      final workingState = state.copyWith(
        dice: state.dice.map((d) => Die(value: d.value, isHeld: d.isHeld)).toList(),
        scores: Map.from(state.scores),
      );

      final Set<int> rolledIndices = workingState.updateDiceForManualRoll(); // This updates dice, rollsLeft, and isHeld
      
      final rollEvent = RollEvent(
        id: _rollCounter++,
        rolledIndices: rolledIndices,
        isInitialRoll: false,
      );
      state = workingState.copyWith(lastRollEvent: rollEvent);
    }
  }

  // Toggles the hold state of a die
  void toggleDieHold(int index) {
    final newDice = state.dice.map((d) => Die(value: d.value, isHeld: d.isHeld)).toList();
    if (index >= 0 && index < newDice.length) {
      newDice[index].toggleHold();
    }
    // Create a new state with the updated dice list.
    // No new RollEvent as this is just a hold toggle.
    state = state.copyWith(dice: newDice);
  }
  
  void assignScore(ScoreCategory category) {
    if (state.scores[category] == null && category != ScoreCategory.bonus) {
      final score = ScoringRules.calculateScore(category, state.dice);

      final workingState = state.copyWith(
        dice: state.dice.map((d) => Die(value: d.value, isHeld: d.isHeld)).toList(),
        scores: Map.from(state.scores),
      );
      
      bool scoreAssigned = workingState.assignScore(category, score);

      if (scoreAssigned) {
        if (workingState.isGameOver) {
          // _localStorageService.saveHighScore(workingState.grandTotal); // Removed: LeaderboardService will handle this
          // Game is over, no new turn or roll event.
          state = workingState.copyWith(isGameInProgress: false); // Ensure game is marked not in progress
        } else {
          // Prepare for next turn
          workingState.resetTurn(); // Resets held dice, rollsLeft, increments round
          workingState.updateDiceForInitialRoll(); // Perform the new turn's automatic roll

          final newTurnRollEvent = RollEvent(
            id: _rollCounter++,
            rolledIndices: {0, 1, 2, 3, 4},
            isInitialRoll: true,
          );
          state = workingState.copyWith(lastRollEvent: newTurnRollEvent);
        }
      }
    }
  }

  // This method might be redundant if assignScore always leads to the next turn or game over.
  // However, if there's a scenario to advance turn without scoring (e.g., forfeiting a turn), it could be used.
  void nextTurn() {
     final workingState = state.copyWith(
        dice: state.dice.map((d) => Die(value: d.value, isHeld: d.isHeld)).toList(),
        scores: Map.from(state.scores),
      );
    workingState.resetTurn();
    workingState.updateDiceForInitialRoll();

    final newTurnRollEvent = RollEvent(
      id: _rollCounter++,
      rolledIndices: {0, 1, 2, 3, 4},
      isInitialRoll: true,
    );
    state = workingState.copyWith(lastRollEvent: newTurnRollEvent);
  }

  // Resets the entire game and starts a new one.
  // This method should call GameState.initial() to set the state.
  void resetAndStartNewGame() {
    // if (state.isGameOver && state.isGameInProgress) { // Only save if game was actually played and over
    //   _localStorageService.saveHighScore(state.grandTotal); // Removed: LeaderboardService will handle this
    // }
    _rollCounter = 0;
    // Use the new factory constructor from GameState.
    final initialGameState = GameState.initial();
    // Then, _performInitialRollAndUpdateState will handle the first roll and set the lastRollEvent.
    // isGameInProgress is already true from GameState.initial().
    _performInitialRollAndUpdateState(isNewGame: true, baseState: initialGameState);
  }

  // Resets the game to a completely fresh state, where no game is in progress.
  void setToInitialState() {
    // if (state.isGameOver && state.isGameInProgress) {
    //     _localStorageService.saveHighScore(state.grandTotal); // Removed: LeaderboardService will handle this
    // }
    _rollCounter = 0;
    state = GameState(); // This creates a new GameState with isGameInProgress = false and null lastRollEvent
  }

  // Provides a list of dice values for convenience
  List<int> get diceValues => state.dice.map((d) => d.value).toList();
  List<bool> get heldDice => state.dice.map((d) => d.isHeld).toList();
}

// Provider for the game state
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

// Example of a simple provider for dice values (derived from gameStateProvider)
final diceValuesProvider = Provider<List<int>>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.dice.map((d) => d.value).toList();
});

final heldDiceProvider = Provider<List<bool>>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.dice.map((d) => d.isHeld).toList();
});

// Provider for rolls left
final rollsLeftProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).rollsLeft;
});

// Provider for current round
final currentRoundProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).currentRound;
});

// Provider for scores
final scoresProvider = Provider<Map<ScoreCategory, int?>>((ref) {
  return ref.watch(gameStateProvider).scores;
});

// Provider for game over state
final isGameOverProvider = Provider<bool>((ref) {
  return ref.watch(gameStateProvider).isGameOver;
});

// Provider for upper section subtotal
final upperSectionSubtotalProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).upperSectionSubtotal;
});

// Provider for upper section bonus
final upperSectionBonusProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).upperSectionBonus;
});

// Provider for upper section total
final upperSectionTotalProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).upperSectionTotal;
});

// Provider for lower section total
final lowerSectionTotalProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).lowerSectionTotal;
});

// Provider for grand total
final grandTotalProvider = Provider<int>((ref) {
  return ref.watch(gameStateProvider).grandTotal;
});

// Provider for potential scores for the current dice
final potentialScoresProvider = Provider<Map<ScoreCategory, int>>((ref) {
  final gameState = ref.watch(gameStateProvider);
  // Ensure dice have been rolled at least once before calculating potential scores
  if (gameState.rollsLeft < 3) {
    return ScoringRules.getPotentialScores(gameState.dice);
  }
  return {}; // Return empty map if dice haven't been rolled yet in the turn
});

// Provider for Yahtzee bonus score
final yahtzeeBonusScoreProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.yahtzeeBonusCount * 100;
});

// Provider for the last roll event (replaces rollIdProvider)
final lastRollEventProvider = Provider<RollEvent?>((ref) {
  return ref.watch(gameStateProvider).lastRollEvent;
});

// Provider for game in progress state
final isGameInProgressProvider = Provider<bool>((ref) {
  return ref.watch(gameStateProvider).isGameInProgress;
});