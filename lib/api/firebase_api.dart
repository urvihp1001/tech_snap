import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
Future<void> handleBackgroundMessage(RemoteMessage message)async{
  print('Title:${message.notification?.title}');
  print('Body:${message.notification?.body}');
  
  print('Payload:${message.data}');
  
}

class FirebaseApi
{
  final FirebaseMessaging _firebaseMessaging=FirebaseMessaging.instance;
  Future<void>initNotifications()async{
    if(!kIsWeb)
    {
    await _firebaseMessaging.requestPermission();
    }
    final fcmToken=await _firebaseMessaging.getToken();
    print('FCM:$fcmToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}