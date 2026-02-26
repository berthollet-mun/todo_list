import 'package:crud_sqlite/models/task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;
  final VoidCallback onEdit; // Nouvelle callback pour l'édition

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onEdit, // Nouveau paramètre requis
  });

  String get _formattedDueDate {
    return DateFormat('dd/MM/yyyy').format(task.dueDate);
  }

  Color? _getDueDateColor(BuildContext context) {
    if (task.isOverdue) {
      return Colors.red;
    } else if (task.dueDate.isBefore(
      DateTime.now().add(const Duration(days: 2)),
    )) {
      return Colors.orange;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => onToggleCompletion(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),

        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Text(
                  _formattedDueDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getDueDateColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (task.isOverdue)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'EN RETARD',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Ajout du bouton d'édition et modification du bouton de suppression
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton d'édition
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Modifier la tâche',
            ),

            // Bouton de suppression
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Supprimer la tâche',
            ),
          ],
        ),

        onLongPress: onToggleCompletion,

        // Optionnel: ajouter un tap sur toute la carte pour éditer
        onTap: onEdit,
      ),
    );
  }
}
