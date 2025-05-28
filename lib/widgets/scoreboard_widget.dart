import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core_logic/game_state.dart'; // For ScoreCategory enum
import 'package:myapp/state_management/providers/game_providers.dart';
import 'package:myapp/generated/app_localizations.dart';

class ScoreboardWidget extends ConsumerWidget {
  const ScoreboardWidget({super.key});

  // Helper to get display name for ScoreCategory using AppLocalizations
  String _getCategoryDisplayName(BuildContext context, ScoreCategory category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case ScoreCategory.ones:
        return l10n.aces;
      case ScoreCategory.twos:
        return l10n.twos;
      case ScoreCategory.threes:
        return l10n.threes;
      case ScoreCategory.fours:
        return l10n.fours;
      case ScoreCategory.fives:
        return l10n.fives;
      case ScoreCategory.sixes:
        return l10n.sixes;
      case ScoreCategory.threeOfAKind:
        return l10n.threeOfAKind;
      case ScoreCategory.fourOfAKind:
        return l10n.fourOfAKind;
      case ScoreCategory.fullHouse:
        return l10n.fullHouse;
      case ScoreCategory.smallStraight:
        return l10n.smallStraight;
      case ScoreCategory.largeStraight:
        return l10n.largeStraight;
      case ScoreCategory.yahtzee:
        return l10n.yahtzee;
      case ScoreCategory.chance:
        return l10n.chance;
      case ScoreCategory.bonus: // This is usually not displayed as a scorable item directly
        return l10n.upperBonus; // Or handle differently if it's just for the total display
      default: // Should not happen if all categories are mapped
        return category.toString().split('.').last;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance
    final scores = ref.watch(scoresProvider);
    final potentialScores = ref.watch(potentialScoresProvider);
    final rollsLeft = ref.watch(rollsLeftProvider);
    final isGameOver = ref.watch(isGameOverProvider);

    // Define the order of categories for display
    final List<ScoreCategory> upperSectionCategories = [
      ScoreCategory.ones,
      ScoreCategory.twos,
      ScoreCategory.threes,
      ScoreCategory.fours,
      ScoreCategory.fives,
      ScoreCategory.sixes,
    ];
    final List<ScoreCategory> lowerSectionCategories = [
      ScoreCategory.threeOfAKind,
      ScoreCategory.fourOfAKind,
      ScoreCategory.fullHouse,
      ScoreCategory.smallStraight,
      ScoreCategory.largeStraight,
      ScoreCategory.yahtzee,
      ScoreCategory.chance,
    ];

    // Helper to build a score list tile
    Widget _buildScoreTile(ScoreCategory category, bool isScored, int? displayScore, bool canScore) {
      return ListTile(
        dense: true,
        leading: isScored ? Icon(Icons.check_circle, color: Theme.of(context).primaryColorDark) : const SizedBox(width: 24), // Icon for scored items
        title: Text(_getCategoryDisplayName(context, category)),
        trailing: Text(
          displayScore?.toString() ?? (isScored ? (scores[category]?.toString() ?? '0') : '-'),
          style: TextStyle(
            fontWeight: isScored || (canScore && displayScore != null) ? FontWeight.bold : FontWeight.normal,
            color: isScored
                ? Colors.black
                : (canScore && displayScore != null ? Theme.of(context).primaryColor : Colors.grey),
          ),
        ),
        onTap: !isScored && canScore && !isGameOver
            ? () {
                ref.read(gameStateProvider.notifier).assignScore(category);
              }
            : null,
        tileColor: isScored ? Colors.grey[200] : null,
      );
    }

    // Helper to build a total tile
    Widget _buildTotalTile(String title, String value, {Color? tileColor, bool isGrandTotal = false}) {
      return ListTile(
        dense: true,
        title: Text(title, style: TextStyle(fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal)),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isGrandTotal ? 16 : null)),
        tileColor: tileColor ?? Colors.blueGrey[50],
      );
    }

    final bool canScoreCategory = rollsLeft < 3 && rollsLeft >= 0; // Can score if at least one roll has been made

    List<Widget> upperSectionItems = upperSectionCategories.map((category) {
      final bool isScored = scores[category] != null;
      final int? displayScore = isScored ? scores[category] : (canScoreCategory ? potentialScores[category] : null);
      return _buildScoreTile(category, isScored, displayScore, canScoreCategory);
    }).toList();

    List<Widget> lowerSectionItems = lowerSectionCategories.map((category) {
      final bool isScored = scores[category] != null;
      final int? displayScore = isScored ? scores[category] : (canScoreCategory ? potentialScores[category] : null);
      return _buildScoreTile(category, isScored, displayScore, canScoreCategory);
    }).toList();

    return SingleChildScrollView( // Use SingleChildScrollView for potentially long content
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(l10n.upperSectionTitle, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  ...upperSectionItems,
                  _buildTotalTile(l10n.upperSubtotal, ref.watch(upperSectionSubtotalProvider).toString()),
                  _buildTotalTile(l10n.upperBonus, ref.watch(upperSectionBonusProvider).toString()),
                  _buildTotalTile(l10n.upperTotal, ref.watch(upperSectionTotalProvider).toString(), tileColor: Colors.blueGrey[100]),
                ],
              ),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(l10n.lowerSectionTitle, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  ...lowerSectionItems,
                  _buildTotalTile(l10n.lowerTotal, ref.watch(lowerSectionTotalProvider).toString(), tileColor: Colors.blueGrey[100]),
                ],
              ),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                   _buildTotalTile(l10n.yahtzeeBonusScore, ref.watch(yahtzeeBonusScoreProvider).toString(), tileColor: Colors.amber[50]),
                  _buildTotalTile(l10n.grandTotal, ref.watch(grandTotalProvider).toString(), tileColor: Colors.amber[100], isGrandTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}