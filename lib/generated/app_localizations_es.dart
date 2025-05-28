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

  @override
  String get loadingLabel => 'Cargando...';

  @override
  String get errorLabel => 'Error';

  @override
  String get retryButtonLabel => 'Reintentar';

  @override
  String get signInFailedGeneric => 'Falló el inicio de sesión. Por favor, comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get firestoreDatabaseNotConfiguredError => 'La base de datos backend no está configurada. Por favor, contacte al administrador.';

  @override
  String get scoreSavedToLeaderboard => 'Score saved to leaderboard! (NEEDS ES TRANSLATION)';

  @override
  String get failedToSaveScore => 'Failed to save score (NEEDS ES TRANSLATION)';

  @override
  String get fix => 'Fix (NEEDS ES TRANSLATION)';

  @override
  String get scoreSavedUsingLocallyStoredUsername => 'Score saved using locally stored username. (NEEDS ES TRANSLATION)';

  @override
  String get usernameNotFoundScoreNotSaved => 'Username not found. Score not saved. (NEEDS ES TRANSLATION)';

  @override
  String errorRetrievingUsername(String details) {
    return 'Error retrieving username: $details (NEEDS ES TRANSLATION)';
  }

  @override
  String get errorFetchingUsername => 'Error fetching username (NEEDS ES TRANSLATION)';

  @override
  String get invalidGameStateRedirecting => 'Estado de juego inválido. Redirigiendo al inicio... (NEEDS ES TRANSLATION)';

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
