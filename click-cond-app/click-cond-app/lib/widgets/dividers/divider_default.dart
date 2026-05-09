import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class DividerDefault extends StatelessWidget {
  final String title;
  final double? fontSize;
  final TextAlign? align;
  final double? height;

  const DividerDefault({
    Key? key,
    required this.title, this.fontSize, this.align, this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      margin: EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width,
      height: height ?? 35,
      color: Colors.grey[300],
      child: LabelDefault(title: title, size: fontSize ?? 13, color: Colors.black, align: align ?? TextAlign.left,),
    );
  }
}
