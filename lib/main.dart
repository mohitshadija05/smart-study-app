import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 Firestore
import 'screens/dashboard_screen.dart'; // Import DashboardScreen
import 'firebase_options.dart'; // Import generated Firebase config

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is properly initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ Load Firebase config
  );

  // ✅ Test Firestore Connection
  testFirestore();

  runApp(SmartStudyApp());
}

// ✅ Firestore Test Function
void testFirestore() async {
  await FirebaseFirestore.instance.collection('test').doc('sample').set({
    'message': 'Hello Firestore!',
    'timestamp': DateTime.now(),
  });
  print("✅ Firestore Write Successful!");
}

// ✅ Main App Widget
class SmartStudyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart Study App", // ✅ Add App Title
      theme: ThemeData(
        primarySwatch: Colors.blue, // ✅ Set theme color
        fontFamily: 'Roboto', // ✅ Optional: Custom font if needed
      ),
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(
        subjects: ["Math", "Science", "History"],
      ), // ✅ Pass subjects to DashboardScreen
    );
  }
}
