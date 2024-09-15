import 'package:JHC_MIS/screens/forgot_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:JHC_MIS/resources/auth_methods.dart';
import 'package:JHC_MIS/responsive/mobile_screen_layout.dart';
import 'package:JHC_MIS/responsive/responsive_layout_screen.dart';
import 'package:JHC_MIS/responsive/web_screen_layout.dart';
import 'package:JHC_MIS/screens/signup_screen.dart';
import 'package:JHC_MIS/utils/colors.dart';
import 'package:JHC_MIS/widgets/glass_morph.dart';
import 'package:JHC_MIS/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    String res = await AuthMethods().loginUser(
      email: emailController.text, 
      password: passwordController.text,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (res == "success") { 

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          webScreenLayout: webScreenLayout(),
          mobileScreenLayout: mobileScreenLayout(),
        ),
      ));
    } else {
      setState(() {
        _errorMessage = res; 
      });
      Fluttertoast.showToast(
        msg: res,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void navigateToSignup() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStartColor, gradientEndColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 3),
              GlassmorphicContainer(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "JHC-MIS",
                        style: TextStyle(
                          fontSize: size.height*0.06,
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFieldInput(
                        textEditingController: emailController,
                        hintText: 'Enter your email',
                        textInputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      TextFieldInput(
                        textEditingController: passwordController,
                        hintText: 'Enter your password',
                        textInputType: TextInputType.text,
                        isPass: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ForgotPassword();
                              }));
                            },
                            child: Container(
                              child: Text("Forgot Password?",
                                  style: TextStyle(
                                      fontFamily: 'Ubuntu',
                                      color: blueColor,
                                      fontWeight: FontWeight.bold)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: loginUser,
                        child: Container(
                          child: _isLoading
                              ? Center(
                                  child: const CircularProgressIndicator(
                                      color: primaryColor),
                                )
                              : Text("Sign In"),
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4))),
                            color: blueColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Container(),
                flex: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text("Don't have an account? ",
                        style: TextStyle(color: blueColor, fontFamily: 'Ubuntu')),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  GestureDetector(
                    onTap: navigateToSignup,
                    child: Container(
                      child: Text("Sign up.",
                          style: TextStyle(
                              color: blueColor,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.bold)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
