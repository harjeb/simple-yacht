import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _selectedLanguageCodeKey = 'selected_language_code';
const String _selectedCountryCodeKey = 'selected_country_code';

class LocaleNotifier extends StateNotifier<Locale?> {
  final Ref _ref;

  LocaleNotifier(this._ref) : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_selectedLanguageCodeKey);
    final countryCode = prefs.getString(_selectedCountryCodeKey);

    if (languageCode != null) {
      state = Locale(languageCode, countryCode);
    }
    // If no locale is saved, state remains null, and MaterialApp will use localeResolutionCallback.
  }

  Future<void> setLocale(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageCodeKey, newLocale.languageCode);
    if (newLocale.countryCode != null && newLocale.countryCode!.isNotEmpty) {
      await prefs.setString(_selectedCountryCodeKey, newLocale.countryCode!);
    } else {
      await prefs.remove(_selectedCountryCodeKey); // Remove if country code is null or empty
    }
    state = newLocale;
  }

  // Method to clear saved locale preference, reverting to system/default logic
  Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedLanguageCodeKey);
    await prefs.remove(_selectedCountryCodeKey);
    state = null;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref);
});