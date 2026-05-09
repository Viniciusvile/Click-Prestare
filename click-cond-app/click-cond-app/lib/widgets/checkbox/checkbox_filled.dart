import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class checkbox_filled extends StatelessWidget {
  
  checkbox_filled({
    Key? key, 
    required this.title,
    required this.isChecked, 
  }) : super(key: key);

  final String title;
  late bool isChecked;

  @override
  Widget build(BuildContext context) {
    Color _backgroundColor = Colors.white;
    Color _titleColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(24),
        color: _backgroundColor
      ),
      child: Row(
        children: [
          RoundCheckBox(
            size: 25,
            onTap: null ,
            isChecked: isChecked,
            disabledColor: isChecked 
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,            
            borderColor: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 10),
          LabelDefault(title: title, color: _titleColor, size: 14)
        ],
      ),
    );
  }

  void setState(Null Function() param0) {}
}
