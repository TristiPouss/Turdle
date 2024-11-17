import 'TurdleMainMenu.dart';
import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();
  // L'historique des parties se réinitialise a chaque lancement de l'application
  // Le mieux aurait que chaque instance du jeu sur un telephone ai son historique
  // En ajoutant une table utilisateur dans ma base par exemple
  await dbHelper.deleteAllGames();

  runApp(const TurdleMainMenu());
}
