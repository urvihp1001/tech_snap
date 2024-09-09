// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:JHC_MIS/models/user.dart' as model;
import 'package:JHC_MIS/providers/user_provider.dart';
import 'package:JHC_MIS/screens/admindashboard.dart';
import 'package:JHC_MIS/screens/dashboard.dart';
import 'package:JHC_MIS/screens/add_task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class webScreenLayout extends StatelessWidget {
  const webScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<Userprovider>(context).getUser;

    Widget screen;
if(user.role=='Admin'||user.role=='Engineer')
{
  screen=Dashboard();
}
else if(user.role=='Faculty')
{
  screen=AddTask();
}else
{
  screen=Center(child: Text('Redirecting...'),);
}
return Scaffold(body:screen);
  }
}
