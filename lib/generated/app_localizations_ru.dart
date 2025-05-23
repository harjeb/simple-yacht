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
}
