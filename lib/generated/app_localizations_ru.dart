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
}
