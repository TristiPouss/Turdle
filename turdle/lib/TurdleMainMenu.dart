import 'package:flutter/material.dart';
import 'TurdleGamePage.dart';

class TurdleMainMenu extends StatelessWidget {
  const TurdleMainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ElevatedButton(
          onPressed: null,
          child: Text("Mode Normal"),
        ),

      ],
    );
  }
}