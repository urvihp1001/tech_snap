import 'package:cloud_firestore/cloud_firestore.dart';

class Comment
{
  String id;
  String taskId;
  String userId;
  String commentText;
  DateTime created_at;
  
  Comment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.commentText,
    // ignore: non_constant_identifier_names
    required this.created_at,
   
  });
  factory Comment.fromFirestore(DocumentSnapshot doc)
  {
Map data=doc.data()as Map<String,dynamic>;
return Comment(id: doc.id, taskId: data['taskId'], userId: data['userId'], 
commentText:data ['commentText'], created_at: data['created_at'], );

  }
  Map<String,dynamic> toFirestore()
  {
    return{
      'taskId':taskId,
      'userId':userId,
      'commentText':commentText,
      'created_at':created_at,
     
    };
  }
}
