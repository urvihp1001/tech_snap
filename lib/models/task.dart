import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // For formatting date and time
import 'dart:async';  // For the timer functionality

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Tasks"),
        backgroundColor: Colors.blue,  // Use your custom color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],  // Use your custom gradient colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return Center(child: Text('No tasks available'));
            }
            final tasks = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  DateTime taskDateTime = task['date_time'].toDate();
                  DateTime deadline = task['deadline'].toDate();
                  bool isOverdue = DateTime.now().difference(deadline).inHours > 0;
                  String status = task['status'];
                  bool requestTimeExtension = task['requestTimeExtension'] ?? false;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Task ID: ${task.id}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,  // Use your custom color
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildTaskDetailRow("Building", task['building']),
                            _buildTaskDetailRow("Floor", task['floor_number']),
                            _buildTaskDetailRow("Room", task['room_number']),
                            _buildTaskDetailRow("Device", task['device_id']),
                            _buildTaskDetailRow("Issue", task['issue']),
                            _buildTaskDetailRow(
                              "Date",
                              DateFormat('yyyy-MM-dd – kk:mm').format(taskDateTime),
                            ),
                            _buildTaskDetailRow("Status", status, isOverdue ? Colors.red : Colors.green),
                            StreamBuilder<DateTime>(
                              stream: _timerStream(),
                              builder: (context, timerSnapshot) {
                                if (!timerSnapshot.hasData) {
                                  return SizedBox.shrink(); // Or a loading indicator
                                }
                                DateTime currentTime = timerSnapshot.data!;
                                Duration remainingTime = deadline.difference(currentTime);
                                String timeRemaining = remainingTime.isNegative
                                    ? "00:00:00"
                                    : "${remainingTime.inHours.toString().padLeft(2, '0')}:${remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}";

                                return _buildTaskDetailRow("Time Remaining", timeRemaining, isOverdue ? Colors.red : Colors.green);
                              },
                            ),
                            SizedBox(height: 16),

                            // Use FutureBuilder to check if the current user is an admin
                            FutureBuilder<bool>(
                              future: _isAdmin(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                // Ensure the snapshot has data and the user is an admin
                                if (snapshot.hasData && snapshot.data == true) {
                                  return Column(
                                    children: [
                                      // Button for requesting time extension (only visible if no extension requested)
                                      if (!requestTimeExtension) ...[
                                        ElevatedButton(
                                          onPressed: () {
                                            _requestTimeExtension(task.id);
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                          child: Text("Request Extension"),
                                        ),
                                      ],

                                      // Button for admin to approve extension (only visible if an extension is requested)
                                      if (requestTimeExtension) ...[
                                        ElevatedButton(
                                          onPressed: () {
                                            _approveTimeExtension(task.id);
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          child: Text("Approve Extension"),
                                        ),
                                        Text(
                                          'Extension Requested',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                }

                                // Hide the buttons for non-admins
                                return SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Stream for the timer
  Stream<DateTime> _timerStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(Duration(seconds: 1));
    }
  }

  // Check if the current user is an admin
  Future<bool> _isAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    String role = userDoc['role'];
    return role == 'admin';
  }

  // Request time extension from the engineer's side
  void _requestTimeExtension(String taskId) {
    FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'requestTimeExtension': true,
      'comments': FieldValue.arrayUnion([{
        'user_id': FirebaseAuth.instance.currentUser?.uid,
        'comment': 'Requesting an extra 24 hours.',
        'timestamp': Timestamp.now(),
      }])
    }).then((_) {
      print('Extension requested');
    }).catchError((e) {
      print('Error requesting extension: $e');
    });
  }

  // Approve the time extension by admin
  void _approveTimeExtension(String taskId) {
    FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'requestTimeExtension': false,
      'deadline': Timestamp.fromDate(DateTime.now().add(Duration(hours: 24))),
      'comments': FieldValue.arrayUnion([{
        'user_id': FirebaseAuth.instance.currentUser?.uid,
        'comment': 'Extension approved. New deadline: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now().add(Duration(hours: 24)))}',
        'timestamp': Timestamp.now(),
      }])
    }).then((_) {
      print('Extension approved');
    }).catchError((e) {
      print('Error approving extension: $e');
    });
  }

  // Helper to build task detail rows
  Widget _buildTaskDetailRow(String label, String value, [Color? color]) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.blue,  // Use your custom color
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.blue,  // Use your custom color
          ),
        ),
      ],
    );
  }
}
