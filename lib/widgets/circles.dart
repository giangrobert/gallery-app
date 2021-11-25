import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final double size;
  final List<Color> colors;

  Circle({Key? key, @required this.size = 0.0, this.colors = Colors.accents})
      : assert(size != null && size > 0),
        assert(colors != null && colors.length >= 2),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
    );
  }
}
