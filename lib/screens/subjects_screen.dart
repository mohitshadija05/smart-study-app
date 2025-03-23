import 'package:flutter/material.dart';

class SubjectsScreen extends StatefulWidget {
  final List<String> subjects;

  SubjectsScreen({required this.subjects}); // ✅ Fix: Added required parameter

  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  TextEditingController subjectController = TextEditingController();

  void addSubject() {
    if (subjectController.text.isNotEmpty) {
      setState(() {
        widget.subjects.add(subjectController.text);
        subjectController.clear();
      });
    }
  }

  void removeSubject(int index) {
    setState(() {
      widget.subjects.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subjects"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: "Enter Subject Name",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addSubject,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.subjects.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(widget.subjects[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeSubject(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Show message if no subjects are found
            if (widget.subjects.isEmpty)
              Text("No subjects found", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
