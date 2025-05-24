// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ヤッツィーゲーム';

  @override
  String get startGame => '新しいゲームを開始';

  @override
  String get leaderboard => 'リーダーボード';

  @override
  String get settings => '設定';

  @override
  String personalBest(int score) {
    return '自己ベスト: $score';
  }

  @override
  String player(String playerName) {
    return 'プレイヤー: $playerName';
  }

  @override
  String round(int currentRound, int totalRounds) {
    return 'ラウンド: $currentRound/$totalRounds';
  }

  @override
  String rollsLeft(int rolls) {
    return '残りロール数: $rolls';
  }

  @override
  String get gameOver => 'ゲームオーバー';

  @override
  String get rollDice => 'サイコロを振る';

  @override
  String get scoreboard => 'スコアボード';

  @override
  String get resetGame => 'ゲームをリセット';

  @override
  String get nextTurn => '次のターン (最初にスコアカテゴリを選択してください!)';

  @override
  String get exitToHome => 'ホームに戻る';

  @override
  String get aces => 'エース (1の目)';

  @override
  String get twos => '2の目';

  @override
  String get threes => '3の目';

  @override
  String get fours => '4の目';

  @override
  String get fives => '5の目';

  @override
  String get sixes => '6の目';

  @override
  String get threeOfAKind => 'スリーカード';

  @override
  String get fourOfAKind => 'フォーカード';

  @override
  String get fullHouse => 'フルハウス';

  @override
  String get smallStraight => 'スモールストレート';

  @override
  String get largeStraight => 'ラージストレート';

  @override
  String get yahtzee => 'ヤッツィー';

  @override
  String get chance => 'チャンス';

  @override
  String get upperBonus => 'アッパーセクションボーナス (63点以上の場合)';

  @override
  String get upperSubtotal => 'アッパーセクション小計';

  @override
  String get upperTotal => 'アッパーセクション合計';

  @override
  String get lowerTotal => 'ロワーセクション合計';

  @override
  String get yahtzeeBonusScore => 'ヤッツィーボーナススコア';

  @override
  String get grandTotal => '総計';

  @override
  String get dice => 'サイコロ';

  @override
  String get selectScoreCategoryPrompt => 'ターンが進みました。スコアカテゴリを選択してください。';

  @override
  String get leaderboardComingSoon => 'リーダーボード (近日公開)';

  @override
  String get settingsComingSoon => '設定 (近日公開)';

  @override
  String get upperSectionTitle => '上部セクション';

  @override
  String get lowerSectionTitle => '下部セクション';

  @override
  String get continueGame => 'ゲームを続ける';

  @override
  String get exitGameConfirmation => '現在のゲームを終了してもよろしいですか？';

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
  String get highScoreDisplay => '最高スコア';

  @override
  String get yourPersonalBestScoreLabel => 'あなたの自己ベスト';

  @override
  String get noPersonalBestScore => '自己ベストスコアはまだありません。ゲームをプレイしましょう！';

  @override
  String get scoreLabel => 'スコア';

  @override
  String get dateTimeLabel => '日時';
}
