import 'package:todo_list/models/task.dart';
import 'package:todo_list/services/auth_service.dart';
import 'package:todo_list/services/task_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Formulaire de création et d'édition de tâches
/// Permet de saisir les détails d'une nouvelle tâche
class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  final _authService = AuthService();
  final _taskService = TaskService();
  bool _isLoading = false;

  /// Sélection de la date d'échéance via un date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      helpText: 'Sélectionnez la date d\'échéance',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF1976D2)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  /// Sauvegarde de la tâche dans la base de données
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = await _authService.getCurrentuser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final task = Task(
        id: const Uuid().v4(),
        userId: currentUser.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        createdAt: DateTime.now(),
        isCompleted: false,
      );

      await _taskService.addTask(task);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Nouvelle Tâche',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _isLoading ? null : _saveTask,
            tooltip: 'Enregistrer la tâche',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARTE PRINCIPALE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // TITRE
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Titre *',
                        labelStyle: TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF1976D2),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: 'Entrez le titre de la tâche',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.title, color: Color(0xFF1976D2)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // DESCRIPTION
                    TextFormField(
                      controller: _descriptionController,
                      style: TextStyle(fontSize: 16),
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF1976D2),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: 'Décrivez la tâche (optionnel)',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 80),
                          child: Icon(
                            Icons.description,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // DATE D'ÉCHÉANCE
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF1976D2).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF1976D2).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF1976D2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date d\'échéance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1976D2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              elevation: 0,
                              minimumSize: Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Modifier',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // BOUTON D'ENREGISTREMENT
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1976D2),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _saveTask,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                shadowColor: Color(0xFF1976D2).withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Enregistrer la tâche',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // INFOS COMPLÉMENTAIRES
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1976D2).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Color(0xFF1976D2), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Les champs marqués d\'un astérisque (*) sont obligatoires',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom padding for keyboard
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
