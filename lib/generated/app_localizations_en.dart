// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Yahtzee Game';

  @override
  String get startGame => 'Start New Game';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get settings => 'Settings';

  @override
  String personalBest(int score) {
    return 'Personal Best: $score';
  }

  @override
  String player(String playerName) {
    return 'Player: $playerName';
  }

  @override
  String round(int currentRound, int totalRounds) {
    return 'Round: $currentRound/$totalRounds';
  }

  @override
  String rollsLeft(int rolls) {
    return 'Rolls Left: $rolls';
  }

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get rollDice => 'Roll Dice';

  @override
  String get scoreboard => 'Scoreboard';

  @override
  String get resetGame => 'Reset Game';

  @override
  String get nextTurn => 'Next Turn (Select Score First!)';

  @override
  String get exitToHome => 'Exit to Home';

  @override
  String get aces => 'Aces';

  @override
  String get twos => 'Twos';

  @override
  String get threes => 'Threes';

  @override
  String get fours => 'Fours';

  @override
  String get fives => 'Fives';

  @override
  String get sixes => 'Sixes';

  @override
  String get threeOfAKind => 'Three of a Kind';

  @override
  String get fourOfAKind => 'Four of a Kind';

  @override
  String get fullHouse => 'Full House';

  @override
  String get smallStraight => 'Small Straight';

  @override
  String get largeStraight => 'Large Straight';

  @override
  String get yahtzee => 'Yahtzee';

  @override
  String get chance => 'Chance';

  @override
  String get upperBonus => 'Upper Bonus (if >= 63)';

  @override
  String get upperSubtotal => 'Upper Subtotal';

  @override
  String get upperTotal => 'Upper Total';

  @override
  String get lowerTotal => 'Lower Total';

  @override
  String get yahtzeeBonusScore => 'Yahtzee Bonus Score';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get dice => 'Dice';

  @override
  String get selectScoreCategoryPrompt => 'Turn Advanced. Select a score category.';

  @override
  String get leaderboardComingSoon => 'Leaderboard (Coming Soon)';

  @override
  String get settingsComingSoon => 'Settings (Coming Soon)';

  @override
  String get upperSectionTitle => 'Upper Section';

  @override
  String get lowerSectionTitle => 'Lower Section';

  @override
  String get continueGame => 'Continue Game';

  @override
  String get exitGameConfirmation => 'Are you sure you want to exit the current game?';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardEmpty => 'The leaderboard is currently empty. Play a game to get on the board!';

  @override
  String leaderboardScoreDate(String score, String date) {
    return 'Score: $score\nDate: $date';
  }

  @override
  String leaderboardScorePoints(String score) {
    return '$score pts';
  }

  @override
  String leaderboardError(String errorDetails) {
    return 'Error loading leaderboard: $errorDetails';
  }

  @override
  String get leaderboardRefreshTooltip => 'Refresh Leaderboard';

  @override
  String get usernameSetupTitle => 'Set Your Username';

  @override
  String get usernameSetupPrompt => 'Please enter a username to be displayed on the leaderboard.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Enter your desired username';

  @override
  String get usernameCannotBeEmpty => 'Username cannot be empty.';

  @override
  String get usernameValidationError => 'Please enter a username.';

  @override
  String get usernameTooShortError => 'Username must be at least 3 characters long.';

  @override
  String get usernameTooLongError => 'Username cannot be more than 15 characters long.';

  @override
  String get saveButtonLabel => 'Save';

  @override
  String get highScoreDisplay => 'High Score';

  @override
  String get yourPersonalBestScoreLabel => 'Your Personal Best';

  @override
  String get noPersonalBestScore => 'No personal best score yet. Play a game!';

  @override
  String get scoreLabel => 'Score';

  @override
  String get dateTimeLabel => 'Date/Time';

  @override
  String get authenticationError => 'Authentication error. Please restart the app.';

  @override
  String get failedToSaveUsername => 'Failed to save username. Please try again.';

  @override
  String get genericError => 'An unexpected error occurred. Please try again.';

  @override
  String get recoveryCodeInvalid => 'Invalid or expired recovery code.';

  @override
  String get recoveryFailedError => 'Account recovery failed.';

  @override
  String get recoverySignInFailed => 'Failed to sign in after recovery.';

  @override
  String get accountRecoveryTitle => 'Recover Account';

  @override
  String get enterRecoveryCodePrompt => 'Enter your 18-character recovery code.';

  @override
  String get recoveryCodeLabel => 'Recovery Code';

  @override
  String get recoveryCodeHint => 'e.g., ABCDE12345FGHIJ678';

  @override
  String get recoveryCodeCannotBeEmpty => 'Recovery code cannot be empty.';

  @override
  String get recoveryCodeInvalidLength => 'Recovery code must be 18 characters.';

  @override
  String get recoverAccountButtonLabel => 'Recover Account';

  @override
  String get switchToRecoverAccountLabel => 'Have a recovery code? Recover account.';

  @override
  String get switchToCreateAccountLabel => 'New user? Create an account.';

  @override
  String get languageSettingsLabel => 'Language Settings';

  @override
  String get selectLanguageLabel => 'Select Language';

  @override
  String get accountSectionTitle => 'Account Management';

  @override
  String get recoveryCodeNotAvailable => 'Recovery code not available. Please ensure your account is set up.';

  @override
  String get yourRecoveryCode => 'Your Recovery Code:';

  @override
  String get copyRecoveryCode => 'Copy Code';

  @override
  String get recoveryCodeCopied => 'Recovery code copied to clipboard!';

  @override
  String get deleteAccountButtonLabel => 'Delete Account';

  @override
  String get deleteAccountDialogTitle => 'Delete Account?';

  @override
  String get deleteAccountDialogContent => 'Are you sure you want to delete your account? This action is irreversible and all your data (username, scores, etc.) will be lost.';

  @override
  String get confirmButtonLabel => 'Confirm';

  @override
  String get deleteAccountSuccess => 'Account deleted successfully.';

  @override
  String get deleteAccountError => 'Failed to delete account. Please try again.';

  @override
  String genericErrorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get loadingLabel => 'Loading...';

  @override
  String get errorLabel => 'Error';

  @override
  String get retryButtonLabel => 'Retry';

  @override
  String get signInFailedGeneric => 'Sign-in failed. Please try again.';

  @override
  String get firestoreDatabaseNotConfiguredError => 'Backend database is not configured. Please contact administrator.';

  @override
  String get scoreSavedToLeaderboard => 'Score saved to leaderboard!';

  @override
  String get failedToSaveScore => 'Failed to save score';

  @override
  String get fix => 'Fix';

  @override
  String get scoreSavedUsingLocallyStoredUsername => 'Score saved using locally stored username.';

  @override
  String get usernameNotFoundScoreNotSaved => 'Username not found. Score not saved.';

  @override
  String errorRetrievingUsername(String details) {
    return 'Error retrieving username: $details';
  }

  @override
  String get errorFetchingUsername => 'Error fetching username';

  @override
  String get invalidGameStateRedirecting => 'Invalid game state. Redirecting to home...';

  @override
  String get clearLocalDataDialogTitle => 'Clear Local Data?';

  @override
  String get clearLocalDataDialogContent => 'This action will remove your account information, game progress, and settings from this device. Your account itself will not be deleted, and you can still recover it using your recovery code on any device. Are you sure you want to proceed?';

  @override
  String get confirmClearButtonLabel => 'Confirm Clear';

  @override
  String get clearLocalDataButtonLabel => 'Clear Account Data on This Device';

  @override
  String get clearLocalDataSuccessMessage => 'Local data has been successfully cleared.';

  @override
  String get clearLocalDataErrorMessage => 'Failed to clear local data';
}
