import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GlassmorphicContainer extends StatelessWidget {
  const GlassmorphicContainer({super.key, required this.child,});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return  Align
    (
      alignment: Alignment.center,
      child:ClipRRect(
      borderRadius: BorderRadius.circular(15),
      
      child:Container(
        width: MediaQuery.of(context).size.width*0.8,
        decoration: BoxDecoration(
          borderRadius:  BorderRadius.circular(15),
          color:Colors.white.withOpacity(0.4),
          border:Border.all(
            color:Colors.white.withOpacity(0.4),
          )
        ),
        child:child,
      
      ),
      ),
    );
  }
}