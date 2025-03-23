import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final CollectionReference tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  // Add Task
  Future<void> addTask(Task task) async {
    await tasksCollection.doc(task.id).set(task.toMap());
  }

  // Get All Tasks
  Stream<List<Task>> getTasks() {
    return tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Update Task
  Future<void> updateTask(Task task) async {
    await tasksCollection.doc(task.id).update(task.toMap());
  }

  // Delete Task
  Future<void> deleteTask(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }
}
