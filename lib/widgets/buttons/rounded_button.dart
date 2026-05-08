import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool? isEdit;
  final double? size;

  const RoundedButton({
    Key? key,
    required this.onPressed, 
    this.isEdit, 
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

        child: MaterialButton(
          minWidth: size ?? 43,
          height: size ?? 43,
          shape: CircleBorder(),
          child: Text("+", style: TextStyle(color: Colors.white, fontSize: 25),),
          color: Theme.of(context).primaryColor,
          textColor: Colors.amber,
          onPressed: onPressed,
        ),
      );
  

  }
}
