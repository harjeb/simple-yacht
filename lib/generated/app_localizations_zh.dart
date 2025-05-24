// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '快艇骰子';

  @override
  String get startGame => '开始新游戏';

  @override
  String get leaderboard => '排行榜';

  @override
  String get settings => '设置';

  @override
  String personalBest(int score) {
    return '个人最佳: $score';
  }

  @override
  String player(String playerName) {
    return '玩家: $playerName';
  }

  @override
  String round(int currentRound, int totalRounds) {
    return '回合: $currentRound/$totalRounds';
  }

  @override
  String rollsLeft(int rolls) {
    return '剩余投掷次数: $rolls';
  }

  @override
  String get gameOver => '游戏结束';

  @override
  String get rollDice => '掷骰子';

  @override
  String get scoreboard => '计分板';

  @override
  String get resetGame => '重置游戏';

  @override
  String get nextTurn => '下一回合 (请先选择计分项!)';

  @override
  String get exitToHome => '退出到主页';

  @override
  String get aces => '一点';

  @override
  String get twos => '二点';

  @override
  String get threes => '三点';

  @override
  String get fours => '四点';

  @override
  String get fives => '五点';

  @override
  String get sixes => '六点';

  @override
  String get threeOfAKind => '三条';

  @override
  String get fourOfAKind => '四条';

  @override
  String get fullHouse => '葫芦';

  @override
  String get smallStraight => '小顺子';

  @override
  String get largeStraight => '大顺子';

  @override
  String get yahtzee => 'Yahtzee (快艇)';

  @override
  String get chance => '机会';

  @override
  String get upperBonus => '上区奖励 (如果 >= 63)';

  @override
  String get upperSubtotal => '上区小计';

  @override
  String get upperTotal => '上区总计';

  @override
  String get lowerTotal => '下区总计';

  @override
  String get yahtzeeBonusScore => 'Yahtzee 奖励分';

  @override
  String get grandTotal => '总计';

  @override
  String get dice => '骰子';

  @override
  String get selectScoreCategoryPrompt => '回合结束。请选择一个计分项。';

  @override
  String get leaderboardComingSoon => '排行榜 (敬请期待)';

  @override
  String get settingsComingSoon => '设置 (敬请期待)';

  @override
  String get upperSectionTitle => '上部得分';

  @override
  String get lowerSectionTitle => '下部得分';

  @override
  String get continueGame => '继续游戏';

  @override
  String get exitGameConfirmation => '您确定要退出当前游戏吗？';

  @override
  String get leaderboardTitle => '排行榜';

  @override
  String get leaderboardEmpty => '排行榜当前为空。进行一场游戏来上榜吧！';

  @override
  String leaderboardScoreDate(String score, String date) {
    return '分数: $score\n日期: $date';
  }

  @override
  String leaderboardScorePoints(String score) {
    return '$score 分';
  }

  @override
  String leaderboardError(String errorDetails) {
    return '加载排行榜错误: $errorDetails';
  }

  @override
  String get leaderboardRefreshTooltip => '刷新排行榜';

  @override
  String get usernameSetupTitle => '设置您的用户名';

  @override
  String get usernameSetupPrompt => '请输入一个用户名，它将显示在排行榜上。';

  @override
  String get usernameLabel => '用户名';

  @override
  String get usernameHint => '输入您想要的用户名';

  @override
  String get usernameCannotBeEmpty => '用户名不能为空。';

  @override
  String get usernameValidationError => '请输入用户名。';

  @override
  String get usernameTooShortError => '用户名长度至少为3个字符。';

  @override
  String get usernameTooLongError => '用户名长度不能超过15个字符。';

  @override
  String get saveButtonLabel => '保存';

  @override
  String get highScoreDisplay => '最高分';

  @override
  String get yourPersonalBestScoreLabel => '您的个人最佳';

  @override
  String get noPersonalBestScore => '暂无个人最佳成绩，快来玩一局吧！';

  @override
  String get scoreLabel => '分数';

  @override
  String get dateTimeLabel => '日期/时间';
}
