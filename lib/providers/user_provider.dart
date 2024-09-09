// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:JHC_MIS/models/user.dart';
import 'package:JHC_MIS/resources/auth_methods.dart';

class Userprovider with ChangeNotifier {
  User? _user; // private field
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user??User(role: '',  email: '',  uid: '');

  // refresh user
  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners(); // notify all listeners that data has changed so please update
  }
}
