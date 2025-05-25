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
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      // refreshListenable: No longer using userServiceProvider directly here.
      // GoRouter will re-evaluate redirect on navigation.
      // If explicit refresh is needed based on usernameProvider state changes,
      // a more complex setup might be required, but typically redirect handles it.
      redirect: (BuildContext context, GoRouterState state) async { // Make redirect async
        // It's generally better to watch providers that might change during the app's lifecycle
        // in a widget, but for redirect, reading the future once per navigation is common.
        // For a more reactive redirect, one might listen to usernameProvider.
        final String? username = await ref.read(usernameProvider.future);
        final bool hasUsernameValue = username != null && username.isNotEmpty;
        final String location = state.uri.toString();

        // If user has no username and is not trying to access setup, redirect to setup.
        if (!hasUsernameValue && location != '/username_setup') {
          return '/username_setup';
        }
        // If user has a username and is trying to access setup, redirect to home.
        if (hasUsernameValue && location == '/username_setup') {
          // User has just set up their username (or already had one and tried to go to setup).
          // Reset game state if they are coming from setup to ensure a clean start.
          // This specific condition might need refinement based on exact flow from UsernameSetupScreen.
          // For now, if they land on /username_setup with a username, they go to home.
          // The actual saving of username and creation of user profile in Firestore
          // should happen in UsernameSetupScreen.
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