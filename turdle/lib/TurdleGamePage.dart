import 'package:flutter/material.dart';

class TurdleGamePage extends StatefulWidget {
  @override
  _TurdleGamePageState createState() => _TurdleGamePageState();
}

class _TurdleGamePageState extends State<TurdleGamePage> {
  // Exemple de mot cible
  final String targetWord = "DAARTS";
  // Liste pour stocker les mots devinés
  List<String> guesses = ["", "", "", "", "", ""];
  List<List<Color>> guessesChecked = [];
  // Lettres tapées par l'utilisateur
  int currentGuess = 0;
  bool? win;
  List<String> badLetters = [];
  List<String> greenLetters = [];
  List<String> yellowLetters = [];
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

  void onLetterTap(String letter) {
    if (guesses[currentGuess].length < targetWord.length) {
      setState(() {
        guesses[currentGuess] += letter;
      });
      scrollToCurrentGuess(); // Défiler vers l'essai actuel
    }
  }

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
      setState(() {
        checkGuess();
        currentGuess++;
      });
      scrollToCurrentGuess(); // Défiler vers l'essai actuel
    }
  }

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
    for(int i = 0; i<guessesChecked[currentGuess].length; i++){
      if(guessesChecked[currentGuess][i] != Colors.green){
        // Mot non trouvé
        break;
      }
      // Partie gagnée
      win = true;
      return;
    }
    // Check si plus d'essai
    if(currentGuess == guesses.length-1){
      // Partie perdue
      win = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turdle'),
      ),
      body: Column(
        children: [
          // Grille des mots devinés
          Expanded(
              child: TurdleGrid(
                guesses: guesses,
                guessesChecked: guessesChecked,
                targetWordLength: targetWord.length,
                currentGuess: currentGuess,
                scrollController: _scrollController,
              )
          ),
          // Ajoute un espace de 16 pixels entre la grille et le clavier
          SizedBox(height: 16.0),
          // Clavier virtuel
          TurdleKeyboard(
              onLetterTap: onLetterTap,
              onBackspaceTap: onBackspaceTap,
              onEnterTap: onEnterTap,
              getLetterColor: getLetterColor
          ),
        ],
      ),
    );
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

  TurdleGrid({
    required this.guesses,
    required this.guessesChecked,
    required this.targetWordLength,
    required this.currentGuess,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Hauteur maximale pour permettre le défilement si nécessaire

      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: guesses.asMap().entries.map((entry) {
            int wordIndex = entry.key;
            String guess = entry.value;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(targetWordLength, (letterIndex) {
                String letter = guess.length > letterIndex ? guess[letterIndex] : "";

                return Container(
                  width: 40.0,
                  height: 40.0,
                  margin: EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: getColor(currentGuess, wordIndex, letterIndex),
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            );
          }).toList(),
        ),
      ),
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