// lib/core_logic/scoring_rules.dart

import 'game_state.dart'; // For Die and ScoreCategory

class ScoringRules {
  // Calculates the score for a given category based on the dice values.
  static int calculateScore(ScoreCategory category, List<Die> dice) {
    List<int> values = dice.map((d) => d.value).toList();
    values.sort(); // Sorting helps in straight detection and counting

    switch (category) {
      case ScoreCategory.ones:
        return _sumOfNs(values, 1);
      case ScoreCategory.twos:
        return _sumOfNs(values, 2);
      case ScoreCategory.threes:
        return _sumOfNs(values, 3);
      case ScoreCategory.fours:
        return _sumOfNs(values, 4);
      case ScoreCategory.fives:
        return _sumOfNs(values, 5);
      case ScoreCategory.sixes:
        return _sumOfNs(values, 6);
      case ScoreCategory.threeOfAKind:
        return _ofAKind(values, 3) ? _sumAll(values) : 0;
      case ScoreCategory.fourOfAKind:
        return _ofAKind(values, 4) ? _sumAll(values) : 0;
      case ScoreCategory.fullHouse:
        return _isFullHouse(values) ? 25 : 0;
      case ScoreCategory.smallStraight:
        return _isStraight(values, 4) ? 30 : 0;
      case ScoreCategory.largeStraight:
        return _isStraight(values, 5) ? 40 : 0;
      case ScoreCategory.yahtzee:
        return _ofAKind(values, 5) ? 50 : 0;
      case ScoreCategory.chance:
        return _sumAll(values);
      case ScoreCategory.bonus:
        // Bonus is calculated in GameState, not directly scorable here
        return 0;
      default:
        return 0;
    }
  }

  // Helper to sum all dice values.
  static int _sumAll(List<int> values) {
    return values.fold(0, (sum, val) => sum + val);
  }

  // Helper to sum dice with a specific value N.
  static int _sumOfNs(List<int> values, int n) {
    return values.where((val) => val == n).fold(0, (sum, val) => sum + val);
  }

  // Helper to check for N of a kind.
  static bool _ofAKind(List<int> values, int n) {
    Map<int, int> counts = {};
    for (var val in values) {
      counts[val] = (counts[val] ?? 0) + 1;
    }
    return counts.values.any((count) => count >= n);
  }

  // Helper to check for Full House.
  static bool _isFullHouse(List<int> values) {
    Map<int, int> counts = {};
    for (var val in values) {
      counts[val] = (counts[val] ?? 0) + 1;
    }
    // A full house has one pair and one three-of-a-kind.
    // This means two distinct die values, with counts of 2 and 3.
    // Or, if it's a Yahtzee (5 of a kind), it can also count as a Full House
    // if the Yahtzee category is already filled. (Standard rules vary, this is one interpretation)
    // For simplicity here, we'll stick to the strict 2 and 3 counts.
    // A Yahtzee (5 of a kind) is technically also a full house if you consider 3 of one and 2 of the same.
    // However, standard Yahtzee rules usually require two *different* values for the pair and triple.
    // Let's check for counts of 3 and 2.
    bool hasThree = counts.values.any((count) => count == 3);
    bool hasTwo = counts.values.any((count) => count == 2);
    return hasThree && hasTwo;
  }

  // Helper to check for a straight of a specific length.
  // Example: length 4 for Small Straight, length 5 for Large Straight.
  static bool _isStraight(List<int> sortedValues, int length) {
    List<int> uniqueValues = sortedValues.toSet().toList(); // Remove duplicates
    if (uniqueValues.length < length) return false;

    for (int i = 0; i <= uniqueValues.length - length; i++) {
      bool isStraightSequence = true;
      for (int j = 0; j < length - 1; j++) {
        if (uniqueValues[i + j + 1] != uniqueValues[i + j] + 1) {
          isStraightSequence = false;
          break;
        }
      }
      if (isStraightSequence) return true;
    }
    return false;
  }

  // Provides a map of all possible scores for the current dice.
  // This is useful for the UI to show potential scores before selection.
  static Map<ScoreCategory, int> getPotentialScores(List<Die> dice) {
    Map<ScoreCategory, int> potential = {};
    for (var category in ScoreCategory.values) {
      if (category != ScoreCategory.bonus) { // Bonus is not directly scorable
        potential[category] = calculateScore(category, dice);
      }
    }
    return potential;
  }
}