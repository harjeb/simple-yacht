// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Juego de Yahtzee';

  @override
  String get startGame => 'Empezar Nuevo Juego';

  @override
  String get leaderboard => 'Tabla de Líderes';

  @override
  String get settings => 'Ajustes';

  @override
  String personalBest(int score) {
    return 'Mejor Personal: $score';
  }

  @override
  String player(String playerName) {
    return 'Jugador: $playerName';
  }

  @override
  String round(int currentRound, int totalRounds) {
    return 'Ronda: $currentRound/$totalRounds';
  }

  @override
  String rollsLeft(int rolls) {
    return 'Tiradas Restantes: $rolls';
  }

  @override
  String get gameOver => 'JUEGO TERMINADO';

  @override
  String get rollDice => 'Lanzar Dados';

  @override
  String get scoreboard => 'Tabla de Puntuación';

  @override
  String get resetGame => 'Reiniciar Juego';

  @override
  String get nextTurn => 'Siguiente Turno (¡Selecciona Puntuación Primero!)';

  @override
  String get exitToHome => 'Salir al Inicio';

  @override
  String get aces => 'Ases';

  @override
  String get twos => 'Doses';

  @override
  String get threes => 'Treses';

  @override
  String get fours => 'Cuatros';

  @override
  String get fives => 'Cincos';

  @override
  String get sixes => 'Seises';

  @override
  String get threeOfAKind => 'Trío';

  @override
  String get fourOfAKind => 'Póker';

  @override
  String get fullHouse => 'Full House';

  @override
  String get smallStraight => 'Escalera Pequeña';

  @override
  String get largeStraight => 'Escalera Grande';

  @override
  String get yahtzee => 'Yahtzee';

  @override
  String get chance => 'Chance';

  @override
  String get upperBonus => 'Bonificación Superior (si >= 63)';

  @override
  String get upperSubtotal => 'Subtotal Superior';

  @override
  String get upperTotal => 'Total Superior';

  @override
  String get lowerTotal => 'Total Inferior';

  @override
  String get yahtzeeBonusScore => 'Puntuación de Bonificación Yahtzee';

  @override
  String get grandTotal => 'Total General';

  @override
  String get dice => 'Dados';

  @override
  String get selectScoreCategoryPrompt => 'Turno Avanzado. Selecciona una categoría de puntuación.';

  @override
  String get leaderboardComingSoon => 'Tabla de Líderes (Próximamente)';

  @override
  String get settingsComingSoon => 'Ajustes (Próximamente)';

  @override
  String get upperSectionTitle => 'Sección Superior';

  @override
  String get lowerSectionTitle => 'Sección Inferior';

  @override
  String get continueGame => 'Continuar Juego';

  @override
  String get exitGameConfirmation => '¿Estás seguro de que quieres salir del juego actual?';

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
  String get highScoreDisplay => 'Puntuación Más Alta';

  @override
  String get yourPersonalBestScoreLabel => 'Tu Mejor Puntuación Personal';

  @override
  String get noPersonalBestScore => 'Aún no tienes mejor puntuación personal. ¡Juega una partida!';

  @override
  String get scoreLabel => 'Puntuación';

  @override
  String get dateTimeLabel => 'Fecha/Hora';

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
}
