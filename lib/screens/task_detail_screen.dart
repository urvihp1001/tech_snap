import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:JHC_MIS/models/task.dart';
import 'package:JHC_MIS/models/comments.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Title: ${task.title}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Description: ${task.description}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Status: ${task.status}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Deadline: ${task.deadline.toString()}'),
          ),
          if (task.status == 'red') ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Explanation: ${task.explanation}'),
            ),
          ],
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('task_id', isEqualTo: task.id)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var comments = snapshot.data!.docs.map((doc) => Comment.fromFirestore(doc)).toList();

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var comment = comments[index];
                    return ListTile(
                      title: Text(comment.commentText),
                      subtitle: Text('Posted by: ${comment.userId}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(hintText: 'Add a comment'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _addComment(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: task.status == 'green'
          ? FloatingActionButton(
              child: Icon(Icons.flag),
              onPressed: () {
                _flagTask(context);
              },
            )
          : null,
    );
  }

  final TextEditingController _commentController = TextEditingController();

  void _addComment(BuildContext context) {
    final comment = Comment(
      id: '',
      taskId: task.id,
      userId: 'engineer_id', // Replace with actual engineer/admin ID
      commentText: _commentController.text,
      created_at: DateTime.now(),
    );

    FirebaseFirestore.instance.collection('comments').add(comment.toFirestore());
    _commentController.clear();
  }

  void _flagTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Flag Task'),
        content: TextField(
          controller: _explanationController,
          decoration: InputDecoration(hintText: 'Explain why it didn’t get solved'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Flag'),
            onPressed: () {
              FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
                'status': 'red',
                'explanation': _explanationController.text,
                'deadline': DateTime.now().add(Duration(days: 1)), // Update deadline
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  final TextEditingController _explanationController = TextEditingController();
}
