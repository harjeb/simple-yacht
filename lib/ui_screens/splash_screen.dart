import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/state_management/providers/user_providers.dart';
import 'package:myapp/generated/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Attempt to sign in anonymously when the screen initializes
    // WidgetsBinding.instance.addPostFrameCallback to ensure context is available for navigation
    // and provider access is safe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Ensure the widget is still in the tree
        developer.log('SplashScreen: initState - calling attemptAnonymousSignIn', name: 'SplashScreen.initState');
        ref.read(anonymousSignInNotifierProvider.notifier).attemptAnonymousSignIn();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    developer.log('SplashScreen: build method called.', name: 'SplashScreen.build');

    // Listen to the anonymousSignInNotifierProvider for state changes
    ref.listen<AnonymousSignInNotifier>(anonymousSignInNotifierProvider, (previous, next) {
      developer.log('SplashScreen: anonymousSignInNotifierProvider listener triggered. Prev loading: ${previous?.isLoading}, Next loading: ${next.isLoading}, Next user: ${next.currentUser?.uid}, Next error: ${next.errorMessage}', name: 'SplashScreen.listener');
      if (mounted) { // Ensure the widget is still in the tree before navigating
        if (!next.isLoading) {
          if (next.currentUser != null) {
            developer.log('SplashScreen: Sign-in successful. User: ${next.currentUser?.uid}. Refreshing router.', name: 'SplashScreen.listener');
            // If sign-in is successful, GoRouter's redirect logic in AppRouter
            // should handle navigation to the appropriate screen (home or username setup).
            // We can trigger a re-evaluation of routes if needed, or rely on initial redirect.
            // For simplicity, we assume AppRouter handles this.
            // If direct navigation is needed here, it would be context.go('/');
            // but usually, AppRouter's redirect based on auth state is preferred.
            // A simple way to trigger route re-evaluation if AppRouter depends on auth state:
            GoRouter.of(context).refresh(); // This might be needed if router doesn't auto-react
                                         // to authStateChangesProvider updates quickly enough
                                         // or if initial route is '/' and redirect handles it.
                                         // More robustly, AppRouter should listen to authStateChangesProvider.
          } else if (next.errorMessage != null) {
            developer.log('SplashScreen: Sign-in error: ${next.errorMessage}', name: 'SplashScreen.listener');
            // Error is handled by the UI below
          } else {
            developer.log('SplashScreen: Sign-in finished, no user and no error.', name: 'SplashScreen.listener');
          }
        } else {
          developer.log('SplashScreen: Sign-in still in progress.', name: 'SplashScreen.listener');
        }
      }
    });

    final signInState = ref.watch(anonymousSignInNotifierProvider);
    developer.log('SplashScreen: Watched signInState - isLoading: ${signInState.isLoading}, User: ${signInState.currentUser?.uid}, Error: ${signInState.errorMessage}', name: 'SplashScreen.build');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(localizations.loadingLabel, style: Theme.of(context).textTheme.titleMedium), // Ensure 'loadingLabel' exists
            if (signInState.isLoading) ...[
              // Text("Signing in..."), // Already covered by CircularProgressIndicator and loadingLabel
            ] else if (signInState.errorMessage != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  "${localizations.errorLabel}: ${signInState.errorMessage}", // Ensure 'errorLabel' exists
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(anonymousSignInNotifierProvider.notifier).attemptAnonymousSignIn();
                },
                child: Text(localizations.retryButtonLabel), // Ensure 'retryButtonLabel' exists
              )
            ] else if (signInState.currentUser == null && !signInState.isLoading) ...[
               // This case might occur if sign-in completes but user is still null without an error message.
               // This is less likely with the current AnonymousSignInNotifier logic but good to consider.
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  localizations.signInFailedGeneric, // Ensure 'signInFailedGeneric' exists
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(anonymousSignInNotifierProvider.notifier).attemptAnonymousSignIn();
                },
                child: Text(localizations.retryButtonLabel),
              )
            ]
            // If currentUser is not null and not loading, navigation should have occurred.
            // No specific UI needed here for the success case as it's handled by navigation.
          ],
        ),
      ),
    );
  }
}