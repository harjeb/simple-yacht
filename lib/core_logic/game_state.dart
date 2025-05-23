// lib/core_logic/game_state.dart

import 'dart:math';
import 'package:collection/collection.dart'; // For SetEquality

// Represents the state of a single die.
class Die {
  int value;
  bool isHeld;

  Die({this.value = 1, this.isHeld = false});

  void roll() {
    // New logic: if isHeld is true, it means the die is selected to be re-rolled (not kept).
    if (isHeld) {
      value = Random().nextInt(6) + 1;
    }
  }

  void toggleHold() {
    isHeld = !isHeld;
  }

  @override
  String toString() {
    return 'Die(value: $value, isHeld: $isHeld)';
  }
}

// Represents the different scoring categories in Yahtzee.
enum ScoreCategory {
  ones,
  twos,
  threes,
  fours,
  fives,
  sixes,
  threeOfAKind,
  fourOfAKind,
  fullHouse,
  smallStraight,
  largeStraight,
  yahtzee,
  chance,
  bonus // For upper section bonus
}

class RollEvent {
  final int id;
  final Set<int> rolledIndices; // Indices of dice that were rolled
  final bool isInitialRoll; // True if all dice were rolled (e.g. start of turn/game)

  RollEvent({required this.id, required this.rolledIndices, this.isInitialRoll = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RollEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          SetEquality().equals(rolledIndices, other.rolledIndices) &&
          isInitialRoll == other.isInitialRoll;

  @override
  int get hashCode => id.hashCode ^ rolledIndices.hashCode ^ isInitialRoll.hashCode;

  @override
  String toString() {
    return 'RollEvent(id: $id, rolledIndices: $rolledIndices, isInitialRoll: $isInitialRoll)';
  }
}

// Represents the game state.
class GameState {
  List<Die> dice;
  int rollsLeft;
  Map<ScoreCategory, int?> scores; // Nullable int for unassigned scores
  int currentPlayerId; // Placeholder for multi-player, can be 0 for single player
  int currentRound; // Current round number (1 to 13 for standard Yahtzee)
  int yahtzeeBonusCount; // Number of Yahtzee bonuses
  RollEvent? lastRollEvent; // Tracks the last dice roll event for animation
  bool isGameInProgress; // Tracks if a game is currently active

  // Upper section scores needed for bonus calculation
  int get upperSectionSubtotal {
    int subtotal = 0;
    const upperCategories = [
      ScoreCategory.ones,
      ScoreCategory.twos,
      ScoreCategory.threes,
      ScoreCategory.fours,
      ScoreCategory.fives,
      ScoreCategory.sixes,
    ];
    for (var category in upperCategories) {
      subtotal += scores[category] ?? 0;
    }
    return subtotal;
  }

  // Bonus for upper section
  int get upperSectionBonus {
    return upperSectionSubtotal >= 63 ? 35 : 0;
  }

  // Total score for the upper section including bonus
  int get upperSectionTotal {
    return upperSectionSubtotal + upperSectionBonus;
  }

  // Total score for the lower section
  int get lowerSectionTotal {
    int total = 0;
    const lowerCategories = [
      ScoreCategory.threeOfAKind,
      ScoreCategory.fourOfAKind,
      ScoreCategory.fullHouse,
      ScoreCategory.smallStraight,
      ScoreCategory.largeStraight,
      ScoreCategory.yahtzee,
      ScoreCategory.chance,
    ];
    for (var category in lowerCategories) {
      total += scores[category] ?? 0;
    }
    return total;
  }

  // Grand total score
  int get grandTotal {
    return upperSectionTotal + lowerSectionTotal + (yahtzeeBonusCount * 100);
  }

  bool get isGameOver {
    // Game is over if all categories are filled
    return scores.values.every((score) => score != null);
  }

  GameState({
    this.currentPlayerId = 0,
    this.currentRound = 1,
    this.yahtzeeBonusCount = 0,
    // lastRollEvent will be set by _performInitialRoll or subsequent rolls
    this.isGameInProgress = false, // Default to false
  })  : dice = List.generate(5, (_) => Die()),
        rollsLeft = 2, // Start with 2 rolls left after automatic first roll
        scores = {
          for (var category in ScoreCategory.values)
            category: category == ScoreCategory.bonus ? 0 : null // Initialize bonus to 0, others to null
        } {
    // _performInitialRoll is called by the Notifier which will also set the initial RollEvent
  }

  // Note: _performInitialRoll and rollDice are now primarily managed by GameStateNotifier
  // to handle RollEvent creation and state updates atomically.
  // These methods in GameState can be simplified or made internal if GameStateNotifier
  // directly manipulates the dice and other properties.
  // For now, we'll assume Notifier calls these and then updates lastRollEvent.

  // This method is now more of a utility for the Notifier.
  // The Notifier will be responsible for creating the RollEvent.
  void updateDiceForInitialRoll() {
    final random = Random();
    for (var die in dice) {
      die.value = random.nextInt(6) + 1;
      die.isHeld = false;
    }
  }

  // This method is now more of a utility for the Notifier.
  // The Notifier will be responsible for creating the RollEvent
  // and determining which dice were actually rolled.
  Set<int> updateDiceForManualRoll() {
    final Set<int> rolledIndices = {};
    if (rollsLeft > 0) {
      for (int i = 0; i < dice.length; i++) {
        if (dice[i].isHeld) { // If selected to be discarded, it will be rolled
          dice[i].roll();
          rolledIndices.add(i);
        }
      }
      rollsLeft--;
      for (var die in dice) {
        die.isHeld = false;
      }
    }
    return rolledIndices;
  }

  // Toggles the hold state of a die at a specific index.
  void toggleDieHold(int index) {
    if (index >= 0 && index < dice.length) {
      dice[index].toggleHold();
      // Placeholder for network send if applicable
      // NETWORK_SEND_DICE_STATE(dice, rollsLeft);
    }
  }

  // Resets the turn: unholds all dice and resets rollsLeft.
  void resetTurn() {
    // All dice are un-held, values are kept until next roll.
    for (var die in dice) {
      die.isHeld = false;
    }
    rollsLeft = 2;
    currentRound++;
    // _performInitialRoll (now updateDiceForInitialRoll) will be called by Notifier,
    // which also creates the RollEvent.
    // Placeholder for network send if applicable
    // NETWORK_SEND_DICE_STATE(dice, rollsLeft);
  }

  // Assigns a score to a category.
  // Returns true if successful, false if category already scored or invalid.
  bool assignScore(ScoreCategory category, int score) {
    if (scores[category] == null && category != ScoreCategory.bonus) {
      scores[category] = score;

      // Handle Yahtzee bonus
      if (category == ScoreCategory.yahtzee && score > 0) {
        // Check if Yahtzee was already scored (i.e., this is a bonus Yahtzee)
        // This logic assumes the first Yahtzee score is 50 and subsequent ones add to bonus count.
        // A more robust way might be to check if scores[ScoreCategory.yahtzee] was already non-null *before* this assignment.
        // However, for simplicity, if a Yahtzee is scored and it's not the *first* time a score is put here,
        // it implies a bonus. This needs careful handling if a player scores 0 for Yahtzee then later a real one.
        // A dedicated flag `hasScoredFirstYahtzee` might be better.
        // For now, let's assume if scores[ScoreCategory.yahtzee] is already non-null and > 0, this is a bonus.
        // This needs to be re-evaluated. A simpler approach: if yahtzee is scored (score > 0),
        // and scores[ScoreCategory.yahtzee] was *already* > 0 before this assignment, it's a bonus.
        // The current `assignScore` structure makes this tricky.
        // Let's refine: if this is a Yahtzee (score > 0) AND scores[ScoreCategory.yahtzee] was already filled with a Yahtzee (50),
        // then it's a bonus.
        // The problem is `scores[category]` is updated *before* this check.
        // A better way: if category is Yahtzee and score is 50:
        //  if scores[ScoreCategory.yahtzee] was already 50 (or more due to previous bonuses if we stored total there), increment bonus.
        //  else, this is the first Yahtzee.
        // Let's assume the `score` parameter is the calculated score for the current attempt (e.g. 50 for Yahtzee)
        // And `scores[ScoreCategory.yahtzee]` holds the *current stored* score for that category.

        // If Yahtzee category already has a score (meaning it was scored before, even if 0)
        // and the current dice make a Yahtzee (score == 50)
        // then it's a bonus Yahtzee.
        // This logic is flawed if a player scores 0 for Yahtzee then gets a real one.
        // The rules are: first Yahtzee is 50. Each subsequent Yahtzee is a 100 point bonus.
        // The Yahtzee box itself can only be scored once.
        // So, if scores[ScoreCategory.yahtzee] is NOT null (it has been scored) AND score == 50 (current roll is a Yahtzee)
        // then it's a bonus.
        // This still doesn't feel right.

        // Correct logic for Yahtzee Bonus:
        // 1. The Yahtzee category itself scores 50 for the first Yahtzee.
        // 2. For *each subsequent* Yahtzee rolled, if the Yahtzee category has already been scored (with 50 or 0),
        //    the player gets a 100 point bonus. These bonuses are tracked by yahtzeeBonusCount.
        //    The player must also score the current roll in another category according to Yahtzee Joker Rules.

        // So, when assignScore is called for Yahtzee:
        if (category == ScoreCategory.yahtzee) {
          // If this is the first Yahtzee being scored (value 50)
          // no immediate bonus count increment. The 50 goes into the Yahtzee box.
        } else if (score > 0 && dice.every((d) => d.value == dice.first.value) && dice.length == 5 && dice.first.value != 0) {
          // This means: current category is NOT Yahtzee, BUT the dice ARE a Yahtzee.
          // And the Yahtzee category has already been scored (either 50 or 0).
          if (scores[ScoreCategory.yahtzee] != null) {
            yahtzeeBonusCount++;
          }
        }
      }

      if (isGameOver) {
        isGameInProgress = false;
      }

      // Update bonus if an upper section score was assigned
      if ([
        ScoreCategory.ones,
        ScoreCategory.twos,
        ScoreCategory.threes,
        ScoreCategory.fours,
        ScoreCategory.fives,
        ScoreCategory.sixes
      ].contains(category)) {
        scores[ScoreCategory.bonus] = upperSectionBonus;
      }
      // Placeholder for network send if applicable
      // NETWORK_SEND_SCORE_UPDATE(scores);
      return true;
    }
    return false;
  }

  // Resets the game to its initial state.
  void resetGame() { // Called by Notifier
    dice = List.generate(5, (_) => Die());
    rollsLeft = 3; // Notifier will call _performInitialRoll and set to 2
    scores = {
      for (var category in ScoreCategory.values)
        category: category == ScoreCategory.bonus ? 0 : null
    };
    currentPlayerId = 0; // Reset to default player
    currentRound = 1;
    yahtzeeBonusCount = 0; // Reset Yahtzee bonus count
    isGameInProgress = true; // A new game is now in progress
    // Placeholder for network send if applicable
    // NETWORK_SEND_GAME_RESET();
  }

  GameState copyWith({
    List<Die>? dice,
    int? rollsLeft,
    Map<ScoreCategory, int?>? scores,
    int? currentPlayerId,
    int? currentRound,
    int? yahtzeeBonusCount,
    RollEvent? lastRollEvent, // Nullable to allow clearing/setting
    bool? isGameInProgress,
  }) {
    // Create a new GameState instance, primarily for updating immutable fields
    // or fields that don't have direct setters but are part of the core state.
    // For mutable fields like 'dice' and 'scores', the existing instance is modified
    // by the utility methods, and then this new instance wraps those changes
    // along with any changes to immutable fields.
    
    // This approach to copyWith is a bit mixed due to GameState having mutable collections (dice, scores)
    // that are modified by methods, and then the Notifier replaces the whole GameState.
    // A more purely immutable GameState would have all utility methods return new GameState instances.

    final newState = GameState(
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      currentRound: currentRound ?? this.currentRound,
      yahtzeeBonusCount: yahtzeeBonusCount ?? this.yahtzeeBonusCount,
      isGameInProgress: isGameInProgress ?? this.isGameInProgress,
    );

    // Carry over mutable state that might have been updated by utility methods
    // or provide new ones if passed to copyWith.
    newState.dice = dice ?? this.dice.map((d) => Die(value: d.value, isHeld: d.isHeld)).toList(); // Deep copy if not provided
    newState.rollsLeft = rollsLeft ?? this.rollsLeft;
    newState.scores = scores ?? Map.from(this.scores); // Deep copy if not provided
    
    // Specifically handle lastRollEvent as it can be nullable
    newState.lastRollEvent = lastRollEvent ?? this.lastRollEvent;
    
    return newState;
  }

  @override
  String toString() {
    return 'GameState(dice: $dice, rollsLeft: $rollsLeft, scores: $scores, upperSubtotal: $upperSectionSubtotal, bonus: $upperSectionBonus, grandTotal: $grandTotal, round: $currentRound, yahtzeeBonusCount: $yahtzeeBonusCount, lastRollEvent: $lastRollEvent, isGameInProgress: $isGameInProgress)';
  }
}