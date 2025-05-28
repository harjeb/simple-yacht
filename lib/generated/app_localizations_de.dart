// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Yahtzee Spiel';

  @override
  String get startGame => 'Neues Spiel Starten';

  @override
  String get leaderboard => 'Bestenliste';

  @override
  String get settings => 'Einstellungen';

  @override
  String personalBest(int score) {
    return 'Persönliche Bestleistung: $score';
  }

  @override
  String player(String playerName) {
    return 'Spieler: $playerName';
  }

  @override
  String round(int currentRound, int totalRounds) {
    return 'Runde: $currentRound/$totalRounds';
  }

  @override
  String rollsLeft(int rolls) {
    return 'Verbleibende Würfe: $rolls';
  }

  @override
  String get gameOver => 'SPIEL BEENDET';

  @override
  String get rollDice => 'Würfeln';

  @override
  String get scoreboard => 'Punktetabelle';

  @override
  String get resetGame => 'Spiel Zurücksetzen';

  @override
  String get nextTurn => 'Nächster Zug (Wähle zuerst eine Kategorie!)';

  @override
  String get exitToHome => 'Verlassen zum Startbildschirm';

  @override
  String get aces => 'Einser';

  @override
  String get twos => 'Zweier';

  @override
  String get threes => 'Dreier';

  @override
  String get fours => 'Vierer';

  @override
  String get fives => 'Fünfer';

  @override
  String get sixes => 'Sechser';

  @override
  String get threeOfAKind => 'Drilling';

  @override
  String get fourOfAKind => 'Vierling';

  @override
  String get fullHouse => 'Full House';

  @override
  String get smallStraight => 'Kleine Straße';

  @override
  String get largeStraight => 'Große Straße';

  @override
  String get yahtzee => 'Yahtzee';

  @override
  String get chance => 'Chance';

  @override
  String get upperBonus => 'Bonus Oberer Teil (wenn >= 63)';

  @override
  String get upperSubtotal => 'Zwischensumme Oberer Teil';

  @override
  String get upperTotal => 'Gesamt Oberer Teil';

  @override
  String get lowerTotal => 'Gesamt Unterer Teil';

  @override
  String get yahtzeeBonusScore => 'Yahtzee Bonus Punkte';

  @override
  String get grandTotal => 'Gesamtsumme';

  @override
  String get dice => 'Würfel';

  @override
  String get selectScoreCategoryPrompt => 'Zug fortgeschritten. Wähle eine Punktekategorie.';

  @override
  String get leaderboardComingSoon => 'Bestenliste (Demnächst verfügbar)';

  @override
  String get settingsComingSoon => 'Einstellungen (Demnächst verfügbar)';

  @override
  String get upperSectionTitle => 'Oberer Bereich';

  @override
  String get lowerSectionTitle => 'Unterer Bereich';

  @override
  String get continueGame => 'Spiel fortsetzen';

  @override
  String get exitGameConfirmation => 'Sind Sie sicher, dass Sie das aktuelle Spiel verlassen möchten?';

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
  String get highScoreDisplay => 'Höchstpunktzahl';

  @override
  String get yourPersonalBestScoreLabel => 'Deine Persönliche Bestleistung';

  @override
  String get noPersonalBestScore => 'Noch keine persönliche Bestleistung. Spiel ein Spiel!';

  @override
  String get scoreLabel => 'Punktzahl';

  @override
  String get dateTimeLabel => 'Datum/Zeit';

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
  String get loadingLabel => 'Wird geladen...';

  @override
  String get errorLabel => 'Fehler';

  @override
  String get retryButtonLabel => 'Wiederholen';

  @override
  String get signInFailedGeneric => 'Anmeldung fehlgeschlagen. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get firestoreDatabaseNotConfiguredError => 'Backend-Datenbank ist nicht konfiguriert. Bitte kontaktieren Sie den Administrator.';

  @override
  String get scoreSavedToLeaderboard => 'Score saved to leaderboard! (NEEDS DE TRANSLATION)';

  @override
  String get failedToSaveScore => 'Failed to save score (NEEDS DE TRANSLATION)';

  @override
  String get fix => 'Fix (NEEDS DE TRANSLATION)';

  @override
  String get scoreSavedUsingLocallyStoredUsername => 'Score saved using locally stored username. (NEEDS DE TRANSLATION)';

  @override
  String get usernameNotFoundScoreNotSaved => 'Username not found. Score not saved. (NEEDS DE TRANSLATION)';

  @override
  String errorRetrievingUsername(String details) {
    return 'Error retrieving username: $details (NEEDS DE TRANSLATION)';
  }

  @override
  String get errorFetchingUsername => 'Error fetching username (NEEDS DE TRANSLATION)';

  @override
  String get invalidGameStateRedirecting => 'Ungültiger Spielstatus. Weiterleitung zur Startseite... (NEEDS DE TRANSLATION)';

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

  @override
  String get multiplayerLobby => 'Multiplayer Lobby';

  @override
  String get quickMatch => 'Quick Match';

  @override
  String get createRoom => 'Create Room';

  @override
  String get joinRoom => 'Join Room';

  @override
  String onlinePlayers(int count) {
    return 'Online Players: $count';
  }

  @override
  String get roomCode => 'Room Code';

  @override
  String get waitingForPlayers => 'Waiting for players to join...';

  @override
  String get gameStarting => 'Game starting';

  @override
  String get yourTurn => 'Your turn';

  @override
  String get opponentTurn => 'Opponent\'s turn';

  @override
  String get multiplayerGame => 'Multiplayer Game';

  @override
  String get playerReady => 'Ready';

  @override
  String get playerNotReady => 'Not Ready';

  @override
  String get leaveRoom => 'Leave Room';

  @override
  String get roomHost => 'Host';

  @override
  String get copyRoomCode => 'Copy Room Code';

  @override
  String get roomCodeCopied => 'Room code copied';

  @override
  String get enterRoomCode => 'Enter room code';

  @override
  String get invalidRoomCode => 'Invalid room code';

  @override
  String get roomNotFound => 'Room not found';

  @override
  String get connectionLost => 'Connection lost';

  @override
  String get reconnecting => 'Reconnecting...';

  @override
  String get gameResult => 'Game Result';

  @override
  String get youWin => 'You Win!';

  @override
  String get youLose => 'You Lose';

  @override
  String get gameDraw => 'Draw';

  @override
  String get playAgain => 'Play Again';

  @override
  String get backToLobby => 'Back to Lobby';
}
