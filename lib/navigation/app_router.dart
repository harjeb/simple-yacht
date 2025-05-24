import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:myapp/state_management/providers/game_providers.dart'; // Import game providers
import 'package:myapp/ui_screens/home_screen.dart';
import 'package:myapp/ui_screens/game_screen.dart';
import 'package:myapp/ui_screens/settings_screen.dart';
import 'package:myapp/ui_screens/leaderboard_screen.dart';
import 'package:myapp/ui_screens/username_setup_screen.dart';
import 'package:myapp/state_management/providers/user_providers.dart'; // Import user providers

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) { // Changed to a method taking WidgetRef
    // Initial check for username. This might run before UserService is fully initialized from storage.
    // The redirect logic will handle the dynamic state.
    // We need to ensure UserService is loaded before first redirect check if possible,
    // or handle loading state within redirect. For simplicity, UserService loads eagerly.

    return GoRouter(
      initialLocation: '/',
      // refreshListenable: ref.watch(userServiceProvider), // Optional: To re-evaluate routes if username changes during app lifecycle
      redirect: (BuildContext context, GoRouterState state) {
        final userService = ref.read(userServiceProvider); // Read the provider
        final bool hasUsername = userService.hasUsername;
        final String location = state.uri.toString();

        // If user has no username and is not trying to access setup, redirect to setup.
        if (!hasUsername && location != '/username_setup') {
          return '/username_setup';
        }
        // If user has a username and is trying to access setup, redirect to home.
        if (hasUsername && location == '/username_setup') {
          // User has just set up their username, reset game state before redirecting to home
          ref.read(gameStateProvider.notifier).setToInitialState();
          return '/';
        }
        // No redirect needed
        return null;
      },
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
                return const GameScreen();
              },
            ),
            GoRoute(
              path: 'leaderboard',
              builder: (BuildContext context, GoRouterState state) {
                return const LeaderboardScreen();
              },
            ),
            GoRoute(
              path: 'settings',
              builder: (BuildContext context, GoRouterState state) {
                return const SettingsScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: '/username_setup',
          builder: (BuildContext context, GoRouterState state) {
            return const UsernameSetupScreen();
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Text('Error: ${state.error?.message}'),
        ),
      ),
    );
  }
}