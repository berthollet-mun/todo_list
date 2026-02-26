import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // Getter pour recuper l'instance de la base donnee
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await intDatabase();
    return _database!;
  }

  // Initialisation de la base de donnee
  Future<Database> intDatabase() async {
    final path = join(await getDatabasesPath(), 'task_app.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Creation de la base de donnees
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,          -- Identifiant unique de l'utilisateur
        username TEXT NOT NULL,       -- Nom d'utilisateur
        email TEXT NOT NULL UNIQUE,   -- Email (unique)
        password TEXT NOT NULL,       -- Mot de passe
        profileImage TEXT             -- Chemin vers l'image de profil (optionnel)
      )
    ''');

    // Table des tâches avec clé étrangère vers users
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,          -- Identifiant unique de la tâche
        userId TEXT NOT NULL,         -- Référence à l'utilisateur propriétaire
        title TEXT NOT NULL,          -- Titre de la tâche
        description TEXT,             -- Description détaillée (optionnelle)
        dueDate TEXT NOT NULL,        -- Date d'échéance au format ISO
        isCompleted INTEGER NOT NULL DEFAULT 0, -- Statut (0 = false, 1 = true)
        createdAt TEXT NOT NULL,      -- Date de création au format ISO
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        -- Suppression en cascade si l'utilisateur est supprimé
      )
    ''');
    print("Base de donnee et tables creees avec success");
  }

  // Fermeture de la connexion a la base de donnee
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
