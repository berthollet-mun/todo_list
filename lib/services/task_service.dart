import 'package:todo_list/services/database_service.dart';

import '../models/task.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final DatabaseService _dbService = DatabaseService();

  // Ajout d'une nouvelle tache
  Future<void> addTask(Task task) async {
    final db = await _dbService.database;
    await db.insert('tasks', task.toMap());
    print('Tâche "${task.title}" ajoutée');
  }

  // Mise ajour d'une tahce existante
  Future<void> updateTask(Task updatedTask) async {
    final db = await _dbService.database;
    await db.update(
      'tasks',
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [updatedTask.id],
    );
    print('Tâche "${updatedTask.title}" mise à jour');
  }

  //Suppression d'une tache

  Future<void> deleteTask(String taskId) async {
    final db = await _dbService.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
    print('Tâche $taskId supprimée');
  }

  //Recuperation des toutes les taches

  Future<List<Task>> getTasks() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  //Recuperation des taches d'une utilisateurs specifique

  Future<List<Task>> getUserTasks(String userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dueDate ASC', // Tri par date d'échéance ascendante
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  //recuperation complete des tahces d'un utilisateur
  Future<List<Task>> getCompletedTasks(String userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND isCompleted = ?',
      whereArgs: [userId, 1], // 1 = true en SQLite
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Recupation des taches en cours d'un utilisateur

  Future<List<Task>> getPendingTasks(String userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND isCompleted = ?',
      whereArgs: [userId, 0], // 0 = false en SQLite
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  //recuperation des taches en retars d'un tulisateur

  Future<List<Task>> getOverdueTasks(String userId) async {
    final now = DateTime.now().toIso8601String();
    final db = await _dbService.database;

    // Requête avec condition de date
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND isCompleted = ? AND dueDate < ?',
      whereArgs: [userId, 0, now],
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  //recherche de tahces par mot-cle

  Future<List<Task>> searchTasks(String userId, String query) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND (title LIKE ? OR description LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }
}
