
// ignore_for_file: prefer_final_fields, use_build_context_synchronously, prefer_const_constructors

import 'package:JHC_MIS/utils/colors.dart';
import 'package:JHC_MIS/widgets/glass_morph.dart';
import 'package:JHC_MIS/widgets/text_field_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController=TextEditingController();

 
  bool _isLoading=false;
 @override
 void dispose()
 {
  super.dispose();
  emailController.dispose();
 
 }
 Future passwordReset()async
 {
try{
  await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());//remove spaces
  showDialog(context: context, builder: (context){
return AlertDialog(
  content: Text("Password Reset link sent! Please check your email"),
);
});
} on FirebaseAuthException catch(e)
{
print(e);
showDialog(context: context, builder: (context){
return AlertDialog(
  content: Text(e.message.toString()),
);
});
}
 }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(child:
      Container(
          decoration: BoxDecoration(
           gradient: LinearGradient(colors: [gradientStartColor,gradientEndColor],
             begin: Alignment.topCenter,
             end:Alignment.bottomCenter,
         
            )
          ),
        //padding so that textfield doesnt take up full width
        padding: EdgeInsets.symmetric(horizontal: 32),
        width:double.infinity,//full width of the device
      
        child:Center(
          
          
          child:
           GlassmorphicContainer(
            
            child: Padding(padding: 
           EdgeInsets.all(16),
           child:Column(
            mainAxisSize:MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
              //in row format
          //mainaxis is for column format
          
          children: [
            Text("JHC-MIS",
          style: TextStyle(fontSize: 60,
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.bold,
          
          color: blueColor),
            ),
            Text("Please enter your email for us to send you a password reset link",
          style: TextStyle(fontSize: 20,
          fontFamily: 'Ubuntu',
          
          
          color: blueColor),),
            //txt field for email
            const SizedBox(height:48),
            TextFieldInput(textEditingController: emailController, hintText: 'Enter your email', textInputType:TextInputType.emailAddress,),
            const SizedBox(height:24),
            
            
            //txt field for password
            InkWell(
              onTap: passwordReset,
              child:Container(
             child:_isLoading?Center(child:const CircularProgressIndicator(color: primaryColor,)): Text("Reset Password"),
              width:double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical:12),
              decoration: ShapeDecoration(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                color:blueColor,
                ),
            ),
            ),
            const SizedBox(height:12),
          ],
           ),
           ),
           ),
            //login button
            ),
          
           
           )
           
      ),
      );
            //svg image
            
            //transitioning to sign out- forgot password type thing
    
  }
} 