import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turdle/TurdleMainMenu.dart';

class TurdleGamePage extends StatefulWidget {
  const TurdleGamePage({
    required this.gameMode,
    required this.language,
    required this.nbLetters,
    required this.nbTry
  });

  final String gameMode;
  final String language;
  final int nbLetters;
  final int nbTry;

  @override
  _TurdleGamePageState createState() => _TurdleGamePageState(
      gameMode: gameMode,
      language: language,
      nbLetters: nbLetters,
      nbTry: nbTry);
}

class _TurdleGamePageState extends State<TurdleGamePage> {
  final String gameMode;
  final String language;
  final int nbLetters;
  final int nbTry;
  String targetWord = "";
  List<String> guesses = [];
  List<String> _dict = [];

  int currentGuess = 0;
  int score = 0;
  bool? win;

  late Future<void> _gameSetupFuture;

  _TurdleGamePageState({
    required this.gameMode,
    required this.language,
    required this.nbLetters,
    required this.nbTry
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turdle - Mode $gameMode'),
      ),
      body: Column(
        children: [
          // Grille des mots devinés
          Expanded(
              child: Scaffold(
                body: FutureBuilder<void>(
                  future: _gameSetupFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Erreur : ${snapshot.error}"));
                    } else {
                      return TurdleGrid(
                        guesses: guesses,
                        guessesChecked: guessesChecked,
                        targetWordLength: targetWord.length,
                        currentGuess: currentGuess,
                        scrollController: _scrollController,
                        win: win,
                      );
                    }
                    }
                ),
              ),
          ),
          // Ajoute un espace de 16 pixels entre la grille et le clavier
          SizedBox(height: 16.0),
          // Clavier virtuel
          if(win == null)
            TurdleKeyboard(
                onLetterTap: onLetterTap,
                onBackspaceTap: onBackspaceTap,
                onEnterTap: onEnterTap,
                getLetterColor: getLetterColor
            ),
          if(win != null) TurdleWin(win: win!, score: score, onMenu: onMenu, onReplay: onReplay,),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _gameSetupFuture = startNewGame();
  }

  Future<void> startNewGame() async{
    await readJson("assets/dict/${language.toLowerCase()}_words.json");
    print("$_dict");
    targetWord = getWord(nbLetters).toUpperCase();
    print(targetWord);
    guesses = List.filled(nbTry, "");
  }

  void onLetterTap(String letter) {
    if (guesses[currentGuess].length < targetWord.length) {
      setState(() {
        guesses[currentGuess] += letter;
      });
      scrollToCurrentGuess(); // Défiler vers l'essai actuel
    }
  }

  void onBackspaceTap() {
    if (guesses[currentGuess].isNotEmpty) {
      setState(() {
        guesses[currentGuess] = guesses[currentGuess].substring(0, guesses[currentGuess].length - 1);
      });
      scrollToCurrentGuess(); // Défiler vers l'essai actuel
    }
  }

  void onEnterTap() {
    if (guesses[currentGuess].length == targetWord.length) {
      if(!validGuess()) return;
      checkGuess();
      setState(() {
        currentGuess++;
      });
      scrollToCurrentGuess(); // Défiler vers l'essai actuel
      if(win != null){
        List<String> tempList = [];
        for(String s in guesses){
          if (s.isNotEmpty) {
            tempList.add(s);
          }
        }
        guesses = tempList;
      }
    }
  }

  List<String> badLetters = [];
  List<String> greenLetters = [];
  List<String> yellowLetters = [];

