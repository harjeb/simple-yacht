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

  @override
  String get authenticationError => '认证失败，请重启应用。';

  @override
  String get failedToSaveUsername => '保存用户名失败，请重试。';

  @override
  String get genericError => '发生未知错误，请重试。';

  @override
  String get recoveryCodeInvalid => '无效或已过期的引继码。';

  @override
  String get recoveryFailedError => '账户恢复失败。';

  @override
  String get recoverySignInFailed => '恢复后登录失败。';

  @override
  String get accountRecoveryTitle => '恢复账户';

  @override
  String get enterRecoveryCodePrompt => '请输入您的18位引继码。';

  @override
  String get recoveryCodeLabel => '引继码';

  @override
  String get recoveryCodeHint => '例如：ABCDE12345FGHIJ678';

  @override
  String get recoveryCodeCannotBeEmpty => '引继码不能为空。';

  @override
  String get recoveryCodeInvalidLength => '引继码必须是18位字符。';

  @override
  String get recoverAccountButtonLabel => '恢复账户';

  @override
  String get switchToRecoverAccountLabel => '已有引继码？恢复账户。';

  @override
  String get switchToCreateAccountLabel => '新用户？创建账户。';

  @override
  String get languageSettingsLabel => '语言设置';

  @override
  String get selectLanguageLabel => '选择语言';

  @override
  String get accountSectionTitle => '账户管理';

  @override
  String get recoveryCodeNotAvailable => '引继码不可用。请确保您的账户已设置。';

  @override
  String get yourRecoveryCode => '您的引继码：';

  @override
  String get copyRecoveryCode => '复制引继码';

  @override
  String get recoveryCodeCopied => '引继码已复制到剪贴板！';

  @override
  String get deleteAccountButtonLabel => '删除账户';

  @override
  String get deleteAccountDialogTitle => '删除账户？';

  @override
  String get deleteAccountDialogContent => '您确定要删除您的账户吗？此操作不可逆，您的所有数据（用户名、分数等）都将丢失。';

  @override
  String get confirmButtonLabel => '确认';

  @override
  String get deleteAccountSuccess => '账户删除成功。';

  @override
  String get deleteAccountError => '删除账户失败，请重试。';

  @override
  String genericErrorWithDetails(String details) {
    return '错误：$details';
  }

  @override
  String get loadingLabel => '加载中...';

  @override
  String get errorLabel => '错误';

  @override
  String get retryButtonLabel => '重试';

  @override
  String get signInFailedGeneric => '登录失败，请检查您的网络连接并稍后重试。';

  @override
  String get firestoreDatabaseNotConfiguredError => '后端数据库未配置，请联系管理员。';

  @override
  String get scoreSavedToLeaderboard => 'Score saved to leaderboard! (NEEDS ZH TRANSLATION)';

  @override
  String get failedToSaveScore => 'Failed to save score (NEEDS ZH TRANSLATION)';

  @override
  String get fix => 'Fix (NEEDS ZH TRANSLATION)';

  @override
  String get scoreSavedUsingLocallyStoredUsername => 'Score saved using locally stored username. (NEEDS ZH TRANSLATION)';

  @override
  String get usernameNotFoundScoreNotSaved => 'Username not found. Score not saved. (NEEDS ZH TRANSLATION)';

  @override
  String errorRetrievingUsername(String details) {
    return 'Error retrieving username: $details (NEEDS ZH TRANSLATION)';
  }

  @override
  String get errorFetchingUsername => 'Error fetching username (NEEDS ZH TRANSLATION)';

  @override
  String get invalidGameStateRedirecting => '无效的游戏状态。正在重定向到主页...';

  @override
  String get clearLocalDataDialogTitle => '清空本地数据？';

  @override
  String get clearLocalDataDialogContent => '此操作将从此设备上移除您的账户信息、游戏进度和设置。您的账户本身不会被删除，您仍可以使用引继码在任何设备上恢复它。确定要继续吗？';

  @override
  String get confirmClearButtonLabel => '确认清除';

  @override
  String get clearLocalDataButtonLabel => '清空此设备上的账户数据';

  @override
  String get clearLocalDataSuccessMessage => '本地数据已成功清除。';

  @override
  String get clearLocalDataErrorMessage => '清除本地数据失败';
}
