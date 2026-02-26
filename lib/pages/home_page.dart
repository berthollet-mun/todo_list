import 'package:todo_list/models/task.dart';
import 'package:todo_list/pages/edit_task_page.dart';
import 'package:todo_list/pages/profile_page.dart';
import 'package:todo_list/pages/task_form_page.dart';
import 'package:todo_list/services/auth_service.dart';
import 'package:todo_list/services/task_service.dart';
import 'package:todo_list/widgets/task_item.dart';
import 'package:flutter/material.dart';

// Classe utilitaire pour le responsive
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1100) return 1000;
    if (width >= 650) return 600;
    return width - 32;
  }
}

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
  List<Task> _filteredTasks = [];
  late TabController _tabController;
  int _currentTabIndex = 0;
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    _searchController.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
    _loadTasks();
  }

  void _filterTasks(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTasks = _tasks;
      } else {
        _filteredTasks = _tasks.where((task) {
          return task.title.toLowerCase().contains(query.toLowerCase()) ||
              task.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
        _filteredTasks = _tasks;
      }
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
        _filteredTasks = _searchQuery.isEmpty
            ? tasks
            : tasks.where((task) {
                return task.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    task.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
              }).toList();
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
                  // TITRE ET BOUTONS
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _isSearching
                            ? Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _filterTasks,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Rechercher...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: _toggleSearch,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                'Mes Tâches',
                                style: TextStyle(
                                  fontSize: Responsive.isMobile(context)
                                      ? 20
                                      : 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _toggleSearch,
                              icon: Icon(
                                _isSearching ? Icons.close : Icons.search,
                                color: Colors.white,
                                size: 26,
                              ),
                              tooltip: 'Rechercher',
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                ).then((_) => _loadTasks());
                              },
                              icon: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 26,
                              ),
                              tooltip: 'Profil',
                            ),
                          ],
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
                      child: _filteredTasks.isEmpty
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add, size: 20),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    'Créer une tâche',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
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
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = _filteredTasks[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
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
