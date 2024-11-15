import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'TurdleGamePage.dart';

class TurdleMainMenu extends StatelessWidget {
  const TurdleMainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Hide debug banner
      debugShowCheckedModeBanner: false,
      title: 'Turdle Menu',
      home: MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatefulWidget {
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  String selectedMode = ""; // Stocke le mode sélectionné
  String language = "French";
  int nbLetters = 5;
  int nbTry = 6;
  bool hasTimer = true;
  String p1 = "";
  String p2 = "";
  bool darkTheme = SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  // Fonction pour afficher les options d'un mode
  Widget _buildOptions(String mode) {
    if (mode == "Classique") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Options Classique"),
          const SizedBox(height: 8.0),
          ListTile(
            title: const Text("Nombre de lettres :"),
            trailing: DropdownButton<int>(
              value: nbLetters,
              items: List.generate(
                9,
                (index) => DropdownMenuItem(
                  value: index + 4,
                  child: Text("${index + 4}"),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  (value != null) ? nbLetters = value : nbLetters = 5;
                });
              },
            ),
          ),
          ListTile(
            title: const Text("Nombre de tentatives"),
            trailing: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: "6",
                isDense: true,
                constraints: BoxConstraints(
                    maxWidth: 60
                ),
              ),
              onChanged: (value){
                setState(() {
                  int v = int.parse(value);
                  (v > 0) ? nbTry = v : nbTry = 6;
                });
              }
            ),
          ),
          ListTile(
            title: const Text("Langage :"),
            trailing: DropdownButton<String>(
              value: language,
              items: const [
                DropdownMenuItem(
                  value: "French",
                  child: Text("Français"),
                ),
                DropdownMenuItem(
                    value: "English",
                    child: Text("Anglais"),
                ),
                DropdownMenuItem(
                  value: "Spanish",
                  child: Text("Espagnol"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  (value != null) ? language = value : language = "French";
                });
              },
            ),
          ),
          ListTile(
            title: const Text("Timer :"),
            trailing: Checkbox(value: hasTimer, onChanged: (onChanged) => {
              setState(() {
                hasTimer = !hasTimer;
              })
            }),
          ),
        ],
      );
    } else if (mode == "Survie") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Options Survie"),
          const SizedBox(height: 8.0),
          ListTile(
            title: const Text("Temps par partie :"),
            trailing: DropdownButton<int>(
              items: [30, 60, 90, 120]
                  .map((time) => DropdownMenuItem(
                value: time,
                child: Text("$time s"),
              ))
                  .toList(),
              onChanged: (value) {},
            ),
          ),
        ],
      );
    } else if (mode == "Duel") {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Options Duel"),
            const SizedBox(height: 8.0),
            ListTile(
              title: const Text("Pseudo du Joueur 1 :"),
              trailing: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]*'))
                ],
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  isDense: true,
                  constraints: BoxConstraints(
                      maxWidth: 150
                  ),
                ),
                onChanged: (value){
                  setState(() {
                    p1 = value;
                  });
                }
              ),
            ),
            ListTile(
              title: const Text("Pseudo du Joueur 2 :"),
              trailing: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.singleLineFormatter,
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]*'))
                  ],
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    isDense: true,
                    constraints: BoxConstraints(
                        maxWidth: 150
                    ),
                  ),
                  onChanged: (value){
                    setState(() {
                      p2 = value;
                    });
                  }
              ),
            ),
          ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_turdle.png',
              width: 40, // Taille de l'icône
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text('Menu Principal'),
            const Spacer(),
            Checkbox(
              value: darkTheme,
              onChanged: (onChanged) => {
                setState(() {
                  darkTheme = !darkTheme;
                }),
              },
            ),
          ],
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  (selectedMode != "Classique") ? selectedMode = "Classique" : selectedMode = "";
                });
              },
              child: const Text("Classique"),
            ),
            if (selectedMode == "Classique") _buildOptions("Classique"),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  (selectedMode != "Survie") ? selectedMode = "Survie" : selectedMode = "";
                });
              },
              child: const Text("Survie"),
            ),
            if (selectedMode == "Survie") _buildOptions("Survie"),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  (selectedMode != "Duel") ? selectedMode = "Duel" : selectedMode = "";
                });
              },
              child: const Text("Duel"),
            ),
            if (selectedMode == "Duel") _buildOptions("Duel"),
            const SizedBox(height: 200.0),
            const Spacer(),
            ElevatedButton( // Bouton Commencer la partie
              onPressed: () {
                // Lancer la partie en fonction du mode et des options sélectionnées
                switch(selectedMode){
                  case "Classique" :
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TurdleGamePage(
                          gameMode: selectedMode,
                          language: language,
                          nbLetters: nbLetters,
                          nbTry: nbTry,
                          hasTimer: hasTimer
                      )),
                    ).then((value) => {
                      setState(() {
                        selectedMode = "";
                        language = "French";
                        nbLetters = 5;
                        nbTry = 6;
                      })
                    });
                    break;
                  case "Survie" :
                    break;
                  case "Duel" :
                    break;
                }
              },
              child: const Text("Commencer la partie"),
            ),
          ],
        ),
      ),
    );
  }
}