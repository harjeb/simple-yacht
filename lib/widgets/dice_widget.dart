import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/state_management/providers/game_providers.dart';
import 'dart:math' as math;

class DiceWidget extends ConsumerStatefulWidget {
  // No longer takes diceValues and heldDice as parameters
  const DiceWidget({super.key});

  @override
  ConsumerState<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends ConsumerState<DiceWidget> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  int? _previousRollEventId; // Changed from _previousRollId

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    _animations = _animationControllers
        .map((controller) => Tween<double>(begin: 0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut)))
        .toList();
    
    // Initialize _previousRollId with the initial rollId from the provider
    // WidgetsBinding.instance.addPostFrameCallback to safely read provider in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Read the initial RollEvent's ID
        _previousRollEventId = ref.read(lastRollEventProvider)?.id;
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diceValues = ref.watch(diceValuesProvider);
    final heldDice = ref.watch(heldDiceProvider); // Current selection state
    final rollsLeft = ref.watch(rollsLeftProvider);
    final currentRollEvent = ref.watch(lastRollEventProvider);

    // Animation logic based on RollEvent change
    if (_previousRollEventId != currentRollEvent?.id) {
      if (currentRollEvent != null) {
        for (int i = 0; i < 5; i++) {
          if (currentRollEvent.rolledIndices.contains(i)) {
            // This die was part of the roll event, so animate it
            _animationControllers[i].reset();
            _animationControllers[i].forward(from: 0.0);
          } else {
            // This die was not rolled (it was kept), ensure it's stopped and upright
            if (_animationControllers[i].isAnimating) {
               _animationControllers[i].stop();
            }
            _animationControllers[i].value = 0;
          }
        }
      }
    }
    _previousRollEventId = currentRollEvent?.id;

    // Ensure dice that are currently "kept" (not selected for discard) AND
    // were NOT part of the most recent roll animation are static and upright.
    // This handles cases like toggling hold status without a roll.
    for (int i = 0; i < 5; i++) {
      bool dieIsCurrentlySelectedToBeKept = !heldDice[i];
      // Check if the die was animated due to the current (still fresh) roll event
      bool dieWasAnimatedByFreshRollEvent = (_previousRollEventId == currentRollEvent?.id) &&
                                           (currentRollEvent?.rolledIndices.contains(i) ?? false);

      if (dieIsCurrentlySelectedToBeKept && !dieWasAnimatedByFreshRollEvent) {
        // If the die is "kept" and its animation wasn't just triggered by the roll event
        if (_animationControllers[i].isAnimating) {
          _animationControllers[i].stop();
        }
        _animationControllers[i].value = 0; // Keep it upright
      }
    }


    if (diceValues.length != 5 || heldDice.length != 5) {
      // This should ideally not happen if providers are correct
      return const Center(child: Text('Error: Invalid dice data'));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: rollsLeft < 3 && rollsLeft > 0
              ? () {
                  // When toggling hold, we don't want the roll animation.
                  // The change in heldDice[index] will be picked up by the build method.
                  // If the die becomes held, the loop above will set its rotation to 0.
                  // If it becomes un-held, it will be ready for the next roll animation.
                  ref.read(gameStateProvider.notifier).toggleDieHold(index);
                }
              : null,
          child: RotationTransition(
            turns: _animations[index],
            child: Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      // New logic: heldDice[index] true means "selected to discard" -> red border
                      // heldDice[index] false means "kept" -> grey border
                      color: heldDice[index] ? Colors.red : Colors.grey,
                      width: heldDice[index] ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      diceValues[index].toString(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (heldDice[index]) // Show X if selected to discard
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(4)
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}