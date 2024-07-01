import 'dart:ui';

import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  const GlassmorphicContainer({super.key, required this.child,});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX:10, sigmaY:10),
      child:Container(
        decoration: BoxDecoration(
          borderRadius:  BorderRadius.circular(15),
          color:Colors.white.withOpacity(0.1),
          border:Border.all(
            color:Colors.white.withOpacity(0.2),
          )
        ),
        child:child,
      )
      ),
    );
  }
}