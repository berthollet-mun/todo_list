import 'package:intl/intl.dart';

class Task {
  String id;
  String userId;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  DateTime createdAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.createdAt,
  });

  // Conversion d'un Task en Map
  // Conversiot de date dans un fichier ISO pour permettre l'affichage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Creation d'un Task aprtir d'une Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Method pour copier le Task avec certaines valeurs modifiees
  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Formate la date d'echeance pour l'affichage
  String get formattedDueDate {
    return DateFormat('dd/MM/yyy').format(dueDate);
  }

  bool get isOverdue {
    return !isCompleted && dueDate.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, completed: $isCompleted }';
  }
}
