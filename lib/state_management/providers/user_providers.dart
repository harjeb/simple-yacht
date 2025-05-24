import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/services/user_service.dart';
import 'package:myapp/services/local_storage_service.dart';

// Provider for LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Provider for UserService
// UserService extends ChangeNotifier, so we use ChangeNotifierProvider
final userServiceProvider = ChangeNotifierProvider<UserService>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return UserService(localStorageService: localStorageService);
});

// Provider for the current username string (synchronous, reflects current state)
// This provider listens to a specific part of the UserService state.
final usernameProvider = Provider<String?>((ref) {
  return ref.watch(userServiceProvider).currentUsername;
});

// FutureProvider for username, to be used with .when() for loading/error states
final usernameAsyncProvider = FutureProvider<String?>((ref) async {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return await localStorageService.getUsername();
});

// Provider to check if a username has been set
final hasUsernameProvider = Provider<bool>((ref) {
  return ref.watch(userServiceProvider).hasUsername;
});

// Example of how to save a username from UI:
// final userService = ref.read(userServiceProvider);
// await userService.saveUsername("NewUser");
// No need to manually refresh usernameProvider or hasUsernameProvider,
// as they will update automatically when UserService notifies listeners.