import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../model/client.dart';
import '../../services/TaskService.dart';
import '../../model/task.dart'; // Import Task Model
import 'package:intl/intl.dart'; // Import for date formatting
import 'TaskDetailsPage.dart';

class JuicerTaskListPage extends StatefulWidget {
  final Client client;

  JuicerTaskListPage({required this.client});

  @override
  _JuicerTaskListPageState createState() => _JuicerTaskListPageState();
}

class _JuicerTaskListPageState extends State<JuicerTaskListPage> {
  final TaskService _taskService = TaskService(); // Instance of Task Service
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _filterCriteria;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // Function to fetch tasks from Firestore
  Future<void> _fetchTasks() async {
    try {
      List<Task> tasks =
          await _taskService.fetchTasks(); // Fetch tasks from the service
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching tasks. Please try again later.';
      });
      print('Error fetching tasks: $e');
    }
  }

  void _applyFilter(String filterCriteria) {
    setState(() {
      _filterCriteria = filterCriteria;
    });
  }

  List<Task> _getFilteredTasks() {
    if (_filterCriteria == null) {
      return _tasks;
    }
    // Add custom filter logic here
    return _tasks
        .where((task) => task.taskType.contains(_filterCriteria!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juicer Task List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'Battery', child: Text('Battery Replacement')),
              const PopupMenuItem(value: 'Maintenance', child: Text('Maintenance')),
              const PopupMenuItem(value: 'All', child: Text('All Tasks')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : _errorMessage != null
              ? Center(
                  child: Text(
                      _errorMessage!)) // Show error message if an error occurs
              : _tasks.isEmpty
                  ? const Center(
                      child: Text(
                          'No tasks available')) // Show when there are no tasks
                  : ListView.builder(
                      itemCount: _getFilteredTasks().length,
                      itemBuilder: (context, index) {
                        final task = _getFilteredTasks()[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(task.vehicleModel),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Battery Level: ${task.batteryLevel}%'),
                                Text('Task Type: ${task.taskType}'),
                                Text('Status: ${task.status}'),
                              ],
                            ),
                            onTap: () {
                              // Navigate to Task Details Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDetailsPage(task: task),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
