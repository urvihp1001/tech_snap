import 'package:JHC_MIS/screens/dashboard.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:JHC_MIS/models/user.dart' as model;
import 'package:JHC_MIS/providers/user_provider.dart';
import 'package:JHC_MIS/utils/colors.dart';
import 'package:JHC_MIS/utils/globals.dart';

class mobileScreenLayout extends StatefulWidget {
  const mobileScreenLayout({super.key});

  @override
  State<mobileScreenLayout> createState() => _mobileScreenLayoutState();
}

class _mobileScreenLayoutState extends State<mobileScreenLayout> {
  String username="";
  int _page=0;
  late PageController pageController;
  @override
  void initState()
  {
    super.initState();
    pageController=PageController();
  }
  @override
  void dispose() {
   super.dispose();
   pageController.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    model.User user=Provider.of<Userprovider>(context).getUser;
    return  Scaffold(
      body:Dashboard(),
      backgroundColor: mobileBackgroundColor,
      
      
    );
  }
}
//reduce calls to db so we r gonna use provider pkg