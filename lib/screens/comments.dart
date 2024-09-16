import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  TaskDetailScreen({required this.taskId});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> _taskFuture;

  @override
  void initState() {
    super.initState();
    _taskFuture = _firestore.collection('tasks').doc(widget.taskId).get();
  }

  Future<void> _updateTimer(DateTime newDueDate) async {
    await _firestore.collection('tasks').doc(widget.taskId).update({
      'dueDate': Timestamp.fromDate(newDueDate),
      'timeUpdated': true,
      'status': 'Time Extended',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _taskFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available.'));
          }

          var task = snapshot.data!.data() as Map<String, dynamic>;
          var engineerComment = task['engineerComment'] ?? 'No comments';
          var dueDate = (task['dueDate'] as Timestamp).toDate();
          bool requestTimeExtension = task['requestTimeExtension'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Engineer Comment:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(engineerComment),
                SizedBox(height: 16),
                if (requestTimeExtension) ...[
                  Text(
                    'Current Due Date: ${dueDate.toLocal()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Modify Timer:'),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime newDueDate = dueDate.add(Duration(hours: 24)); // Example: Adding 24 hours
                      await _updateTimer(newDueDate);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timer updated')));
                    },
                    child: Text('Add 24 Hours'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime resetDueDate = DateTime.now().add(Duration(hours: 24)); // Example: Resetting to 24 hours from now
                      await _updateTimer(resetDueDate);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timer reset')));
                    },
                    child: Text('Reset Timer'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
