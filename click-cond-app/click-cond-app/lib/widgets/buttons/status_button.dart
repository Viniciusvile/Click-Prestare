import 'package:flutter/material.dart';

class StatusButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final FractionalOffset? aligment;
  final bool isRecuse;
  final bool disable;

  const StatusButton({
    Key? key,
    required this.title,
    this.onPressed,
    this.aligment, 
    required this.isRecuse, 
    required this.disable, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return 
      Flexible(
        child: Align(
          alignment: this.aligment ?? FractionalOffset.bottomCenter,
          child: 
            ElevatedButton(
              onPressed: disable ? null : onPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(0.0),
                elevation: 5,
                minimumSize: Size(double.infinity, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Ink(
                height: 30,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: !isRecuse ?
                        [Color.fromRGBO(43, 196, 243, disable ? 0.2 : 1), Color.fromRGBO(0, 174, 238, disable  ? 0.2 : 1),
                              Color.fromRGBO(0, 149, 218, disable ? 0.2 : 1)]
                        : [Color.fromRGBO(255, 157, 144, disable ? 0.2 : 1), Color.fromRGBO(206, 1, 1, disable ? 0.2 : 0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight
                  ),
                  borderRadius: BorderRadius.circular(30),
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
                    ]
                  )
                ),
              )
            )
        )
      );
  }
}
