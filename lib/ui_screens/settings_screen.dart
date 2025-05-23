import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/state_management/providers/locale_provider.dart';
import 'package:myapp/generated/app_localizations.dart'; // Updated import path

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    // Define the locales your app supports for the dropdown
    final supportedLocales = AppLocalizations.supportedLocales;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Language / 语言', // A neutral way to display this label before full localization of this screen itself
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Locale>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Language / 选择语言',
              ),
              value: currentLocale ?? const Locale('en'), // Default to English if no preference set
              items: supportedLocales.map((locale) {
                String displayName;
                switch (locale.languageCode) {
                  case 'en':
                    displayName = 'English';
                    break;
                  case 'zh':
                    displayName = '中文 (Chinese)';
                    break;
                  case 'es':
                    displayName = 'Español (Spanish)';
                    break;
                  case 'fr':
                    displayName = 'Français (French)';
                    break;
                  case 'de':
                    displayName = 'Deutsch (German)';
                    break;
                  case 'ja':
                    displayName = '日本語 (Japanese)';
                    break;
                  case 'ru':
                    displayName = 'Русский (Russian)';
                    break;
                  default:
                    displayName = locale.toLanguageTag();
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
            const SizedBox(height: 20),
            Text(
              "Current appTitle: ${l10n.appTitle}", // Example of using a localized string
              style: Theme.of(context).textTheme.bodySmall,
            ),
             Text(
              "Current startGame: ${l10n.startGame}", // Example of using a localized string
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}