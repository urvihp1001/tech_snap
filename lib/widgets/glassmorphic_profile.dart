import 'dart:ui';

import 'package:flutter/material.dart';


class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;

  const GlassmorphicContainer({super.key, required this.child, this.width=350,
   this.height=200,  this.borderRadius=20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height:height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(colors: [
           Colors.white.withOpacity(0.2),
           Colors.white.withOpacity(0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,

        ),
        border:Border.all(color: Colors.white.withOpacity(0.2),
        width:1.5,
        )
      ),
      child:ClipRRect(borderRadius:  BorderRadius.circular(borderRadius),
      child: BackdropFilter(filter: ImageFilter.blur(
        sigmaX: 10.0,
        sigmaY: 10.0,
      ),
      child: child,
      ),
      )
    );
  }
}