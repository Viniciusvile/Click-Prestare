import 'package:flutter/material.dart';

BoxDecoration BoxMainRounded() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(35),
      topLeft: Radius.circular(35),
    ),
  );
}
