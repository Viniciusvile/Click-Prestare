import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class checkbox_default extends StatelessWidget {
  checkbox_default({
    Key? key, 
    required this.title,
    this.isChecked, 
    this.onPressed,
    this.notPress,
  }) : super(key: key);

  final String title;
  final bool? isChecked;
  final bool? notPress;
  final Function(bool)? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          RoundCheckBox(
            isChecked: isChecked,
            size: 30,
            onTap: notPress == null || notPress == false 
              ? (selected) { onPressed!(selected!); } 
              : null,
            checkedWidget: Icon(Icons.check, color: Colors.white),
            borderColor: Theme.of(context).primaryColor,
            checkedColor: Theme.of(context).primaryColor,
            uncheckedColor: Colors.white,
            border: Border.all(color: Theme.of(context).primaryColor),
            disabledColor: isChecked == false ? Colors.white : Theme.of(context).primaryColor,
          ),
          SizedBox(width: 10),
          LabelDefault(title: title, color: Theme.of(context).primaryColor)
        ],
      ),
    );
  }
}
