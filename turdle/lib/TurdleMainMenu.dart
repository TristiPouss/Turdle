import 'package:flutter/material.dart';
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

  // Fonction pour afficher les options d'un mode
  Widget _buildOptions(String mode) {
    if (mode == "Classique") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Options Classique"),
          SizedBox(height: 8.0),
          ListTile(
            title: Text("Nombre de lettres :"),
            trailing: DropdownButton<int>(
              value: nbLetters,
              items: List.generate(
                9,
                (index) => DropdownMenuItem(
                  child: Text("${index + 4}"),
                  value: index + 4,
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
            title: Text("Nombre de tentatives"),
            trailing: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(color: Colors.black),
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
            title: Text("Langage :"),
            trailing: DropdownButton<String>(
              value: language,
              items: const [
                DropdownMenuItem(
                  child: Text("Français"),
                  value: "French",
                ),
                DropdownMenuItem(
                    child: Text("Anglais"),
                    value: "English",
                ),
                DropdownMenuItem(
                  child: Text("Espagnol"),
                  value: "Spanish",
                ),
              ],
              onChanged: (value) {
                setState(() {
                  (value != null) ? language = value : language = "French";
                });
              },
            ),
          ),
        ],
      );
    } else if (mode == "Survie") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Options Survie"),
          SizedBox(height: 8.0),
          ListTile(
            title: Text("Temps par partie (en secondes) :"),
            trailing: DropdownButton<int>(
              items: [30, 60, 90, 120]
                  .map((time) => DropdownMenuItem(
                child: Text("$time s"),
                value: time,
              ))
                  .toList(),
              onChanged: (value) {},
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
            SizedBox(width: 10),
            Text('Menu Principal - Choix du Mode'),
          ],
        )
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedMode = "Classique";
                });
              },
              child: Text("Classique"),
            ),
            if (selectedMode == "Classique") _buildOptions("Classique"),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedMode = "Survie";
                });
              },
              child: Text("Survie"),
            ),
            if (selectedMode == "Survie") _buildOptions("Survie"),
            Spacer(),
            ElevatedButton(
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
                          nbTry: nbTry
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
                }
              },
              child: Text("Commencer la partie"),
            ),
          ],
        ),
      ),
    );
  }
}