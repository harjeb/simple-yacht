import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:simple_yacht/core_logic/score_entry.dart';
import 'package:simple_yacht/state_management/providers/leaderboard_providers.dart';
import 'package:simple_yacht/generated/app_localizations.dart'; // For localization

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsyncValue = ref.watch(leaderboardProvider);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.leaderboardTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Fallback if cannot pop
            }
          },
        ),
      ),
      body: leaderboardAsyncValue.when(
        data: (leaderboard) {
          if (leaderboard.isEmpty) {
            return Center(
              child: Text(
                localizations.leaderboardEmpty,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final ScoreEntry entry = leaderboard[index];
              final rank = index + 1;
              final formattedDate = DateFormat.yMd().add_jm().format(entry.timestamp);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('$rank'),
                  ),
                  title: Text(
                    entry.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    localizations.leaderboardScoreDate(entry.score.toString(), formattedDate),
                    // 'Score: ${entry.score} - Date: $formattedDate',
                  ),
                  trailing: Text(
                    localizations.leaderboardScorePoints(entry.score.toString()),
                    //'${entry.score} pts',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              localizations.leaderboardError(error.toString()),
              // 'Error loading leaderboard: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.refresh(leaderboardProvider);
        },
        tooltip: localizations.leaderboardRefreshTooltip,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}