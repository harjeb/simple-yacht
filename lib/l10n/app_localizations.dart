import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Yahtzee Game'**
  String get appTitle;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start New Game'**
  String get startGame;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Displays the player's personal best score
  ///
  /// In en, this message translates to:
  /// **'Personal Best: {score}'**
  String personalBest(int score);

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player: {playerName}'**
  String player(String playerName);

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round: {currentRound}/{totalRounds}'**
  String round(int currentRound, int totalRounds);

  /// No description provided for @rollsLeft.
  ///
  /// In en, this message translates to:
  /// **'Rolls Left: {rolls}'**
  String rollsLeft(int rolls);

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOver;

  /// No description provided for @rollDice.
  ///
  /// In en, this message translates to:
  /// **'Roll Dice'**
  String get rollDice;

  /// No description provided for @scoreboard.
  ///
  /// In en, this message translates to:
  /// **'Scoreboard'**
  String get scoreboard;

  /// No description provided for @resetGame.
  ///
  /// In en, this message translates to:
  /// **'Reset Game'**
  String get resetGame;

  /// No description provided for @nextTurn.
  ///
  /// In en, this message translates to:
  /// **'Next Turn (Select Score First!)'**
  String get nextTurn;

  /// No description provided for @exitToHome.
  ///
  /// In en, this message translates to:
  /// **'Exit to Home'**
  String get exitToHome;

  /// No description provided for @aces.
  ///
  /// In en, this message translates to:
  /// **'Aces'**
  String get aces;

  /// No description provided for @twos.
  ///
  /// In en, this message translates to:
  /// **'Twos'**
  String get twos;

  /// No description provided for @threes.
  ///
  /// In en, this message translates to:
  /// **'Threes'**
  String get threes;

  /// No description provided for @fours.
  ///
  /// In en, this message translates to:
  /// **'Fours'**
  String get fours;

  /// No description provided for @fives.
  ///
  /// In en, this message translates to:
  /// **'Fives'**
  String get fives;

  /// No description provided for @sixes.
  ///
  /// In en, this message translates to:
  /// **'Sixes'**
  String get sixes;

  /// No description provided for @threeOfAKind.
  ///
  /// In en, this message translates to:
  /// **'Three of a Kind'**
  String get threeOfAKind;

  /// No description provided for @fourOfAKind.
  ///
  /// In en, this message translates to:
  /// **'Four of a Kind'**
  String get fourOfAKind;

  /// No description provided for @fullHouse.
  ///
  /// In en, this message translates to:
  /// **'Full House'**
  String get fullHouse;

  /// No description provided for @smallStraight.
  ///
  /// In en, this message translates to:
  /// **'Small Straight'**
  String get smallStraight;

  /// No description provided for @largeStraight.
  ///
  /// In en, this message translates to:
  /// **'Large Straight'**
  String get largeStraight;

  /// No description provided for @yahtzee.
  ///
  /// In en, this message translates to:
  /// **'Yahtzee'**
  String get yahtzee;

  /// No description provided for @chance.
  ///
  /// In en, this message translates to:
  /// **'Chance'**
  String get chance;

  /// No description provided for @upperBonus.
  ///
  /// In en, this message translates to:
  /// **'Upper Bonus (if >= 63)'**
  String get upperBonus;

  /// No description provided for @upperSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Upper Subtotal'**
  String get upperSubtotal;

  /// No description provided for @upperTotal.
  ///
  /// In en, this message translates to:
  /// **'Upper Total'**
  String get upperTotal;

  /// No description provided for @lowerTotal.
  ///
  /// In en, this message translates to:
  /// **'Lower Total'**
  String get lowerTotal;

  /// No description provided for @yahtzeeBonusScore.
  ///
  /// In en, this message translates to:
  /// **'Yahtzee Bonus Score'**
  String get yahtzeeBonusScore;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @dice.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get dice;

  /// No description provided for @selectScoreCategoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Turn Advanced. Select a score category.'**
  String get selectScoreCategoryPrompt;

  /// No description provided for @leaderboardComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard (Coming Soon)'**
  String get leaderboardComingSoon;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings (Coming Soon)'**
  String get settingsComingSoon;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
