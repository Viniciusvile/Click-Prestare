import 'package:flutter/material.dart';

BoxDecoration BoxSindico() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(35),
      topLeft: Radius.circular(35),
      bottomRight: Radius.circular(35),
      bottomLeft: Radius.circular(35),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3), // changes position of shadow
      ),
    ],
  );
}
