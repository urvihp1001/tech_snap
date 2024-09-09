import 'package:JHC_MIS/screens/TaskComments.dart';
import 'package:JHC_MIS/screens/TaskDetails.dart';
import 'package:JHC_MIS/widgets/glassmorphic_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:JHC_MIS/utils/colors.dart';
import 'package:intl/intl.dart';  // For formatting date and time

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task"),
        backgroundColor: blueColor,
      ),
      body:Container(
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
                bool isOverdue = DateTime.now().difference(taskDateTime).inHours > 24;
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
                                color: Colors.white,
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
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _toggleTaskStatus(task.id, status);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: status == 'completed' ? Colors.green : Colors.red,
                              ),
                              child: Text(status == 'completed' ? "Mark as Pending" : "Mark as Completed"),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _viewTaskComments(context, task.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: Text("View Comments"),
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

  // Helper to build task detail rows
  Widget _buildTaskDetailRow(String label, String value, [Color? color]) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.red,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.white,
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

  // View comments from engineers
  void _viewTaskComments(BuildContext context, String taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCommentsPage(taskId: taskId),
      ),
    );
  }
}