  Color getLetterColor(String letter){
    if (greenLetters.contains(letter)){
      return Colors.green;
    }
    if (yellowLetters.contains(letter)){
      return Colors.yellow;
    }
    if (badLetters.contains(letter)){
      return Colors.grey.shade300;
    }
    return Colors.white;
  }

  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fonction pour défiler jusqu'à l'essai en cours
  void scrollToCurrentGuess() {
    double offset = 0; // Taille approximative de chaque ligne
    _scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn);
  }

  List<List<Color>> guessesChecked = [];

  void checkGuess() {
    // resultat a ajouter dans la liste guessesChecked
    List<Color> res = List.filled(targetWord.length, Colors.grey.shade300);
    // liste des lettres utilisées pour marquer les mal placées
    List<bool> checkedLetters = List.filled(targetWord.length, false);
    // d'abord les lettres bien  placées en Vert
    for(int i = 0; i<targetWord.length; i++){
      String currentLetter = guesses[currentGuess][i];
      // Pas besoin de vérifier la longueur du guess par rapport au mot à deviner.
      if(currentLetter == targetWord[i]){
        // La lettre est au bon endroit - Vert
        res[i] = Colors.green;
        greenLetters.add(currentLetter);
        checkedLetters[i] = true;
      }
    }
    // ensuite les lettre dans le mot mais pas au bon endroit
    for(int guessIndex = 0; guessIndex<guesses[currentGuess].length; guessIndex++){
      String currentLetter = guesses[currentGuess][guessIndex];
      if(res[guessIndex] != Colors.green){ // ignore les lettres bien placées
        for(int targetIndex = 0; targetIndex<targetWord.length; targetIndex++){
          if(!checkedLetters[targetIndex] && currentLetter == targetWord[targetIndex]){
            res[guessIndex] = Colors.yellow;
            yellowLetters.add(currentLetter);
            checkedLetters[targetIndex] = true;
            break;
          }
        }
      }
    }
    for(int i = 0; i<guesses[currentGuess].length; i++){
      if(res[i] == Colors.grey.shade300){
        badLetters.add(guesses[currentGuess][i]);
      }
    }
    // on ajoute le résultat a la liste checked
    guessesChecked.add(res);
    // on verifie si le jeu est terminé
    checkEnd();
  }

  void checkEnd() {
    // Check fin de partie
    for(int i = 0; i<guessesChecked[currentGuess].length;i++){
      if(guessesChecked[currentGuess][i] != Colors.green){
        // Mot non trouvé
        // Check si plus d'essai
        if(currentGuess == guesses.length-1){
          // Partie perdue
          win = false;
        }
        return;
      }
    }
    // Partie gagnée
    win = true;
  }

  void onReplay(){
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TurdleGamePage(
          gameMode: gameMode,
          language: language,
          nbLetters: nbLetters,
          nbTry: nbTry
      )),
    );
  }

  void onMenu(){
    Navigator.pop(context);
  }

  Future<void> readJson(String filePath) async {
    try {
      final String response = await rootBundle.loadString(filePath);
      final data = json.decode(response);
      //setState(() {
        _dict = List<String>.from(data);
      //});
      // Vérifier que les mots sont bien chargés
      if (_dict.isEmpty) {
        print("Aucun mot trouvé dans le fichier JSON.");
      } else {
        //print("Mots chargés : $_dict");
      }
    } catch (e) {
      print("Erreur lors du chargement du fichier JSON : $e");
    }
  }

  String getWord(int len) {
    if (_dict.isEmpty) {
      throw Exception("Le dictionnaire de mots est vide. Assurez-vous que readJson() a été appelé.");
    }
    // Filtrer les mots de la longueur spécifiée
    List<String> filteredWords = _dict.where((word) => word.length == len).toList();

    // Vérifier que la liste filtrée n'est pas vide
    if (filteredWords.isEmpty) {
      throw Exception("Aucun mot trouvé avec la longueur spécifiée : $len");
    }

    // Sélectionner un mot aléatoire parmi les mots filtrés
    final random = Random();
    return filteredWords[random.nextInt(filteredWords.length)];
  }

  bool validGuess() {
    return _dict.contains(guesses[currentGuess].toLowerCase());
  }

}

class TurdleKeyboard extends StatelessWidget {
  final Function(String) onLetterTap;
  final VoidCallback onBackspaceTap;
  final VoidCallback onEnterTap;
  final Function(String) getLetterColor;

  TurdleKeyboard({
    required this.onLetterTap,
    required this.onBackspaceTap,
    required this.onEnterTap,
    required this.getLetterColor
  });

  @override
  Widget build(BuildContext context) {
    final letters = [
      'A', 'Z', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
      'Q', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M',
      'W', 'X', 'C', 'V', 'B', 'N'
    ];

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          children: letters.map((letter) {
            return ElevatedButton(
              onPressed: () => onLetterTap(letter),
              child: Text(letter),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(36, 36),
                  padding: EdgeInsets.all(12.0),
                  backgroundColor: getLetterColor(letter)
              ),
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onBackspaceTap,
              icon: Icon(Icons.backspace),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: onEnterTap,
              child: Text('Enter'),
            ),
          ],
        ),
      ],
    );
  }
}

class TurdleGrid extends StatelessWidget {
  final List<String> guesses;
  final List<List<Color>> guessesChecked;
  final int targetWordLength;
  final int currentGuess;
  final ScrollController scrollController;
  final bool? win;

  TurdleGrid({
    required this.guesses,
    required this.guessesChecked,
    required this.targetWordLength,
    required this.currentGuess,
    required this.scrollController,
    required this.win,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 500, // Hauteur maximale pour permettre le défilement si nécessaire,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: guesses.asMap().entries.map((entry) {
              int wordIndex = entry.key;
              String guess = entry.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 20),
                  ...List.generate(targetWordLength, (letterIndex) {
                    String letter = guess.length > letterIndex ? guess[letterIndex] : "";

                    return Expanded(
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: getColor(currentGuess, wordIndex, letterIndex),
                        ),
                        child: Text(
                          letter,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 20),
                ],
              );
            }).toList(),
          ),
        ),
      )
    );
  }

  Color getColor(int currentGuess, int wordIndex, int letterIndex) {
    if(currentGuess == wordIndex) {
      return Colors.lightBlue; // Met en surbrillance l'essai actuel
    } else if (wordIndex < currentGuess) {
      return guessesChecked[wordIndex][letterIndex];
    } else {
      return Colors.white;
    }
  }
}

class TurdleWin extends StatelessWidget{
  final bool win;
  final int score;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  TurdleWin({
    required this.win,
    required this.score,
    required this.onReplay,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: win ? Colors.greenAccent[100] : Colors.redAccent[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                win ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 80,
                color: win ? Colors.green : Colors.red,
              ),
              SizedBox(height: 10),
              Text(
                win ? "Félicitations !" : "Dommage !",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: win ? Colors.green[800] : Colors.red[800],
                ),
              ),
              SizedBox(height: 10),
              Text(
                win ? "Vous avez gagné!" : "Essayez encore !",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                "Score : $score",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onReplay,
                    icon: Icon(Icons.refresh),
                    label: Text("Rejouer"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: onMenu,
                    icon: Icon(Icons.home),
                    label: Text("Menu"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.orangeAccent,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}