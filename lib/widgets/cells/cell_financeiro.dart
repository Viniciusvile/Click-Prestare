import 'package:click/pages/singleton.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CellFinanceiro extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellFinanceiro({
    Key? key,
    required this.item, 
    this.hasArrow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    getIcon(){
      if(item["tipo"] == "D"){
        return Icon(MdiIcons.cashMinus, color: Colors.red.shade300, size: 30);
      }else{
        if(item["tipo"] == "C" && item['categoria'] == "Arrecadação"){
          return Icon(MdiIcons.homeOutline, color: Colors.green.shade300, size: 30);
        }
        return Icon(MdiIcons.cashPlus, color: Colors.green.shade300, size: 30);
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: 
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10),
                Column(
                  children: [
                    getIcon(),                    
                    if(item["pago"] == 0)
                      Icon(MdiIcons.alertCircle, color: Colors.orange, size: 20,),
                  ],
                ),
                SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Container(
                    height: 40,
                    width: 4,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(fit: FlexFit.loose, child: LabelDefault(title: item['nome'], color: Colors.black87, size: 16, maxLines: 3)),
                          Flexible(child: LabelDefault(title: item['valorString'].toString().toUpperCase().replaceAll("R\$", Singleton.instance.getCurrentMoeda()), color: Colors.black, size: 18, weight: FontWeight.w500)),
                        ],
                      ), 
                      SizedBox(height: 2),      
                      if(item['nome_operador'] != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: LabelDefault(title: "Registrado por: ${item['nome_operador']}", size: 14)
                        ),
                    ],
                  ),
                )
              ],
            ),
        )
      ),
    );
  }
}
