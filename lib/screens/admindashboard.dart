import 'package:JHC_MIS/screens/TaskComments.dart';
import 'package:JHC_MIS/screens/TaskDetails.dart';
import 'package:JHC_MIS/widgets/glassmorphic_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:JHC_MIS/utils/colors.dart';
import 'package:intl/intl.dart';  // For formatting date and time
import 'dart:async';  // For the timer functionality

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Tasks"),
        backgroundColor: blueColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStartColor, gradientEndColor],
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
              padding: const EdgeInsets.all(16.0), // Padding for consistency
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  DateTime taskDateTime = task['date_time'].toDate();
                  bool isOverdue = DateTime.now().difference(taskDateTime).inHours > 48;
                  String status = task['status'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassmorphicContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Task ID: ${task.id}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: blueColor,
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
                              _buildTaskDetailRow("Status", status,
                                  isOverdue ? Colors.red : Colors.green),
                              StreamBuilder<DateTime>(
                                stream: _timerStream(),
                                builder: (context, timerSnapshot) {
                                  if (!timerSnapshot.hasData) {
                                    return SizedBox.shrink(); // Or a loading indicator
                                  }
                                  Duration remainingTime = taskDateTime.add(Duration(hours: 24)).difference(timerSnapshot.data!);
                                  String timeRemaining = remainingTime.isNegative
                                      ? "00:00:00"
                                      : "${remainingTime.inHours.toString().padLeft(2, '0')}:${remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}";
                                  
                                  return _buildTaskDetailRow("Time Remaining", timeRemaining, isOverdue ? Colors.red : Colors.green);
                                },
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _toggleTaskStatus(task.id, status);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:status == 'completed' ? Colors.green : Colors.red,
                                ),
                                child: Text(status == 'completed' ? "Mark as Pending" : "Mark as Completed",style:TextStyle(fontFamily: 'Ubuntu') ,),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _viewTaskComments(context, task.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text("View Comments", style:TextStyle(fontFamily: 'Ubuntu')),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _addComment(context, task.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: Text("Add Comment",style:TextStyle(fontFamily: 'Ubuntu')),
                              ),
                            ],
                          ),
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

  // Create a stream that emits the current time every second
  Stream<DateTime> _timerStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(Duration(seconds: 1));
    }
  }

  // Helper to build task detail rows
  Widget _buildTaskDetailRow(String label, String value, [Color? color]) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color:blueColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 12,
            color: color ?? blueColor,
          ),
        ),
      ],
    );
  }

  // Toggle task status
  void _toggleTaskStatus(String taskId, String currentStatus) {
    String newStatus = currentStatus == 'pending' ? 'completed' : 'pending';
    FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'status': newStatus,
    }).then((_) {
      print('Task status updated to $newStatus');
    }).catchError((e) {
      print('Error updating status: $e');
    });
  }

  // View comments from engineers/admins
  void _viewTaskComments(BuildContext context, String taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCommentsPage(taskId: taskId),
      ),
    );
  }

  // Add comment functionality for engineers/admins
 void _addComment(BuildContext context, String taskId) {
  TextEditingController commentController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Add Comment", style: TextStyle(fontFamily: 'Ubuntu')),
      content: TextField(
        controller: commentController,
        maxLines: 5,
        decoration: InputDecoration(hintText: "Enter your comment here"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            String comment = commentController.text.trim();
            if (comment.isNotEmpty) {
              try {
                // Get the current server timestamp
                Timestamp currentTime = Timestamp.now();

                // Fetch the current comments array
                DocumentSnapshot doc = await FirebaseFirestore.instance.collection('tasks').doc(taskId).get();
                List<dynamic> currentComments = doc['comments'] ?? [];

                // Add the new comment to the array
                currentComments.add({
                  'comment': comment,
                  'role': 'Admin/Engineer',  // You can distinguish by user role if needed
                  'timestamp': currentTime,  // Use the fetched server timestamp
                });

                // Update the document with the new comments array
                await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
                  'comments': currentComments,
                });

                print('Comment added');
                Navigator.pop(context); // Close the dialog after submitting
              } catch (e) {
                print('Error adding comment: $e');
              }
            }
          },
          child: Text("Submit"),
        ),
      ],
    ),
  );
}
}