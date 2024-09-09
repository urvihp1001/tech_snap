import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCommentsPage extends StatelessWidget {
  final String taskId;

  TaskCommentsPage({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Comments'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tasks').doc(taskId).collection('comments').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No comments available'));
          }
          final comments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
                title: Text(comment['comment']),
                subtitle: Text("By: ${comment['engineer_name']}"),
              );
            },
          );
        },
      ),
    );
  }
}
