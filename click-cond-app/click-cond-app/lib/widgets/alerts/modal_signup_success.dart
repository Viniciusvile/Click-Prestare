import 'dart:ui';
import 'package:click/pages/sindico/list_condominiums.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/buttons/default_button_normal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {

  const CustomDialogBox({
    Key? key, 
    }) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(top: 25),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black,offset: Offset(0,5),
              blurRadius: 15
              ),
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(getText('signup_cond_sucesso'),  textAlign: TextAlign.center, style: TextStyle(fontSize: 22,fontWeight: FontWeight.w900, color: Theme.of(context).hintColor),),
              SizedBox(height: 25,),
              Align(                
                alignment: Alignment.bottomCenter,
                child: Image(
                  height: 200,
                  fit: BoxFit.fitHeight,
                  width: MediaQuery.of(context).size.width,
                  image: AssetImage('assets/images/check_signup.png'),
                ),
              ), 
              SizedBox(height: 35,),
              DefaultButtonNormal(
                  title: "OK", hasArrow: false,
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => ListCondomiums()),);
                  }
              ),
            ],
          ),
        ),
      ],
    );
  }
}
