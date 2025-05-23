import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/ui_screens/home_screen.dart'; // Assuming myapp is the project name
import 'package:myapp/ui_screens/game_screen.dart'; // Import the actual GameScreen
import 'package:myapp/ui_screens/settings_screen.dart'; // Import the actual SettingsScreen

// Placeholder screen widgets (to be created later)
// Removed GameScreen placeholder, as we now import the actual one.
// Removed SettingsScreen placeholder, as we now import the actual one.

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Leaderboard Screen (Placeholder)')));
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'game',
            builder: (BuildContext context, GoRouterState state) {
              return const GameScreen(); // Now references the imported ui_screens/game_screen.dart
            },
          ),
          GoRoute(
            path: 'leaderboard',
            builder: (BuildContext context, GoRouterState state) {
              return const LeaderboardScreen(); // Placeholder
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (BuildContext context, GoRouterState state) {
              return const SettingsScreen(); // Now references the imported ui_screens/settings_screen.dart
            },
          ),
        ],
      ),
    ],
    // Optional: Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('Error: ${state.error?.message}'),
      ),
    ),
  );
}