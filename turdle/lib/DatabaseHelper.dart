import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Game.dart';

class DatabaseHelper {
  // Singleton pour éviter plusieurs instances
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  // Méthode pour obtenir ou créer la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialiser la base de données
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'turdle_game.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Créer la table lors de l'initialisation
  Future<void> _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE IF NOT EXISTS games (id INTEGER PRIMARY KEY NOT NULL, word TEXT NOT NULL, guesses TEXT NOT NULL, duration TEXT, win INTEGER NOT NULL);");
    }

  // Insérer une partie dans la base de données
  Future<int> saveGame(Game game) async {
    final db = await database;
    return await db.insert(
      'games',
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupérer toutes les parties
  Future<List<Game>> getAllGames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('games');
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  // Supprimer toutes les parties
  Future<void> deleteAllGames() async {
    final db = await database;
    await db.delete('games');
  }
}
