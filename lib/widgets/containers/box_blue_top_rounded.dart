import 'package:flutter/material.dart';

BoxDecoration backgroundDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
        colors: [Color.fromRGBO(43, 196, 243, 1), Color.fromRGBO(0, 174, 238, 1),
                Color.fromRGBO(0, 149, 218, 1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(35),
    ),
  );
}
