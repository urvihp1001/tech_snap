// ignore_for_file: prefer_const_constructors

import 'package:JHC_MIS/api/firebase_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:JHC_MIS/providers/user_provider.dart';
import 'package:JHC_MIS/responsive/mobile_screen_layout.dart';
import 'package:JHC_MIS/responsive/responsive_layout_screen.dart';
import 'package:JHC_MIS/responsive/web_screen_layout.dart';
import 'package:JHC_MIS/screens/login_screen.dart';

//import 'package:flutter/widgets.dart';
import 'package:JHC_MIS/utils/colors.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb)
  {
    await Firebase.initializeApp(
    options:const FirebaseOptions(
    apiKey: "APIKEY", 
    appId: "1:831630626654:web:cd0df057bd41a1967e09cf",
    messagingSenderId: "",
   
    projectId: "infortech-15683",
    storageBucket: "infortech-15683.appspot.com",
   
    ),

    );
   
  }else{
   
await Firebase.initializeApp();
await FirebaseApi().initNotifications();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers:[
      ChangeNotifierProvider(create: (_)=>Userprovider())
    ],//bigger app more providers
    child: MaterialApp(
      title: 'JHC_MIS',
      theme: ThemeData.dark().copyWith(
       
      ),
      debugShowCheckedModeBanner: false,
      /*home: */
        //persisting user auth
        //home:StreamBuilder(stream: FirebaseAuth.instance.idTokenChanges(), //we dont want to go back to auth
        home:StreamBuilder(stream:FirebaseAuth.instance.authStateChanges() ,builder:(context, snapshot) {
          if(snapshot.connectionState==ConnectionState.active){
            if(snapshot.hasData){
      ResponsiveLayout(
        mobileScreenLayout:mobileScreenLayout(),
        webScreenLayout:webScreenLayout() ,);
            }else if(snapshot.hasError){
              return Center(child:Text('${snapshot.error}'));
            }
          }
          if(snapshot.connectionState==ConnectionState.waiting)
          {
 return Center(child:CircularProgressIndicator(
  color: primaryColor,
 ));
          }
          return LoginScreen();
        },),
    ),  
    );
      //userchanges - forget password functionality
      
  }

}


