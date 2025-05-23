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
}
