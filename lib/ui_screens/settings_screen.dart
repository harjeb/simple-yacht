import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:myapp/state_management/providers/locale_provider.dart';
import 'package:myapp/generated/app_localizations.dart';
import 'package:myapp/state_management/providers/user_providers.dart'; // For userProfileProvider and usernameProvider
import 'package:myapp/services/user_service.dart'; // For userAccountServiceProvider
// It's good practice to also invalidate game state if any exists
import 'package:myapp/state_management/providers/game_providers.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final localizations = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.deleteAccountDialogTitle), // New localization
          content: Text(localizations.deleteAccountDialogContent), // New localization
          actions: <Widget>[
            TextButton(
              child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(localizations.confirmButtonLabel), // New localization
              style: TextButton.styleFrom(foregroundColor: Theme.of(dialogContext).colorScheme.error),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final userAccountService = ref.read(userAccountServiceProvider);
      final success = await userAccountService.deleteCurrentUserAccount();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? localizations.deleteAccountSuccess : localizations.deleteAccountError), // New localizations
          ),
        );
        if (success) {
          // Explicitly invalidate providers to ensure state is cleared immediately.
          // Though authStateChangesProvider will trigger rebuilds, this is more direct.
          ref.invalidate(userProfileProvider);
          ref.invalidate(usernameProvider);
          // Add any other user-specific or game-specific providers that need reset
          // ref.invalidate(rawGameScoreProvider); // Removed as it caused an error and gameStateProvider should cover game state reset.
          ref.invalidate(isGameOverProvider);
          ref.invalidate(gameStateProvider);
          // Add other providers as necessary, e.g., personalBestScoreProvider if it exists and caches user data

          // Navigate to splash screen. GoRouter's redirect logic will then
          // take the user to username_setup or home based on the new state.
          // Using context.go effectively replaces the navigation stack.
          if (context.mounted) { // Check context is still valid before navigating
            GoRouter.of(context).go('/splash');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final userProfileAsyncValue = ref.watch(userProfileProvider);

    final supportedLocales = AppLocalizations.supportedLocales;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView( // Changed to ListView for potentially longer content
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            l10n.languageSettingsLabel, // New localization for "Language / 语言"
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<Locale>(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: l10n.selectLanguageLabel, // New localization for "Select Language / 选择语言"
            ),
            value: currentLocale ?? const Locale('en'),
            items: supportedLocales.map((locale) {
              String displayName;
              switch (locale.languageCode) {
                case 'en': displayName = 'English'; break;
                case 'zh': displayName = '中文 (Chinese)'; break;
                case 'es': displayName = 'Español (Spanish)'; break;
                case 'fr': displayName = 'Français (French)'; break;
                case 'de': displayName = 'Deutsch (German)'; break;
                case 'ja': displayName = '日本語 (Japanese)'; break;
                case 'ru': displayName = 'Русский (Russian)'; break;
                default: displayName = locale.toLanguageTag();
              }
              return DropdownMenuItem<Locale>(
                value: locale,
                child: Text(displayName),
              );
            }).toList(),
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                ref.read(localeProvider.notifier).setLocale(newLocale);
              }
            },
          ),
          const Divider(height: 40),

          Text(
            l10n.accountSectionTitle, // New localization
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          userProfileAsyncValue.when(
            data: (userProfile) {
              if (userProfile == null || userProfile.transferCode.isEmpty) {
                return Text(l10n.recoveryCodeNotAvailable); // New localization
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.yourRecoveryCode, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SelectableText(
                    userProfile.transferCode,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.copyRecoveryCode), // New localization
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: userProfile.transferCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.recoveryCodeCopied)), // New localization
                      );
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text(l10n.genericError), // Using genericError now
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: Text(l10n.deleteAccountButtonLabel), // New localization
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => _deleteAccount(context, ref),
          ),
        ],
      ),
    );
  }
}