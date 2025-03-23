import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksScreen extends StatefulWidget {
  final List<String> subjects; // Required subjects parameter

  TasksScreen({required this.subjects}); // Constructor

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TextEditingController _taskController = TextEditingController();
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tasks"), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Task Input Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: "Enter Task",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    String taskTitle = _taskController.text.trim();
                    if (taskTitle.isNotEmpty) {
                      _showSubjectDialog(taskTitle);
                    } else {
                      _showSnackbar("Please enter a task!");
                    }
                  },
                  child: Text("Add Task"),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Task List Display from Firestore
            Expanded(
              child: StreamBuilder(
                stream: _tasksCollection.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading tasks"));
                  }

                  var tasks = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      var task = tasks[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            task['title'],
                            style: TextStyle(
                              decoration:
                                  task['completed']
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text("Subject: ${task['subject']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: task['completed'],
                                onChanged:
                                    (value) =>
                                        _toggleTaskCompletion(task.id, value!),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeTask(task.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add Task to Firestore
  void _addTask(String taskTitle, String subject) async {
    await _tasksCollection.add({
      'title': taskTitle,
      'completed': false,
      'subject': subject,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _taskController.clear();
    _showSnackbar("Task Added!");
  }

  // Remove Task from Firestore
  void _removeTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
    _showSnackbar("Task Removed!");
  }

  // Toggle Task Completion
  void _toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _tasksCollection.doc(taskId).update({'completed': isCompleted});
  }

  // Show Dialog to Select Subject
  void _showSubjectDialog(String taskTitle) {
    TextEditingController _subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Subject"),
          content: TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: "Subject Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String subject = _subjectController.text.trim();
                if (subject.isNotEmpty && widget.subjects.contains(subject)) {
                  _addTask(taskTitle, subject);
                  Navigator.pop(context);
                } else {
                  _showSnackbar("Subject not found!");
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Helper: Show Snackbar Messages
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
