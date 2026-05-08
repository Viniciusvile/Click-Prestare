import 'package:click/widgets/alerts/bottom_sheet_phone.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellPrestador extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellPrestador({
    Key? key,
    required this.item, 
    this.hasArrow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
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
                     color: Theme.of(context).primaryColor,
                   ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(flex:14, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelDefault(title: item['nome'], color:Colors.black, size: 18, weight: FontWeight.w500, maxLines: 1,),
                    SizedBox(height: 5),
                    LabelDefault(title: item['categorias'].replaceAll(',',' - ').toString().toUpperCase(), size: 15, weight: FontWeight.w500, maxLines: 1,),
                  ],
                ),
              ),
              Spacer(),
              IconButton(
                padding: EdgeInsets.only(bottom: 8),
                constraints: BoxConstraints(),
                onPressed: () {
                  bottomSheetPhone(context, item['telefone']);
                }, icon: Icon(Icons.phone, size: 30, color: Theme.of(context).primaryColor)
              ),
            ],
          ),
        )
      ),
    );
  }
}
