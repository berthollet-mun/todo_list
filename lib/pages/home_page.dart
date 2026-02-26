import 'package:crud_sqlite/models/task.dart';
import 'package:crud_sqlite/pages/edit_task_page.dart';
import 'package:crud_sqlite/pages/profile_page.dart';
import 'package:crud_sqlite/pages/task_form_page.dart';
import 'package:crud_sqlite/services/auth_service.dart';
import 'package:crud_sqlite/services/task_service.dart';
import 'package:crud_sqlite/widgets/task_item.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _taskService = TaskService();
  List<Task> _tasks = [];
  late TabController _tabController;
  int _currentTabIndex = 0;
  bool _isLoading = true;

  final List _tabkTitles = ['Toutes', 'En cours', 'Terminées'];
  final List _emptyStateMessages = [
    'Aucune tâche',
    'Aucune tâche en cours',
    'Aucune tâche terminée',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadTasks();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  Future<void> _loadTasks() async {
    final currentUser = await _authService.getCurrentuser();
    if (currentUser != null) {
      List<Task> tasks;

      switch (_currentTabIndex) {
        case 0:
          tasks = await _taskService.getUserTasks(currentUser.id);
          break;
        case 1:
          tasks = await _taskService.getPendingTasks(currentUser.id);
          break;
        case 2:
          tasks = await _taskService.getCompletedTasks(currentUser.id);
          break;
        default:
          tasks = [];
      }

      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _taskService.updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> _deleteTask(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _taskService.deleteTask(taskId);
      _loadTasks();
    }
  }

  Future<void> _editTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskPage(task: task)),
    );
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // EN-TÊTE FIXE
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // TITRE ET BOUTON PROFIL
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mes Tâches',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(),
                              ),
                            ).then((_) => _loadTasks());
                          },
                          icon: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 26,
                          ),
                          tooltip: 'Profil',
                        ),
                      ],
                    ),
                  ),

                  // ONGLETS
                  Container(
                    color: Color(0xFF1976D2),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.7),
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(icon: Icon(Icons.list, size: 22), text: 'Toutes'),
                        Tab(
                          icon: Icon(Icons.access_time, size: 22),
                          text: 'En cours',
                        ),
                        Tab(
                          icon: Icon(Icons.check_circle, size: 22),
                          text: 'Terminées',
                        ),
                      ],
                      onTap: (index) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                        _loadTasks();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // CORPS SCROLLABLE
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1976D2),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTasks,
                      color: Color(0xFF1976D2),
                      child: _tasks.isEmpty
                          ? SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFF1976D2,
                                          ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.task,
                                          size: 60,
                                          color: Color(
                                            0xFF1976D2,
                                          ).withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        _emptyStateMessages[_currentTabIndex],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      if (_currentTabIndex == 0)
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            'Commencez par ajouter votre première tâche',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      if (_currentTabIndex == 0)
                                        const SizedBox(height: 20),
                                      if (_currentTabIndex == 0)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const TaskFormPage(),
                                                ),
                                              ).then((_) => _loadTasks());
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF1976D2,
                                              ),
                                              foregroundColor: Colors.white,
                                              minimumSize: Size(
                                                double.infinity,
                                                50,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.add, size: 20),
                                                const SizedBox(width: 8),
                                                Text('Créer une tâche'),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                final task = _tasks[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: TaskItem(
                                    task: task,
                                    onToggleCompletion: () =>
                                        _toggleTaskCompletion(task),
                                    onDelete: () => _deleteTask(task.id),
                                    onEdit: () => _editTask(task),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentTabIndex != 2
          ? Container(
              margin: EdgeInsets.only(bottom: 16),
              child: FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskFormPage(),
                    ),
                  );
                  _loadTasks();
                },
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.add, size: 28),
              ),
            )
          : null,
    );
  }
}
