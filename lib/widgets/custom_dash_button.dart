// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const DashboardButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.black,
        elevation: 10,
        backgroundColor: isSelected
            ? Color.fromARGB(255, 99, 11, 255)
            : Color.fromARGB(255, 249, 245, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(0),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/deviceprofile.svg',
            height: 50,  
          ),
          SizedBox(height: 10),  
          Text(
            text,
            style: TextStyle(
              fontSize: 16,  
              color: isSelected
                  ? Colors.white
                  : Color.fromARGB(255, 99, 11, 255),
            ),
          ),
        ],
      ),
    );
  }
}
