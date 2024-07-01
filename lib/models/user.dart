import 'package:cloud_firestore/cloud_firestore.dart';

class User{
   final String username;
  final String uid;//every user's uid
  final String email;
  final String bio;
  final String photoURL;
  final List followers, following, subscriptions;
  const User({
    required this.username,
    required this.bio,
    required this.email,
    required this.followers,
    required this.following,
    required this.photoURL,
    required this.subscriptions,
    required this.uid,
  });
  // convert user object required to JSON object (for storing in doc)-- serialisation
  Map<String,dynamic> toJson()=>{
    "username":username,
    "uid":uid,
    "email":email,
    "photoURL":photoURL,
    "bio":bio,
    "followers":followers,
    "following":following,
    "subscriptions":subscriptions,
  };
  static User fromSnap(DocumentSnapshot snap)
  {
    var snapshot=snap.data() as Map<String,dynamic>;
    return User(
      username: snapshot['username'],
      uid:snapshot['uid'],
      email:snapshot['email'],
      photoURL: snapshot['photoURL'],
      bio: snapshot['bio'],
      followers: snapshot['followers'],
      following: snapshot['following'],
      subscriptions: snapshot['subscriptions']
    );//deserialisation
  }
}