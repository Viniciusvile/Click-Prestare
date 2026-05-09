import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool hasArrow;
  final bool? isRounded;
  final FractionalOffset? aligment;
  final double? size;

  const DefaultButton({
    Key? key,
    required this.title,
    this.onPressed,
    required this.hasArrow,
    this.aligment, 
    this.isRounded,
    this.size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return 
      Align(
        alignment: this.aligment ?? FractionalOffset.bottomCenter,
        child: 
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0.0),
              elevation: 5,
              minimumSize: Size(double.infinity, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(this.isRounded != null ? 30 : 12),
              ),
            ),
            child: Ink(
              height: size ?? 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color.fromRGBO(43, 196, 243, 1), Color.fromRGBO(0, 174, 238, 1),
                            Color.fromRGBO(0, 149, 218, 1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight
                ),
                borderRadius: BorderRadius.circular(this.isRounded != null ? 30 : 12),
              ),
              child: Container(          
                // padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.merge(
                        TextStyle(color: Colors.white),
                      ),
                    ),              
                    SizedBox(width: 10),
                    if(hasArrow)
                      Icon(Icons.arrow_right_alt, size: 35,)
                  ]
                )                    
              ),
            )
          )
      );
  }
}
