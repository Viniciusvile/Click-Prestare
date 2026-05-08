import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellMoradorAgendamento extends StatelessWidget {
  final item;
  final canEdit;

  const CellMoradorAgendamento({
    Key? key,
    required this.item, required this.canEdit, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 190,
      child: Card(
        elevation: 0,
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [                   
                Row(
                  children: [
                    if(canEdit)            
                      Icon(Icons.edit, color: Colors.grey,),
                      SizedBox(width: 4),
                    LabelDefault(title: "${getText('lb_bloco')}: "+item['bloco'] , size: 14),
                  ],
                ),
                LabelDefault(title: "${getText('lb_apto')}: "+item['apto'] , size: 14),
                LabelDefault(title: '${item['data']}\n${item['horaDe']} até ${item['horaAte']}', size: 14, maxLines: 3,),
              ],
            )           
        )         
      ),
    );
  }
}
