import 'package:flutter/material.dart';

class TurdleMainMenu extends StatelessWidget {
  const TurdleMainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turdle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TurdleGamePage(),
    );
  }
}

class TurdleGamePage extends StatefulWidget {
  @override
  _TurdleGamePageState createState() => _TurdleGamePageState();
}

class _TurdleGamePageState extends State<TurdleGamePage> {
  // Exemple de mot cible
  final String targetWord = "DARTS";
  // Liste pour stocker les mots devinés
  List<String> guesses = ["", "", "", "", "", ""];

  // Lettres tapées par l'utilisateur
  int currentGuess = 0;

  void onLetterTap(String letter) {
    if (guesses[currentGuess].length < targetWord.length) {
      setState(() {
        guesses[currentGuess] += letter;
      });
    }
  }

  void onBackspaceTap() {
    if (guesses[currentGuess].isNotEmpty) {
      setState(() {
        guesses[currentGuess] = guesses[currentGuess].substring(0, guesses[currentGuess].length - 1);
      });
    }
  }

  void onEnterTap() {
    if (guesses[currentGuess].length == targetWord.length) {
      setState(() {
        checkGuess();
        currentGuess++;
      });
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
            child: GridView.builder(
              itemCount: guesses.length * targetWord.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: targetWord.length,
              ),
              itemBuilder: (context, index) {
                int wordIndex = index ~/ targetWord.length;
                int letterIndex = index % targetWord.length;
                String letter = guesses[wordIndex].length > letterIndex
                    ? guesses[wordIndex][letterIndex]
                    : "";

                return Container(
                  margin: EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          // Clavier virtuel
          buildKeyboard(),
        ],
      ),
    );
  }

  Widget buildKeyboard() {
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
              style: ElevatedButton.styleFrom(
                minimumSize: Size(36, 36),
                padding: EdgeInsets.all(12.0),
              ),
              child: Text(letter),
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
        )
      ],
    );
  }

  void checkGuess() {}
}
