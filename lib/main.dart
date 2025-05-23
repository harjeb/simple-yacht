import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ProviderScope
import 'package:myapp/navigation/app_router.dart'; // Assuming myapp is the project name
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localizations delegates
import 'package:myapp/generated/app_localizations.dart'; // Import generated localizations from new path
import 'package:myapp/state_management/providers/locale_provider.dart'; // Import locale provider

void main() {
  runApp(
    const ProviderScope( // Wrap MyApp with ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget { // Changed to ConsumerWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Yahtzee Game', // This will be localized by MaterialApp if AppLocalizations.delegate is first and has appTitle
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
      locale: currentLocale, // Set the locale from the provider
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('zh', ''), // Chinese, no country code
        Locale('es', ''), // Spanish
        Locale('fr', ''), // French
        Locale('de', ''), // German
        Locale('ja', ''), // Japanese
        Locale('ru', ''), // Russian
        // Add other locales your app supports
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // If user has a saved preference, use it.
        if (currentLocale != null) {
          return currentLocale;
        }
        // Otherwise, try to match device locale.
        if (deviceLocale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == deviceLocale.languageCode) {
              // We don't check country code here, just language.
              // If you want to be more specific, you can check deviceLocale.countryCode as well.
              return supportedLocale;
            }
          }
        }
        // If device locale is not supported or not available, fallback to English.
        return const Locale('en', '');
      },
    );
  }
}
