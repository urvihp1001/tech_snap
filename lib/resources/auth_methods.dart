
// ignore_for_file: avoid_print

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:tech_snap/models/user.dart" as model;
import "package:tech_snap/resources/storage_methods.dart";

class AuthMethods{
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  Future<model.User> getUserDetails() async 
  {
    //firebase user used
    User currentUser= _auth.currentUser!;
    DocumentSnapshot snap= await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }
  //sign up user
  Future <String> signUpUser(
    {
      required String email,//auth
      required String password,//auth
      required String username,//firestore
      required String bio,//firestore
     Uint8List? file, //i guess profile pic //firestore
    }
  ) async{
String res="";
try{
if(email.isNotEmpty||password.isNotEmpty||username.isNotEmpty||bio.isNotEmpty)
{
UserCredential cred= await _auth.createUserWithEmailAndPassword(email: email, password: password);
print(cred.user!.uid);
//check if upload
String photoURL= await Storage().uploadImageToSource('profilePics', file!, false);//create Profilepics folder

model.User user= model.User(username: username, bio: bio, email: email,
 followers:[], following: [], photoURL: photoURL, 
 subscriptions: [], uid: cred.user!.uid);

//add user to our database

await _firestore.collection("users").doc(cred.user!.uid).set(user.toJson(),);//converts user obj to JSON which firestore stores as doc
//document oriented database
/*await _firestore.collection('users').add({
 'username':username,
  'uid':cred.user!.uid,//every user's uid
  email:email,
  bio:bio,
  'followers':[],
  'following':[],
});*/
res="success";
}else{
    res="Please enter all fields";
  }
  
}on FirebaseAuthException catch(err){

  res=err.toString();
}
return res;
  }
  //logging in user
  Future<String> loginUser({required String email, required String password})async
  {
    String res="";
  try{
    if(email.isNotEmpty||password.isNotEmpty){
      //logic separate from ui
    await  _auth.signInWithEmailAndPassword(email: email, password: password);
    res="success";
  }else{
    res="Please enter all fields";
  }
  }on FirebaseAuthException
  catch(err){
    res=err.toString();
  }
  return res;
  }
}