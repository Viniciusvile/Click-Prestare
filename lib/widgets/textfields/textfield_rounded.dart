import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TextFieldRounded extends StatefulWidget {
  const TextFieldRounded({
    Key? key,
    required this.title,
    required this.isPassword, 
    this.controller,
  }) : super(key: key);

  final String title;
  final bool isPassword;
  final TextEditingController? controller;
 
  @override
  _TextFieldRoundedState createState() => _TextFieldRoundedState();
}

class _TextFieldRoundedState extends State<TextFieldRounded> {  
  var passenable = true;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword==true && passenable==true ?  true : false,
        decoration: InputDecoration(        
          floatingLabelBehavior:FloatingLabelBehavior.always,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          labelText: widget.title,
          labelStyle: TextStyle(fontSize: 22),
          hintText: !widget.isPassword ? 'e-mail@click.com' : '********',
          prefixIcon: Icon(widget.isPassword ? Icons.lock_outline : Icons.email_outlined),
          suffixIcon: widget.isPassword == true
            ? IconButton(
              onPressed: (){
                setState(() { passenable = !passenable; });
              },
              icon: Icon(passenable ? MdiIcons.eyeOff : MdiIcons.eye, color: Colors.grey.shade400),
            )
            : null,
          suffixIconConstraints: BoxConstraints(minWidth: 60),
        ),
      ),
    );
  }
}
