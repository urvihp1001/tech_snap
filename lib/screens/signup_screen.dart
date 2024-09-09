import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:JHC_MIS/resources/auth_methods.dart';
import 'package:JHC_MIS/responsive/mobile_screen_layout.dart';
import 'package:JHC_MIS/responsive/responsive_layout_screen.dart';
import 'package:JHC_MIS/responsive/web_screen_layout.dart';
import 'package:JHC_MIS/screens/login_screen.dart';
import 'package:JHC_MIS/utils/colors.dart';
import 'package:JHC_MIS/utils/utils.dart';
import 'package:JHC_MIS/widgets/glass_morph.dart';
import 'package:JHC_MIS/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  
  final TextEditingController roleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole;
  bool _isLoading = false;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
   
    roleController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _pageController.dispose();
  }

  

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole!,
        );
    setState(() {
      _isLoading = false;
    });

    if (res != "success") {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
              webScreenLayout: webScreenLayout(),
              mobileScreenLayout: mobileScreenLayout())));
    }
  }

  void navigateToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
             gradient: LinearGradient(colors: [gradientStartColor,gradientEndColor],
             begin: Alignment.topCenter,
             end:Alignment.bottomCenter,
             )
             ),
          padding: EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2), //up balance padding center
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                child: GlassmorphicContainer(
                  
                  child: PageView(
                    controller: _pageController,
                    children: [
                      buildFirstPage(),
                    
                    ],
                  ),
                ),
              ),
              Spacer(flex: 2),//down balance padding center
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text("Already have an account? ", style: TextStyle(fontFamily: 'Ubuntu', color: blueColor),),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: Container(
                      child: Text(
                        "Log in.",
                        style: TextStyle(
                          fontFamily: 'Ubuntu', fontWeight: FontWeight.bold, color: blueColor),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFirstPage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("JHC-MIS",
          
          style: TextStyle(fontSize: 60,
          color: blueColor,
            fontFamily: 'Ubuntu',
          fontWeight: FontWeight.bold,),
          ),
          SizedBox(height: 48),
          TextFieldInput(
            textEditingController: emailController,
            hintText: 'Enter your email',
            textInputType: TextInputType.emailAddress,
          ),
          SizedBox(height: 24),
          TextFieldInput(
            textEditingController: passwordController,
            hintText: 'Enter your password',
            textInputType: TextInputType.text,
            isPass: true,
          ),
            SizedBox(height: 24),
          DropdownButtonFormField( style: TextStyle(color: Colors.red), items: ['Admin','Engineer','Faculty'].map((role)=>DropdownMenuItem(child: Text(role),value: role,)).toList(), onChanged: (value){setState(() {
            selectedRole=value;
            
          });},
          decoration: InputDecoration(
            labelText: "Select Role",
            labelStyle: TextStyle(color: Colors.black),
            
            border:OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          ),

           SizedBox(height: 24),
          InkWell(
            onTap: signUpUser,
            child: Container(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: primaryColor,
                    ))
                  : Text("Sign Up"),
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                color: blueColor,
              ),
            ),
          ),
        ]
      ),
    );
  }

  
  }

