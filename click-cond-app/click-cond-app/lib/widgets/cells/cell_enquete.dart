import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellEnquete extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellEnquete({
    Key? key,
    required this.item, 
    this.hasArrow,
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
                     height: 100,
                     width: 5,
                     color: Theme.of(context).primaryColor,
                   ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(Icons.calendar_month_outlined, size: 20, color: Theme.of(context).hintColor,),
                        SizedBox(width: 5),
                        LabelDefault(title: 'De ${item['data_inicio']} até ${item['data_termino']}', size: 14),
                      ],
                    ),   
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(child: Align(alignment: Alignment.centerLeft, child: LabelDefault(title: item['titulo'], color: Colors.black, size: 16))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(child: LabelDefault(title: item['descricao'], size: 15, maxLines: 5,))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        item["status"] == 0 ?
                          LabelDefault(title: getText('votacao_agendado'), size: 14)
                        : item["status"] == 1 ?
                           LabelDefault(title: getText('votacao_andamento'), color: Theme.of(context).primaryColor, size: 14,)
                        : item["status"] == 2 ?
                           LabelDefault(title: getText('votacao_finalizado'), color: Colors.red, size: 14)
                        : Container()
                      ],
                    )
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
