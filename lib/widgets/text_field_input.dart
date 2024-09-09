import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:JHC_MIS/utils/colors.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  const TextFieldInput({super.key, required this.textEditingController, required this.hintText, 
   this.isPass=false, required this.textInputType
  });
  
  @override
  Widget build(BuildContext context) {
    final inputBorder=OutlineInputBorder(
          borderSide: Divider.createBorderSide(context)
        );
    return TextField(
      controller:textEditingController,
      
      decoration:InputDecoration(
        
        hintText:hintText,
        hintStyle:TextStyle(color:blueColor,
        fontFamily: 'Ubuntu',
        
        ),
        
        fillColor: primaryColor,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled:true,
        contentPadding: const EdgeInsets.all(8),

      ),
      keyboardType:textInputType ,
      obscureText: isPass,
      cursorColor: blueColor,
      style: TextStyle(fontFamily: 'Ubuntu',
      color: blueColor,
      
      ),
    );
  }
}