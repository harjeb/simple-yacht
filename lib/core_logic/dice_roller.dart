// lib/core_logic/dice_roller.dart

import 'game_state.dart'; // Assuming Die class is in game_state.dart or imported there

class DiceRoller {
  // Rolls all dice that are not held.
  // This function might seem redundant if GameState.rollDice() is used directly.
  // However, it can be a central place for any additional logic related to rolling,
  // e.g., animations triggers, sound effects, or specific pre/post roll checks.
  void rollDice(List<Die> dice) {
    for (var die in dice) {
      if (!die.isHeld) {
        die.roll();
      }
    }
    // Placeholder for network send if this action is managed separately
    // NETWORK_SEND_DICE_ROLLED_STATE(dice);
  }

  // Toggles the hold state of a specific die.
  void toggleDieHold(Die die) {
    die.toggleHold();
    // Placeholder for network send if this action is managed separately
    // NETWORK_SEND_DIE_HOLD_STATE(die);
  }

  // Resets all dice to be not held.
  void unholdAllDice(List<Die> dice) {
    for (var die in dice) {
      die.isHeld = false;
    }
    // Placeholder for network send if this action is managed separately
    // NETWORK_SEND_UNHOLD_ALL_DICE_STATE(dice);
  }
}