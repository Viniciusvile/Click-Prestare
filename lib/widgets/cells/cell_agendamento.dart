import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellAgendamento extends StatelessWidget {
  final item;
  // final Function(int, bool, String) changeStatus;

  const CellAgendamento({
    Key? key,
    required this.item,
    // required this.changeStatus, 
  }) : super(key: key);

  updateStatus(idItem, status, motivo) async{
    try{
      var res = await apiUpdateStatus("mudancas", idItem, status, motivo);
      if(res.toString().isEmpty){
        print('foi');
      }else{
        print('erro');
      }
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 190,
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: 
            Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.house_outlined, size: 20, color: Theme.of(context).hintColor,),
                          SizedBox(width: 5),
                          LabelDefault(title: '${getText('lb_apto')} '+item['apto']+' ${getText('lb_bloco')}'+item['bloco'], size: 14),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                          SizedBox(width: 5),
                          LabelDefault(title: item['data_criacao'], size: 14),
                        ],
                      )
                      
                    ],
                  ),
                ),   
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Container(
                        height: 100,
                        width: 5,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 100, 
                      width: MediaQuery.of(context).size.width - 170,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [                          
                          LabelDefault(title: "${getText('area_social_data_reserva')} "+item['data'], size: 15, maxLines: 2),
                          SizedBox(height: 5),
                          LabelDefault(title: "${getText('area_social_hora_reserva')} "+item['horaDe']+' - '+item['horaAte'], size: 15, maxLines: 2),                          
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              LabelDefault(title: getText('area_social_reservado'), size: 18),
                              SizedBox(width: 5),
                              LabelDefault(title: item['nomeArea'], size: 18, color: Theme.of(context).primaryColor, weight: FontWeight.bold),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
        )
      ),
    );
  }
}
