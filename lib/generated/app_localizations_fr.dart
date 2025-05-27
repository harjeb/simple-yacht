// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Jeu de Yahtzee';

  @override
  String get startGame => 'Commencer une Nouvelle Partie';

  @override
  String get leaderboard => 'Classement';

  @override
  String get settings => 'Paramètres';

  @override
  String personalBest(int score) {
    return 'Meilleur Score Personnel : $score';
  }

  @override
  String player(String playerName) {
    return 'Joueur : $playerName';
  }

  @override
  String round(int currentRound, int totalRounds) {
    return 'Manche : $currentRound/$totalRounds';
  }

  @override
  String rollsLeft(int rolls) {
    return 'Lancers Restants : $rolls';
  }

  @override
  String get gameOver => 'PARTIE TERMINÉE';

  @override
  String get rollDice => 'Lancer les Dés';

  @override
  String get scoreboard => 'Tableau des Scores';

  @override
  String get resetGame => 'Réinitialiser la Partie';

  @override
  String get nextTurn => 'Tour Suivant (Sélectionnez d\'abord une catégorie !)';

  @override
  String get exitToHome => 'Quitter vers l\'Accueil';

  @override
  String get aces => 'As';

  @override
  String get twos => 'Deux';

  @override
  String get threes => 'Trois';

  @override
  String get fours => 'Quatre';

  @override
  String get fives => 'Cinq';

  @override
  String get sixes => 'Six';

  @override
  String get threeOfAKind => 'Brelan';

  @override
  String get fourOfAKind => 'Carré';

  @override
  String get fullHouse => 'Full';

  @override
  String get smallStraight => 'Petite Suite';

  @override
  String get largeStraight => 'Grande Suite';

  @override
  String get yahtzee => 'Yahtzee';

  @override
  String get chance => 'Chance';

  @override
  String get upperBonus => 'Bonus Supérieur (si >= 63)';

  @override
  String get upperSubtotal => 'Sous-total Supérieur';

  @override
  String get upperTotal => 'Total Supérieur';

  @override
  String get lowerTotal => 'Total Inférieur';

  @override
  String get yahtzeeBonusScore => 'Score Bonus Yahtzee';

  @override
  String get grandTotal => 'Total Général';

  @override
  String get dice => 'Dés';

  @override
  String get selectScoreCategoryPrompt => 'Tour avancé. Sélectionnez une catégorie de score.';

  @override
  String get leaderboardComingSoon => 'Classement (Bientôt disponible)';

  @override
  String get settingsComingSoon => 'Paramètres (Bientôt disponible)';

  @override
  String get upperSectionTitle => 'Section Supérieure';

  @override
  String get lowerSectionTitle => 'Section Inférieure';

  @override
  String get continueGame => 'Continuer la partie';

  @override
  String get exitGameConfirmation => 'Êtes-vous sûr de vouloir quitter la partie en cours ?';

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
  String get highScoreDisplay => 'Meilleur Score';

  @override
  String get yourPersonalBestScoreLabel => 'Votre Meilleur Score Personnel';

  @override
  String get noPersonalBestScore => 'Pas encore de meilleur score personnel. Jouez une partie !';

  @override
  String get scoreLabel => 'Score';

  @override
  String get dateTimeLabel => 'Date/Heure';

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
  String get loadingLabel => 'Chargement...';

  @override
  String get errorLabel => 'Erreur';

  @override
  String get retryButtonLabel => 'Réessayer';

  @override
  String get signInFailedGeneric => 'La connexion a échoué. Veuillez vérifier votre connexion et réessayer.';

  @override
  String get firestoreDatabaseNotConfiguredError => 'La base de données backend n\'est pas configurée. Veuillez contacter l\'administrateur.';

  @override
  String get scoreSavedToLeaderboard => 'Score saved to leaderboard! (NEEDS FR TRANSLATION)';

  @override
  String get failedToSaveScore => 'Failed to save score (NEEDS FR TRANSLATION)';

  @override
  String get fix => 'Fix (NEEDS FR TRANSLATION)';

  @override
  String get scoreSavedUsingLocallyStoredUsername => 'Score saved using locally stored username. (NEEDS FR TRANSLATION)';

  @override
  String get usernameNotFoundScoreNotSaved => 'Username not found. Score not saved. (NEEDS FR TRANSLATION)';

  @override
  String errorRetrievingUsername(String details) {
    return 'Error retrieving username: $details (NEEDS FR TRANSLATION)';
  }

  @override
  String get errorFetchingUsername => 'Error fetching username (NEEDS FR TRANSLATION)';

  @override
  String get invalidGameStateRedirecting => 'État du jeu invalide. Redirection vers l\'accueil... (NEEDS FR TRANSLATION)';

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
