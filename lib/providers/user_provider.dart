// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:tech_snap/models/user.dart';
import 'package:tech_snap/resources/auth_methods.dart';

class Userprovider with ChangeNotifier {
  User? _user; // private field
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user??User(username: '', bio: '', email: '', followers: [], following: [], photoURL:'',
   subscriptions:[], uid: '');

  // refresh user
  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners(); // notify all listeners that data has changed so please update
  }
}
