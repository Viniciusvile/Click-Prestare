import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellDoc extends StatelessWidget {
  final bool? hasArrow;
  final item;
  final Color? colorTag;
  final Function(int) onPressed;

  const CellDoc({
    Key? key,
    required this.item, 
    this.hasArrow, 
    this.colorTag,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 10, 15, 10),
          child: Row(
            children: [
              Container(
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(4.0),
                   child: Container(
                     height: 40,
                     width: 5,
                     color: colorTag ?? Theme.of(context).primaryColor,
                   ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(flex:14,child: LabelDefault(title: item['nome'], size: 16, weight: FontWeight.w500, maxLines: 1, color: hasArrow != null && hasArrow == true ? Colors.black87 : null,)),
              Spacer(),
              Icon(hasArrow != null && hasArrow == true ? Icons.arrow_right_alt : Icons.file_present_outlined, size: 30, color: Theme.of(context).hintColor),
              if(hasArrow == null)
                SizedBox(width: 7),
              if(hasArrow == null)
                IconButton(
                  padding: EdgeInsets.only(bottom: 8),
                  constraints: BoxConstraints(),
                  onPressed: () {
                    onPressed(item['id']);
                  }, icon: Icon(Icons.delete_outline, size: 30, color: Theme.of(context).hintColor)
                )
            ],
          ),
        )
      ),
    );
  }
}
