import 'package:flutter/material.dart';

class Loader extends StatelessWidget  {
  
  const Loader({
    Key? key,
    required this.opacity,
    required this.dismissibles,
    required this.color,
    required this.loadingTxt,
  }) : super(key: key);

  final double opacity;
  final bool dismissibles;
  final Color color;
  final String loadingTxt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1000,
      height: 1000,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: opacity,
            child: const ModalBarrier(dismissible: false, color: Colors.black),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 10),
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new AssetImage("assets/loading.gif"),
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
