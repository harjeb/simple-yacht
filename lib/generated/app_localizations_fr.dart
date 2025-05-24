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
}
