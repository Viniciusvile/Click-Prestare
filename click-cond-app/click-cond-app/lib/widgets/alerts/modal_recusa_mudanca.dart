import 'dart:ui';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/buttons/default_button_normal.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalRecusaMudanca extends StatefulWidget {

  const ModalRecusaMudanca({
    Key? key, 
    }) : super(key: key);

  @override
  _ModalRecusaMudancaState createState() => _ModalRecusaMudancaState();
}

class _ModalRecusaMudancaState extends State<ModalRecusaMudanca> {
  final txtRecusa = TextEditingController();

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
              Text(getText('mudanca_motivo_recusa'),  textAlign: TextAlign.center, style: TextStyle(fontSize: 22,fontWeight: FontWeight.w900, color: Theme.of(context).hintColor),),
              SizedBox(height: 25,),
              TextFieldDefault(title: getText('lb_descricao'), controller: txtRecusa),
              SizedBox(height: 35,),
              DefaultButtonNormal(
                  title: getText('btn_save'), hasArrow: false, isRed: true,
                  onPressed: () => Navigator.pop(context, txtRecusa.text)
              ),
            ],
          ),
        ),
      ],
    );
  }
}
