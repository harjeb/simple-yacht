// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Игра Яхтзы';

  @override
  String get startGame => 'Начать Новую Игру';

  @override
  String get leaderboard => 'Таблица Лидеров';

  @override
  String get settings => 'Настройки';

  @override
  String personalBest(int score) {
    return 'Личный Рекорд: $score';
  }

  @override
  String player(String playerName) {
    return 'Игрок: $playerName';
  }

  @override
  String round(int currentRound, int totalRounds) {
    return 'Раунд: $currentRound/$totalRounds';
  }

  @override
  String rollsLeft(int rolls) {
    return 'Осталось Бросков: $rolls';
  }

  @override
  String get gameOver => 'ИГРА ОКОНЧЕНА';

  @override
  String get rollDice => 'Бросить Кости';

  @override
  String get scoreboard => 'Таблица Очков';

  @override
  String get resetGame => 'Сбросить Игру';

  @override
  String get nextTurn => 'Следующий Ход (Сначала выберите категорию!)';

  @override
  String get exitToHome => 'Выход в Главное Меню';

  @override
  String get aces => 'Единицы';

  @override
  String get twos => 'Двойки';

  @override
  String get threes => 'Тройки';

  @override
  String get fours => 'Четверки';

  @override
  String get fives => 'Пятерки';

  @override
  String get sixes => 'Шестерки';

  @override
  String get threeOfAKind => 'Три одинаковых';

  @override
  String get fourOfAKind => 'Каре';

  @override
  String get fullHouse => 'Фулл-хаус';

  @override
  String get smallStraight => 'Малый Стрейт';

  @override
  String get largeStraight => 'Большой Стрейт';

  @override
  String get yahtzee => 'Яхтзы';

  @override
  String get chance => 'Шанс';

  @override
  String get upperBonus => 'Верхний Бонус (если >= 63)';

  @override
  String get upperSubtotal => 'Верхняя Промежуточная Сумма';

  @override
  String get upperTotal => 'Верхний Итог';

  @override
  String get lowerTotal => 'Нижний Итог';

  @override
  String get yahtzeeBonusScore => 'Бонусные Очки Яхтзы';

  @override
  String get grandTotal => 'Общий Итог';

  @override
  String get dice => 'Кости';

  @override
  String get selectScoreCategoryPrompt => 'Ход завершен. Выберите категорию для записи очков.';

  @override
  String get leaderboardComingSoon => 'Таблица Лидеров (Скоро)';

  @override
  String get settingsComingSoon => 'Настройки (Скоро)';

  @override
  String get upperSectionTitle => 'Верхняя Секция';

  @override
  String get lowerSectionTitle => 'Нижняя Секция';

  @override
  String get continueGame => 'Продолжить игру';

  @override
  String get exitGameConfirmation => 'Вы уверены, что хотите выйти из текущей игры?';

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
  String get highScoreDisplay => 'Лучший Результат';

  @override
  String get yourPersonalBestScoreLabel => 'Ваш Личный Рекорд';

  @override
  String get noPersonalBestScore => 'Личного рекорда пока нет. Сыграйте игру!';

  @override
  String get scoreLabel => 'Счет';

  @override
  String get dateTimeLabel => 'Дата/Время';

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
  String get loadingLabel => 'Загрузка...';

  @override
  String get errorLabel => 'Ошибка';

  @override
  String get retryButtonLabel => 'Повторить';

  @override
  String get signInFailedGeneric => 'Ошибка входа. Проверьте подключение и попробуйте снова.';

  @override
  String get firestoreDatabaseNotConfiguredError => 'База данных бэкэнда не настроена. Пожалуйста, свяжитесь с администратором.';

  @override
  String get scoreSavedToLeaderboard => 'Score saved to leaderboard! (NEEDS RU TRANSLATION)';

  @override
  String get failedToSaveScore => 'Failed to save score (NEEDS RU TRANSLATION)';

  @override
  String get fix => 'Fix (NEEDS RU TRANSLATION)';

  @override
  String get scoreSavedUsingLocallyStoredUsername => 'Score saved using locally stored username. (NEEDS RU TRANSLATION)';

  @override
  String get usernameNotFoundScoreNotSaved => 'Username not found. Score not saved. (NEEDS RU TRANSLATION)';

  @override
  String errorRetrievingUsername(String details) {
    return 'Error retrieving username: $details (NEEDS RU TRANSLATION)';
  }

  @override
  String get errorFetchingUsername => 'Error fetching username (NEEDS RU TRANSLATION)';

  @override
  String get invalidGameStateRedirecting => 'Недопустимое состояние игры. Перенаправление на главный экран... (NEEDS RU TRANSLATION)';

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
