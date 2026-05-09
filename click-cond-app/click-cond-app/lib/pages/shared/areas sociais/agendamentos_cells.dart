import 'package:click/pages/shared/comunicados/detail_comunidado.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/cells/cell_agendamento.dart';
import 'package:click/widgets/cells/cell_area_social.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class AgendamentosCells extends StatelessWidget {
  const AgendamentosCells({
    Key? key,
    required this.list,
    required this.reload
  }) : super(key: key);

  final List<dynamic> list;
  final Function() reload;

  updateStatus(idItem, status, motivo) async{
    // try{
    //   changeLoading(true);
    //   var res = await apiUpdateStatus("mudancas", idItem, status, motivo);
    //   changeLoading(false);
    //   if(res.toString().isEmpty){
    //     loadList();
    //   }else{
    //     displayMessage(context, getText('alert_error'), res.toString());
    //   }
    // }catch(e){
    //   displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    // }
  }

  // changeLoading(bool value){
  //   _isLoading = value;
  //   setState(() {});
  // }

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
              LabelDefault(title: getText('alert_list_empty_generic')),
            ],
          ),
        for(var item in list) 
          GestureDetector(
              // onTap: (){
              //   Navigator.push(context,MaterialPageRoute(builder: (context) => DetailComunicado()),);
              // },
              child: CellAgendamento(item: item)
                  // changeStatus: (id, status, motivo){
                  //   updateStatus(id, status, motivo);
                  // },),
            )
        ]
      ),
    );
  }
}

