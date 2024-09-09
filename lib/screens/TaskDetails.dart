import 'package:JHC_MIS/widgets/glassmorphic_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:JHC_MIS/utils/colors.dart';


class TaskDetailsPage extends StatelessWidget {
  final String taskId;

  TaskDetailsPage({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
        backgroundColor: blueColor,
        centerTitle: true, // Center title alignment
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('tasks').doc(taskId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Task not found"));
          }

          final task = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0), // Padding for consistency
            child: GlassmorphicContainer(
              
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskDetailRow("Building", task['building']),
                    _buildTaskDetailRow("Floor", task['floor_number']),
                    _buildTaskDetailRow("Room", task['room_number']),
                    _buildTaskDetailRow("Device", task['device_id']),
                    _buildTaskDetailRow("Issue", task['issue']),
                    _buildTaskDetailRow("Status", task['status']),
                    _buildTaskDetailRow(
                      "Date",
                      task['date_time'].toDate().toString(),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _resolveTask(context, task.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Custom color for resolve button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Mark as Resolved"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _resolveTask(BuildContext context, String taskId) {
    FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'status': 'completed',
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task marked as resolved')),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resolving task: $e')),
      );
    });
  }
}
