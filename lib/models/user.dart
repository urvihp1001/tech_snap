import 'package:cloud_firestore/cloud_firestore.dart';

class User{
   final String role;
  final String uid;//every user's uid
  final String email;

  const User({
    required this.role,
    required this.uid,
    required this.email,
   
  });
  // convert user object required to JSON object (for storing in doc)-- serialisation
  Map<String,dynamic> toJson()=>{
    "role":role,
    "uid":uid,
    "email":email,
    
  };
  static User fromSnap(DocumentSnapshot snap)
  {
    var snapshot=snap.data() as Map<String,dynamic>;
    return User(
      role: snapshot['role'],
      uid:snapshot['uid'],
      email:snapshot['email'],
      );//deserialisation
  }
}