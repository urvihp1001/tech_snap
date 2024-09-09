import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskComments extends StatefulWidget {
  final String taskId;
  TaskComments({required this.taskId});

  @override
  _TaskCommentsState createState() => _TaskCommentsState();
}

class _TaskCommentsState extends State<TaskComments> {
  final TextEditingController _commentController = TextEditingController();
  List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() async {
    final commentsSnapshot = await FirebaseFirestore.instance.collection('comments')
        .where('task_id', isEqualTo: widget.taskId)
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      _comments = commentsSnapshot.docs.map((doc) => doc['comment'] as String).toList();
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a comment')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('comments').add({
        'task_id': widget.taskId,
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Refresh comments
      _commentController.clear();
      _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add comment: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Comments"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_comments[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: "Add a comment",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
