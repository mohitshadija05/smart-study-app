import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'subjects_screen.dart';
import 'tasks_screen.dart';
import 'sessions_screen.dart';
import 'progress_screen.dart';

class DashboardScreen extends StatefulWidget {
  final List<String> subjects; // Accept subjects as a parameter

  DashboardScreen({Key? key, required this.subjects})
    : super(key: key); // Constructor

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> subjects = []; // Store fetched subjects

  @override
  void initState() {
    super.initState();
    subjects = widget.subjects; // Initialize subjects with passed data
    fetchSubjects(); // Fetch subjects from Firestore
  }

  // Function to fetch subjects from Firestore
  void fetchSubjects() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot snapshot = await firestore.collection('subjects').get();
      List<String> fetchedSubjects =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();

      setState(() {
        subjects =
            widget.subjects +
            fetchedSubjects; // Merge fetched subjects with passed ones
      });
    } catch (e) {
      _showSnackbar("Failed to fetch subjects. Please try again.");
      print("Error fetching subjects: $e");
    }
  }

  // Show Snackbar for messages
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60), // Spacing from top
              Text(
                "Welcome to the Smart Study App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildDashboardButton(
                        context,
                        "Subjects",
                        Icons.book,
                        Colors.orange,
                        SubjectsScreen(
                          subjects: subjects,
                        ), // Pass fetched subjects
                      ),
                      _buildDashboardButton(
                        context,
                        "Tasks",
                        Icons.checklist,
                        Colors.green,
                        TasksScreen(subjects: subjects), // Pass subjects here
                      ),
                      _buildDashboardButton(
                        context,
                        "Sessions",
                        Icons.timer,
                        Colors.purple,
                        SessionsScreen(),
                      ),
                      _buildDashboardButton(
                        context,
                        "Progress",
                        Icons.pie_chart,
                        Colors.blue,
                        ProgressScreen(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper to build each dashboard button
  Widget _buildDashboardButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        color: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
