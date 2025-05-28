import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';
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
/// import 'gen_l10n/app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Yahtzee Game'**
  String get appTitle;

  /// Start game button
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
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

  /// No description provided for @upperSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Upper Section'**
  String get upperSectionTitle;

  /// No description provided for @lowerSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Lower Section'**
  String get lowerSectionTitle;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue Game'**
  String get continueGame;

  /// No description provided for @exitGameConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the current game?'**
  String get exitGameConfirmation;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'The leaderboard is currently empty. Play a game to get on the board!'**
  String get leaderboardEmpty;

  /// Displays score and date for a leaderboard entry
  ///
  /// In en, this message translates to:
  /// **'Score: {score}\nDate: {date}'**
  String leaderboardScoreDate(String score, String date);

  /// Displays score in points format for a leaderboard entry
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String leaderboardScorePoints(String score);

  /// Error message when leaderboard fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading leaderboard: {errorDetails}'**
  String leaderboardError(String errorDetails);

  /// No description provided for @leaderboardRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh Leaderboard'**
  String get leaderboardRefreshTooltip;

  /// No description provided for @usernameSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Username'**
  String get usernameSetupTitle;

  /// No description provided for @usernameSetupPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username to be displayed on the leaderboard.'**
  String get usernameSetupPrompt;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your desired username'**
  String get usernameHint;

  /// No description provided for @usernameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty.'**
  String get usernameCannotBeEmpty;

  /// No description provided for @usernameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get usernameValidationError;

  /// No description provided for @usernameTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters long.'**
  String get usernameTooShortError;

  /// No description provided for @usernameTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be more than 15 characters long.'**
  String get usernameTooLongError;

  /// No description provided for @saveButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButtonLabel;

  /// Label for the high score display section on the home screen
  ///
  /// In en, this message translates to:
  /// **'High Score'**
  String get highScoreDisplay;

  /// Label for the personal best score display
  ///
  /// In en, this message translates to:
  /// **'Your Personal Best'**
  String get yourPersonalBestScoreLabel;

  /// Message displayed when there is no personal best score
  ///
  /// In en, this message translates to:
  /// **'No personal best score yet. Play a game!'**
  String get noPersonalBestScore;

  /// Label for the score value
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// Label for the date and time of the score
  ///
  /// In en, this message translates to:
  /// **'Date/Time'**
  String get dateTimeLabel;

  /// Error message shown when user authentication fails during username setup.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please restart the app.'**
  String get authenticationError;

  /// Error message shown when saving username to backend fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to save username. Please try again.'**
  String get failedToSaveUsername;

  /// Generic error message for unexpected issues.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get genericError;

  /// Error message for invalid recovery code.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired recovery code.'**
  String get recoveryCodeInvalid;

  /// Generic error message for account recovery failure.
  ///
  /// In en, this message translates to:
  /// **'Account recovery failed.'**
  String get recoveryFailedError;

  /// Error message when sign-in after recovery fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in after recovery.'**
  String get recoverySignInFailed;

  /// Title for the account recovery screen.
  ///
  /// In en, this message translates to:
  /// **'Recover Account'**
  String get accountRecoveryTitle;

  /// Prompt for user to enter their recovery code.
  ///
  /// In en, this message translates to:
  /// **'Enter your 18-character recovery code.'**
  String get enterRecoveryCodePrompt;

  /// Label for the recovery code input field.
  ///
  /// In en, this message translates to:
  /// **'Recovery Code'**
  String get recoveryCodeLabel;

  /// Hint text for the recovery code input field.
  ///
  /// In en, this message translates to:
  /// **'e.g., ABCDE12345FGHIJ678'**
  String get recoveryCodeHint;

  /// Validation error for empty recovery code.
  ///
  /// In en, this message translates to:
  /// **'Recovery code cannot be empty.'**
  String get recoveryCodeCannotBeEmpty;

  /// Validation error for incorrect recovery code length.
  ///
  /// In en, this message translates to:
  /// **'Recovery code must be 18 characters.'**
  String get recoveryCodeInvalidLength;

  /// Label for the recover account button.
  ///
  /// In en, this message translates to:
  /// **'Recover Account'**
  String get recoverAccountButtonLabel;

  /// Label for the button to switch to recovery mode.
  ///
  /// In en, this message translates to:
  /// **'Have a recovery code? Recover account.'**
  String get switchToRecoverAccountLabel;

  /// Label for the button to switch to create account mode.
  ///
  /// In en, this message translates to:
  /// **'New user? Create an account.'**
  String get switchToCreateAccountLabel;

  /// Label for the language settings section title.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettingsLabel;

  /// Label for the language selection dropdown.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageLabel;

  /// Title for the account management section.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountSectionTitle;

  /// Message shown when recovery code is not available.
  ///
  /// In en, this message translates to:
  /// **'Recovery code not available. Please ensure your account is set up.'**
  String get recoveryCodeNotAvailable;

  /// Label for displaying the user's recovery code.
  ///
  /// In en, this message translates to:
  /// **'Your Recovery Code:'**
  String get yourRecoveryCode;

  /// Label for the copy recovery code button.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyRecoveryCode;

  /// Snackbar message when recovery code is copied.
  ///
  /// In en, this message translates to:
  /// **'Recovery code copied to clipboard!'**
  String get recoveryCodeCopied;

  /// Label for the delete account button.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountButtonLabel;

  /// Title for the delete account confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountDialogTitle;

  /// Content/warning message for the delete account confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is irreversible and all your data (username, scores, etc.) will be lost.'**
  String get deleteAccountDialogContent;

  /// Label for the confirm button in dialogs.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButtonLabel;

  /// Snackbar message when account deletion is successful.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get deleteAccountSuccess;

  /// Snackbar message when account deletion fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get deleteAccountError;

  /// Generic error message that includes details.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String genericErrorWithDetails(String details);

  /// Text shown when content is loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// Text shown when an error occurs
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// Label for a button to retry an action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButtonLabel;

  /// Generic message for sign-in failure
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get signInFailedGeneric;

  /// Error message shown when the Firestore database is not found or not configured.
  ///
  /// In en, this message translates to:
  /// **'Backend database is not configured. Please contact administrator.'**
  String get firestoreDatabaseNotConfiguredError;

  /// Snackbar message when score is successfully saved to the leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Score saved to leaderboard!'**
  String get scoreSavedToLeaderboard;

  /// Part of a generic error message, indicating the action that failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save score'**
  String get failedToSaveScore;

  /// Label for a button that offers to fix an issue, e.g., navigate to settings.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get fix;

  /// Snackbar message when score is saved using a username from local storage.
  ///
  /// In en, this message translates to:
  /// **'Score saved using locally stored username.'**
  String get scoreSavedUsingLocallyStoredUsername;

  /// Snackbar message when username is not found locally and score cannot be saved.
  ///
  /// In en, this message translates to:
  /// **'Username not found. Score not saved.'**
  String get usernameNotFoundScoreNotSaved;

  /// Error message when retrieving username from local storage fails.
  ///
  /// In en, this message translates to:
  /// **'Error retrieving username: {details}'**
  String errorRetrievingUsername(String details);

  /// Part of a generic error message, indicating the action that failed during username fetch from provider.
  ///
  /// In en, this message translates to:
  /// **'Error fetching username'**
  String get errorFetchingUsername;

  /// Message shown when the game state is invalid and the user is redirected to the home screen.
  ///
  /// In en, this message translates to:
  /// **'Invalid game state. Redirecting to home...'**
  String get invalidGameStateRedirecting;

  /// Title for the clear local data confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Clear Local Data?'**
  String get clearLocalDataDialogTitle;

  /// Content/warning message for the clear local data confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This action will remove your account information, game progress, and settings from this device. Your account itself will not be deleted, and you can still recover it using your recovery code on any device. Are you sure you want to proceed?'**
  String get clearLocalDataDialogContent;

  /// Label for the confirm clear button in the clear local data dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm Clear'**
  String get confirmClearButtonLabel;

  /// Label for the button to clear local account data.
  ///
  /// In en, this message translates to:
  /// **'Clear Account Data on This Device'**
  String get clearLocalDataButtonLabel;

  /// Snackbar message when local data clearing is successful.
  ///
  /// In en, this message translates to:
  /// **'Local data has been successfully cleared.'**
  String get clearLocalDataSuccessMessage;

  /// Snackbar message when local data clearing fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear local data'**
  String get clearLocalDataErrorMessage;

  /// Title for the multiplayer lobby screen
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Lobby'**
  String get multiplayerLobby;

  /// Label for quick match button
  ///
  /// In en, this message translates to:
  /// **'Quick Match'**
  String get quickMatch;

  /// Label for create room button
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// Label for join room button
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get joinRoom;

  /// Display online player count
  ///
  /// In en, this message translates to:
  /// **'Online Players: {count}'**
  String onlinePlayers(int count);

  /// Room code label
  ///
  /// In en, this message translates to:
  /// **'Room Code'**
  String get roomCode;

  /// Message when waiting for other players to join room
  ///
  /// In en, this message translates to:
  /// **'Waiting for players to join...'**
  String get waitingForPlayers;

  /// Message before game starts
  ///
  /// In en, this message translates to:
  /// **'Game starting'**
  String get gameStarting;

  /// Message when it's current player's turn
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get yourTurn;

  /// Message when it's opponent's turn
  ///
  /// In en, this message translates to:
  /// **'Opponent\'s turn'**
  String get opponentTurn;

  /// Multiplayer game button label
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Game'**
  String get multiplayerGame;

  /// Player ready status
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get playerReady;

  /// Player not ready status
  ///
  /// In en, this message translates to:
  /// **'Not Ready'**
  String get playerNotReady;

  /// Leave room button
  ///
  /// In en, this message translates to:
  /// **'Leave Room'**
  String get leaveRoom;

  /// Room host identifier
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get roomHost;

  /// Copy room code button
  ///
  /// In en, this message translates to:
  /// **'Copy Room Code'**
  String get copyRoomCode;

  /// Room code copied success message
  ///
  /// In en, this message translates to:
  /// **'Room code copied'**
  String get roomCodeCopied;

  /// Enter room code prompt
  ///
  /// In en, this message translates to:
  /// **'Enter room code'**
  String get enterRoomCode;

  /// Invalid room code message
  ///
  /// In en, this message translates to:
  /// **'Invalid room code'**
  String get invalidRoomCode;

  /// Room not found message
  ///
  /// In en, this message translates to:
  /// **'Room not found'**
  String get roomNotFound;

  /// Connection lost message
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get connectionLost;

  /// Reconnecting message
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get reconnecting;

  /// Game result title
  ///
  /// In en, this message translates to:
  /// **'Game Result'**
  String get gameResult;

  /// Win message
  ///
  /// In en, this message translates to:
  /// **'You Win!'**
  String get youWin;

  /// Lose message
  ///
  /// In en, this message translates to:
  /// **'You Lose'**
  String get youLose;

  /// Draw message
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get gameDraw;

  /// Play again button
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// Back to lobby button
  ///
  /// In en, this message translates to:
  /// **'Back to Lobby'**
  String get backToLobby;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'ja', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'ja': return AppLocalizationsJa();
    case 'ru': return AppLocalizationsRu();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
