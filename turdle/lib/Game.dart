class Game {
  String targetWord;
  List<String> guesses;
  bool win;
  Duration? duration;

  Game({
    required this.targetWord,
    required this.guesses,
    required this.win,
    required this.duration,
  });

  // Convertir un objet Game en map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'word': '"$targetWord"',
      'guesses': '"${guesses.join(',')}"', // Sauvegarde les guesses en chaîne séparée par des virgules
      'duration': '"${duration.toString()}"',
      'win': win ? "TRUE" : "FALSE",
    };
  }

  // Convertir une map issue de SQLite en objet Game
  factory Game.fromMap(Map<String, dynamic> map) {
    List<String> _guesses = map['guesses'].split(',');
    List<String> _guessesProcessed = _guesses.where((element) => element != "").toList();
    List<String> _durationStr = map['duration'].split(':');
    Duration? _duration = Duration(
        hours: int.parse(_durationStr[0].replaceAll(RegExp(r'[^0-9]'),'')),
        minutes: int.parse(_durationStr[1].replaceAll(RegExp(r'[^0-9]'),'')),
        seconds: int.parse(_durationStr[2].replaceAll(RegExp(r'[^0-9]'),''))
    );
    return Game(
      targetWord: map['word'],
      guesses: _guessesProcessed,
      duration: _duration,
      win: map['win'] == 'TRUE' ? true : false,
    );
  }
}
