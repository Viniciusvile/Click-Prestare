import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TextFieldSearch extends StatefulWidget {
  const TextFieldSearch({
    Key? key,
    required this.isPassword, 
    required this.placeholder,
    this.icon,
    this.controller, 
    this.keyboard,
    this.onChanged,
    this.focusNode
  }) : super(key: key);

  final placeholder;
  final bool isPassword;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType? keyboard;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  @override
  _TextFieldSearchState createState() => _TextFieldSearchState();
}

class _TextFieldSearchState extends State<TextFieldSearch> {  
  var passenable = true;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: TextField(
        onChanged: widget.onChanged != null 
                  ? (text) { widget.onChanged!(text);}
                  :  null,
        controller: widget.controller,
        obscureText: widget.isPassword==true && passenable==true ?  true : false,
        style: TextStyle(color: Theme.of(context).hintColor),
        keyboardType: widget.keyboard ?? TextInputType.text,
        focusNode: widget.focusNode,
        decoration: InputDecoration(   
          filled: true,
          fillColor: Colors.white,     
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 3),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),  
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 3),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ), 
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 3),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),              
          hintText: widget.placeholder,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(widget.icon, color: Colors.grey.shade400),
          suffixIcon: widget.isPassword == true
            ? IconButton(
              onPressed: (){
                setState(() { passenable = !passenable; });
              },
              icon: Icon(passenable ? MdiIcons.eyeOff : MdiIcons.eye, color: Colors.grey.shade200),
            )
            : null,
          suffixIconConstraints: BoxConstraints(minWidth: 60),
        ),
      ),
    );
  }
}
