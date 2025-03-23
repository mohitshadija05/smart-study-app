import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int totalTasks = 0;
  int completedTasks = 0;
  int completedSessions = 0;
  Map<String, int> subjectProgress = {};

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    // Load tasks from Firestore
    QuerySnapshot taskSnapshot =
        await FirebaseFirestore.instance.collection('tasks').get();
    List<QueryDocumentSnapshot> tasks = taskSnapshot.docs;

    setState(() {
      totalTasks = tasks.length;
      completedTasks = tasks.where((task) => task['completed'] == true).length;

      subjectProgress = {};
      for (var task in tasks) {
        String subject = task['subject'] ?? "Unknown";
        bool isCompleted = task['completed'] ?? false;
        if (!subjectProgress.containsKey(subject)) {
          subjectProgress[subject] = 0;
        }
        if (isCompleted) {
          subjectProgress[subject] = subjectProgress[subject]! + 1;
        }
      }
    });

    // Load completed sessions from Firestore
    QuerySnapshot sessionSnapshot =
        await FirebaseFirestore.instance.collection('sessions').get();
    setState(() {
      completedSessions = sessionSnapshot.docs.length;
    });

    // Store progress data to Firestore
    await _updateProgressData();
  }

  Future<void> _updateProgressData() async {
    String userId =
        "user123"; // You can get the current user's ID from Firebase Auth

    try {
      await FirebaseFirestore.instance.collection('progress').doc(userId).set({
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'completedSessions': completedSessions,
        'subjectProgress': subjectProgress,
      }, SetOptions(merge: true)); // Merge to avoid overwriting other data
      print("Progress data saved successfully!");
    } catch (e) {
      print("Error saving progress data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Progress"), backgroundColor: Colors.blue),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Progress Section
            Text(
              "Task Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            LinearProgressIndicator(
              value:
                  totalTasks == 0 ? 0 : completedTasks / totalTasks.toDouble(),
            ),
            SizedBox(height: 10),
            Text("Completed: $completedTasks / $totalTasks"),

            SizedBox(height: 20),
            // Session Progress Section
            Text(
              "Session Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Completed Sessions: $completedSessions"),

            SizedBox(height: 20),
            // Subject-Based Progress Chart
            Text(
              "Subject-Based Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child:
                  subjectProgress.isEmpty
                      ? Center(
                        child: Text("No progress data available for subjects."),
                      )
                      : PieChart(
                        PieChartData(
                          sections:
                              subjectProgress.entries.map((entry) {
                                double percentage =
                                    totalTasks == 0
                                        ? 0
                                        : (entry.value / totalTasks) * 100;
                                return PieChartSectionData(
                                  title:
                                      "${entry.key}\n${entry.value} tasks\n(${percentage.toStringAsFixed(1)}%)",
                                  value: entry.value.toDouble(),
                                  color:
                                      Colors.primaries[entry.key.hashCode %
                                          Colors.primaries.length],
                                );
                              }).toList(),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
