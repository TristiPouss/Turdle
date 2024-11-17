import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'Game.dart';

class TurdleGameHistoryPage extends StatefulWidget {
  const TurdleGameHistoryPage({super.key});

  @override
  _TurdleGameHistoryPageState createState() => _TurdleGameHistoryPageState();
}

class _TurdleGameHistoryPageState extends State<TurdleGameHistoryPage> {
  late Future<List<Game>> _gameHistory;

  @override
  void initState() {
    super.initState();
    _gameHistory = _fetchGameHistory();
  }

  Future<List<Game>> _fetchGameHistory() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.getAllGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des parties"),
      ),
      body: FutureBuilder<List<Game>>(
        future: _gameHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune partie enregistrées"));
          } else {
            final games = snapshot.data!.reversed.toList();
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                      "Mot cible : ${game.targetWord}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Tentative${game.guesses.length > 1 ? "s" : ""} : ${game.guesses.join(', ')}\nGagné : ${game.win ? "Oui" : "Non"}",
                    ),
                    trailing: Icon(
                      Icons.circle,
                      color: game.win ? Colors.green : Colors.red,
                    ),
                    onTap: () {
                      _showGameDetails(context, game);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showGameDetails(BuildContext context, Game game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Détails de la partie"),
        content: Text(
          "Mot cible : ${game.targetWord}\n"
              "Tentatives : ${game.guesses.join(', ')}\n"
              "Terminé : ${game.win ? "Oui" : "Non"}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

}
