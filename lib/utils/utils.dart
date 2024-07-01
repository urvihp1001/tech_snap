// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imgpicker=ImagePicker();
 XFile? _file= await _imgpicker.pickImage(source: source);
 if(_file!=null)//ie user actually went to pick image didnt press back-button
 {
  return await _file.readAsBytes();// to be web-compatible
 }
 print("No image selected");
}
showSnackBar(String content,BuildContext context)
{
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text(content)
    )
    );
}