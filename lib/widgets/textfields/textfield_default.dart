import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TextFieldDefault extends StatefulWidget {
  const TextFieldDefault({
    Key? key,
    required this.title,
    this.isPassword,
    this.keyboard,
    this.mask,
    this.controller,
    this.placeholder,
    this.enabled, 
    this.textCapitalization, 
    this.fontSize
  }) : super(key: key);

  final String title;
  final bool? isPassword;
  final TextInputType? keyboard;
  final TextInputFormatter? mask;
  final TextEditingController? controller;
  final String? placeholder;
  final bool? enabled;
  final TextCapitalization? textCapitalization;
  final double? fontSize;

  @override
  _TextFieldDefaultState createState() => _TextFieldDefaultState();
}

  class _TextFieldDefaultState extends State<TextFieldDefault> {  
    var passenable = false;
      
    @override
    Widget build(BuildContext context) {
      return MediaQuery(
        data:MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: TextField(
          enabled: widget.enabled ?? true,
          textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,          
          controller: widget.controller,
          obscureText: widget.isPassword != null && widget.isPassword==true && passenable==true ?  true : false,
          keyboardType: widget.keyboard ?? TextInputType.text,
          maxLines: widget.isPassword != null ? 1 : null,
          inputFormatters: widget.mask != null ? [widget.mask!] : [],
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: widget.fontSize ?? 16),
          decoration: InputDecoration(   
            hintText: widget.placeholder,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),     
            floatingLabelBehavior:FloatingLabelBehavior.always,
            labelText: widget.title,
            labelStyle: TextStyle(fontSize: 16, color: Colors.grey.shade600),  
            suffixIcon: widget.isPassword != null && widget.isPassword == true
            ? IconButton(
              onPressed: (){
                setState(() {
                  passenable = !passenable;
                });
              },
              icon: Icon(passenable ? MdiIcons.eyeOff : MdiIcons.eye, color: Colors.grey),
            )
            : null,      
          ),
        ),
      );
    }
  }

