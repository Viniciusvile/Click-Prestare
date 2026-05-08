import 'package:auto_size_text/auto_size_text.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/containers/background.dart';


class NavigationDefault extends StatelessWidget {
  final String title;
  final bool? buttonEnd;
  final String? buttonRight;
  final IconData? buttonRightIcon;
  final VoidCallback? onPressed;
  final Decoration? bgDecoration;

  const NavigationDefault({
    Key? key,
    required this.title, 
    this.buttonEnd, 
    this.buttonRight, 
    this.buttonRightIcon,
    this.onPressed, 
    this.bgDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {   
    return Container(
      padding: new EdgeInsets.fromLTRB(15, 42, 20, 20),
      decoration: bgDecoration ?? backgroundDecoration(),
      child:Stack(
        alignment: Alignment.centerLeft,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            }, icon: Icon(Icons.arrow_back, size: 30, color: Colors.white)
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(45, 0, 35, 0),
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                title,
                textScaleFactor: 1.0,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                minFontSize: 18,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if(buttonEnd != null && buttonEnd == true)
            Align(alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onPressed,
                style: ButtonStyle(    
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                ),
                child: Text(getText('lb_finalizar'), textScaleFactor: 1.0, style: TextStyle(color: Colors.white),),
              ),
            ),
          if(buttonRight != null)
            Align(alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onPressed,
                style: ButtonStyle(    
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                  ),
                ),
                child: Text(buttonRight!, textScaleFactor: 1.0, style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          if(buttonRightIcon != null)
            Align(alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 1, color: Colors.white),
                ),
                child: Icon(buttonRightIcon, size: 23, color: Colors.white),
              ),
            )
        ],
      )
    );
  }
}
