import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Import Firestore

class SessionsScreen extends StatefulWidget {
  @override
  _SessionsScreenState createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  int _minutes = 25;
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  List<String> sessionHistory = [];
  TextEditingController _timeController = TextEditingController();

  void startTimer() {
    if (_timer != null) _timer!.cancel();

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds == 0) {
          if (_minutes == 0) {
            _timer!.cancel();
            _isRunning = false;
            saveSession(); // ✅ Now correctly saving to Firestore
          } else {
            _minutes--;
            _seconds = 59;
          }
        } else {
          _seconds--;
        }
      });
    });
  }

  // ✅ Save session to Firestore
  void saveSession() async {
    await FirebaseFirestore.instance.collection('sessions').add({
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      sessionHistory.add("${_timeController.text} min session completed");
    });
  }

  void pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void stopTimer() {
    if (_timer != null) _timer!.cancel();

    setState(() {
      _minutes = int.tryParse(_timeController.text) ?? 25;
      _seconds = 0;
      _isRunning = false;
    });
  }

  void setTimer() {
    int? newTime = int.tryParse(_timeController.text);
    if (newTime != null && newTime > 0) {
      setState(() {
        _minutes = newTime;
        _seconds = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Study Sessions"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Session Timer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter minutes",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: setTimer,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text("Start"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isRunning ? pauseTimer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text("Pause"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: stopTimer,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Stop"),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "Session History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: sessionHistory.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Icon(Icons.history, color: Colors.purple),
                      title: Text(sessionHistory[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
