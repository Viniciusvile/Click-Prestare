import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/checkbox/checkbox_default.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellVotacao extends StatelessWidget {
  final bool? hasArrow;
  final item;
  final List<dynamic> meusVotos;
  final bool isRegister;
  final Function() onPressedDelete;
  final Function(int) onPressedChoice;
  final String? title;

  const CellVotacao({
    Key? key,
    required this.item, 
    required this.meusVotos, 
    this.hasArrow, 
    this.title,
    required this.isRegister,
    required this.onPressedDelete,
    required this.onPressedChoice, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 190,
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 20, 10, 20),
          child: Row(
            children: [
              Container(
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(4.0),
                   child: Container(
                     height: 140,
                     width: 5,
                     color: Theme.of(context).primaryColor,
                   ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 20, color: Theme.of(context).hintColor,),
                        SizedBox(width: 5),
                        LabelDefault(title: '${getText('label_of')} ${item['data_inicio']} ${getText('label_until')} ${item['data_termino']}', size: 14),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(child: Align(alignment: Alignment.center, child: LabelDefault(title: title ?? item['titulo'], color: Colors.black, weight: FontWeight.bold, size: 17))),
                      ],
                    ),
                    SizedBox(height: 10),
                    for(var opcao in item['opcoes']) 
                      InkWell(           
                        onTap: (){
                          if(item['status']!=1){
                             displayMessage(context, getText('alert_ops'), getText('votacao_fora_periodo'));
                          }                         
                        },
                        child: Row(
                          children: <Widget>[
                            if(!isRegister)
                              checkbox_default(notPress: item['status']!=1, title: "", isChecked: meusVotos.contains(opcao.split(';')[0]), onPressed: (checked){onPressedChoice(int.parse(opcao.split(';')[0]));},),
                            Expanded(child: LabelDefault(title: opcao.split(';')[1], size: 15, maxLines: 5,)),
                            if(!isRegister)
                              LabelDefault(title: "${opcao.split(';')[2]} Votos", size: 15)
                          ],
                        ),
                      ),
                    SizedBox(height: 10),
                    if(getUserType() == "sindico")
                      InkWell(
                        onTap: (){onPressedDelete();},
                        child: Align(
                          alignment: Alignment.center,
                          child: LabelDefault(title: getText("btn_delete"), size: 18, color: Colors.red)
                        ),
                      ),
                 ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
