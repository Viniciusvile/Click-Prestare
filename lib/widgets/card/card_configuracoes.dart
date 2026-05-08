import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CardConfiguracoes extends StatelessWidget {
  final String title;

  const CardConfiguracoes({
    Key? key, required this.title, 
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        LabelDefault(title: title, color:Colors.grey.shade500, size: 15,),
        SizedBox(height: 10),
        Divider(),
      ],
    );
  }
}
