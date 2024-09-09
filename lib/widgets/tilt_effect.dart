import 'package:flutter/material.dart';
import 'dart:math';

class TiltEffect extends StatefulWidget {
  final Widget child;
  final double tiltAmount;
  final double perspective;
  final double scale;

  const TiltEffect({
    Key? key,
    required this.child,
    this.tiltAmount = 0.08,
    this.perspective = 0.002,
    this.scale = 1.02,
  }) : super(key: key);

  @override
  _TiltEffectState createState() => _TiltEffectState();
}

class _TiltEffectState extends State<TiltEffect> {
  double _x = 0;
  double _y = 0;

  void _handleMouseEnter(PointerEvent event) {
    _updateTilt(event);
  }

  void _handleMouseMove(PointerEvent event) {
    _updateTilt(event);
  }

  void _handleMouseExit(PointerEvent event) {
    setState(() {
      _x = 0;
      _y = 0;
    });
  }

  void _updateTilt(PointerEvent event) {
    final size = context.size!;
    final offset = event.localPosition;

    setState(() {
      _x = ((offset.dy / size.height) - 0.5) * widget.tiltAmount;
      _y = ((offset.dx / size.width) - 0.5) * widget.tiltAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _handleMouseEnter,
      onHover: _handleMouseMove,
      onExit: _handleMouseExit,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, widget.perspective)
          ..rotateX(_x)
          ..rotateY(_y)
          ..scale(widget.scale),
        alignment: FractionalOffset.center,
        child: widget.child,
      ),
    );
  }
}
