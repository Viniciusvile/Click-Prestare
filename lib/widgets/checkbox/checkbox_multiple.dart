import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class checkbox_multiple extends StatelessWidget {
  checkbox_multiple({
    Key? key, 
    required this.title, 
    required this.isChecked,
  }) : super(key: key);

  final String title;
  late bool isChecked;


  @override

  Widget build(BuildContext context) {


    return Container(
      padding: const EdgeInsets.all(0.0),
      height: 30,
      width: MediaQuery.of(context).size.width - 50,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: CheckboxListTile(
                activeColor: Colors.yellow,
                title: LabelDefault(title: title, size: 16),
                value: isChecked,
                onChanged: (newValue) { isChecked = !isChecked; },
              ),
            )
          ],
        ),
    );
  }
}
