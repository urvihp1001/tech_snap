import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class Storage{
  final FirebaseStorage _storage=FirebaseStorage.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  Future<String> uploadImageToSource(String childName, Uint8List file, bool isPost) async
  {
    Reference ref= _storage.ref().child(childName).child(_auth.currentUser!.uid);
    if(isPost)
    {
      String id=const Uuid().v1();
      ref=ref.child(id);
    }
    //make it web-compat so no file but data
    UploadTask uploadTask= ref.putData(file);//like a future- when complete
    TaskSnapshot snap=await uploadTask;
    String downloadURL= await snap.ref.getDownloadURL();//upload it to correct uid
    //String to Future<String> is AWAIT
    return downloadURL;
  }
}