import 'package:flutter/material.dart';

class FloatButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool? isEdit;

  const FloatButton({
    Key? key,
    required this.onPressed, 
    this.isEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
      FloatingActionButton(
        onPressed: onPressed,
        child: Container(
          width: 60,
          height: 60,
          child: Icon(isEdit != null ? Icons.edit : Icons.add,size: 40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color.fromRGBO(43, 196, 243, 1), Color.fromRGBO(0, 174, 238, 1),
                Color.fromRGBO(0, 149, 218, 1)])
          ),
        ),
      );
  }
}
