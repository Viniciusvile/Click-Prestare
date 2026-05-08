import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/cells/cell_my_agendamento.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class MeusAgendamentosCells extends StatelessWidget {
  const MeusAgendamentosCells({
    Key? key,
    required this.list,
    required this.reload
  }) : super(key: key);

  final List<dynamic> list;
  final Function() reload;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
        SizedBox(height: 15),
        if(list.length == 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LabelDefault(title: getText('area_social_nenhum_agendamento')),
            ],
          ),
        for(var item in list) 
          GestureDetector(
              // onTap: (){
              //   Navigator.push(context,MaterialPageRoute(builder: (context) => NewReserva(isEdit: true, nameArea: '', idArea: 1, obj: item, myId: item['id'], quantity: -1,)),).then((_) {
              //       reload();
              //     })
              //   ;},
              child: CellMyAgendamento(item: item),
            )
        ]
      ),
    );
  }
}

