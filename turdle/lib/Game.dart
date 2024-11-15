class Game {
  int? id;
  String targetWord;
  List<String> guesses;
  bool win;
  Duration? duration;

  Game({
    this.id,
    required this.targetWord,
    required this.guesses,
    required this.win,
    required this.duration,
  });

  // Convertir un objet Game en map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetWord': targetWord,
      'guesses': guesses.join(','), // Sauvegarde les guesses en chaîne séparée par des virgules
      'isComplete': win ? true : false,
      'duration': duration.toString(),
    };
  }

  // Convertir une map issue de SQLite en objet Game
  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      targetWord: map['targetWord'],
      guesses: map['guesses'].split(','), // Convertir la chaîne en liste
      win: map['isComplete'],
      duration: map['duration'],
    );
  }
}
