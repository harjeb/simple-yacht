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
import 'package:myapp/ui_screens/splash_screen.dart'; // Import SplashScreen
import 'package:myapp/services/auth_service.dart'; // Import for authStateChangesProvider

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/splash', // Start with splash screen
      // refreshListenable: No longer using userServiceProvider directly here.
      // GoRouter will re-evaluate redirect on navigation.
      // If explicit refresh is needed based on usernameProvider state changes,
      // a more complex setup might be required, but typically redirect handles it.
      redirect: (BuildContext context, GoRouterState state) async { // Make redirect async
        final authState = ref.watch(authStateChangesProvider); // Watch auth state for reactivity
        final location = state.uri.toString();

        // If still on splash screen, or auth state is loading, no redirect yet.
        if (location == '/splash' || authState.isLoading || (!authState.hasValue && !authState.hasError)) {
          // If auth is loading and we are not on splash, redirect to splash.
          // This handles cases where deep linking might occur before auth is ready.
          if (location != '/splash' && (authState.isLoading || (!authState.hasValue && !authState.hasError))) {
            return '/splash';
          }
          return null; // Stay on splash or current if auth is loading
        }

        // Auth state is resolved (hasValue or hasError)
        final firebaseUser = authState.asData?.value;

        if (firebaseUser == null) {
          // If no Firebase user (sign-in failed or not yet attempted and we are past splash)
          // and not already on splash, redirect to splash to attempt sign-in.
          // This shouldn't happen if SplashScreen logic is correct, but as a safeguard.
          if (location != '/splash') {
            return '/splash';
          }
          return null; // Stay on splash if sign-in failed
        }

        // Firebase user exists, now check for app-level username
        final String? username = await ref.read(usernameProvider.future); // Check username after Firebase user confirmed
        final bool hasUsernameValue = username != null && username.isNotEmpty;

        // If on splash screen and Firebase user exists, proceed to username check / main app
        if (location == '/splash') {
          return hasUsernameValue ? '/' : '/username_setup';
        }

        // If user has no app username and is not trying to access setup, redirect to setup.
        if (!hasUsernameValue && location != '/username_setup') {
          return '/username_setup';
        }
        // If user has an app username and is trying to access setup, redirect to home.
        if (hasUsernameValue && location == '/username_setup') {
          ref.read(gameStateProvider.notifier).setToInitialState();
          return '/';
        }
        // No redirect needed
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/splash', // Add splash screen route
          builder: (BuildContext context, GoRouterState state) {
            return const SplashScreen();
          },
        ),
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