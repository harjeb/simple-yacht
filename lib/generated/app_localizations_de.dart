// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Yahtzee Spiel';

  @override
  String get startGame => 'Neues Spiel Starten';

  @override
  String get leaderboard => 'Bestenliste';

  @override
  String get settings => 'Einstellungen';

  @override
  String personalBest(int score) {
    return 'Persönliche Bestleistung: $score';
  }

  @override
  String player(String playerName) {
    return 'Spieler: $playerName';
  }

  @override
  String round(int currentRound, int totalRounds) {
    return 'Runde: $currentRound/$totalRounds';
  }

  @override
  String rollsLeft(int rolls) {
    return 'Verbleibende Würfe: $rolls';
  }

  @override
  String get gameOver => 'SPIEL BEENDET';

  @override
  String get rollDice => 'Würfeln';

  @override
  String get scoreboard => 'Punktetabelle';

  @override
  String get resetGame => 'Spiel Zurücksetzen';

  @override
  String get nextTurn => 'Nächster Zug (Wähle zuerst eine Kategorie!)';

  @override
  String get exitToHome => 'Verlassen zum Startbildschirm';

  @override
  String get aces => 'Einser';

  @override
  String get twos => 'Zweier';

  @override
  String get threes => 'Dreier';

  @override
  String get fours => 'Vierer';

  @override
  String get fives => 'Fünfer';

  @override
  String get sixes => 'Sechser';

  @override
  String get threeOfAKind => 'Drilling';

  @override
  String get fourOfAKind => 'Vierling';

  @override
  String get fullHouse => 'Full House';

  @override
  String get smallStraight => 'Kleine Straße';

  @override
  String get largeStraight => 'Große Straße';

  @override
  String get yahtzee => 'Yahtzee';

  @override
  String get chance => 'Chance';

  @override
  String get upperBonus => 'Bonus Oberer Teil (wenn >= 63)';

  @override
  String get upperSubtotal => 'Zwischensumme Oberer Teil';

  @override
  String get upperTotal => 'Gesamt Oberer Teil';

  @override
  String get lowerTotal => 'Gesamt Unterer Teil';

  @override
  String get yahtzeeBonusScore => 'Yahtzee Bonus Punkte';

  @override
  String get grandTotal => 'Gesamtsumme';

  @override
  String get dice => 'Würfel';

  @override
  String get selectScoreCategoryPrompt => 'Zug fortgeschritten. Wähle eine Punktekategorie.';

  @override
  String get leaderboardComingSoon => 'Bestenliste (Demnächst verfügbar)';

  @override
  String get settingsComingSoon => 'Einstellungen (Demnächst verfügbar)';

  @override
  String get upperSectionTitle => 'Oberer Bereich';

  @override
  String get lowerSectionTitle => 'Unterer Bereich';

  @override
  String get continueGame => 'Spiel fortsetzen';

  @override
  String get exitGameConfirmation => 'Sind Sie sicher, dass Sie das aktuelle Spiel verlassen möchten?';
}
