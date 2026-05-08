import 'package:flutter/material.dart';

class LabelTitle extends StatelessWidget {
  final String title;
  final double? size;
  final Color? color;
  final TextAlign? align;

  const LabelTitle({
    Key? key,
    required this.title,
    this.size, 
    this.color,
    this.align,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {   
    return Text(
        title,
        textScaleFactor: 1.0,
        textAlign: align,
        style: TextStyle(
          color: color ?? Theme.of(context).hintColor,
          fontSize: size ?? 25,
          fontWeight: FontWeight.bold,
        ),
      );
  }
}
