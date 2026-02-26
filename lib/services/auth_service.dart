import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/services/database_service.dart';

import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService.internal();
  factory AuthService() => _instance;
  AuthService.internal();

  final DatabaseService _dbService = DatabaseService();
  static const String _userKey = 'current_user';

  // Sauvegarder la session utilisateur
  Future<void> _saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  // Récupérer la session utilisateur
  Future<User?> _getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromMap(jsonDecode(userData));
    }
    return null;
  }

  // Effacer la session utilisateur
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Vérifier si un utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final user = await _getUserSession();
    return user != null;
  }

  Future<void> registerUser(User user) async {
    final db = await _dbService.database;

    // verifier l'unicite de l'email
    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user.email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception("un utilisateur avec cet email existe deja");
    }

    // insertion d'un nouvel utilisateur
    await db.insert('users', user.toMap());
    print('Utilisateur ${user.username} eregistrer avec succes');
  }

  //connexion d'un nouvel utilisateur
  Future<User?> login(String email, String password) async {
    final db = await _dbService.database;

    // Recherche de l'utilisateur par email et mot de passe
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      final user = User.fromMap(result.first);
      await _saveUserSession(user); // Sauvegarder la session
      print("utilisateur ${user.username} connecter avec succes");
      return user;
    }
    print("Echec de connexion par l' email $email");
    return null;
  }

  // Recupere l'utilisateur actuellement connecter
  Future<User?> getCurrentuser() async {
    // D'abord essayer de récupérer depuis la session
    final sessionUser = await _getUserSession();
    if (sessionUser != null) {
      return sessionUser;
    }
    // Fallback sur la base de données
    final db = await _dbService.database;
    final result = await db.query('users', limit: 1);

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  //Mise a jour des informations de l'utilisateur
  Future<void> updatedUser(User updatedUser) async {
    final db = await _dbService.database;
    await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [updatedUser.id],
    );
    print('utilisateur ${updatedUser.username} mis a jour');
  }

  // Suppression des informations de l'utilisateur
  Future<void> deletedUser(String userId) async {
    final db = await _dbService.database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
    print('Utilisateur $userId suprimé');
  }

  // verifier si un email deja utilise existe deja
  Future<bool> isEmailTaken(String email) async {
    final db = await _dbService.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
}
