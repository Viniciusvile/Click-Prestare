import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/agenda/new_agenda.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/dividers/divider_default.dart';

class DetailAgenda extends StatefulWidget {
  const DetailAgenda({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _DetailAgendaPageState createState() => _DetailAgendaPageState();
}

class _DetailAgendaPageState extends State<DetailAgenda> {
  var _isLoading = false;
  late dynamic obj = null;

  @override
  void initState(){
      super.initState();
      load();
  }

  load() async{
    try{
     _isLoading = true;
      setState(() {});
      obj = await apiGetDetails('agenda', widget.id);
      _isLoading = false;
      setState(() {});
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(  
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),           
            ),    
            child: Column(
              children: [
                NavigationDefault(title: getText('lb_manut_programada')),
                Flexible(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20), 
                      height: MediaQuery.of(context).size.height - 110,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxMainRounded(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [   
                            DividerDefault(title: getText('lb_titulo')),   
                            LabelDefault(title: obj != null ? obj['titulo'] : "", color: Colors.grey.shade800, weight: FontWeight.w500,),
                            SizedBox(height: 10),
                            DividerDefault(title: getText('data_e_hora').toUpperCase()), 
                            Row(
                                children: [                                  
                                  Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                                  SizedBox(width: 5),                                 
                                  LabelDefault(title: obj != null ? "${getText('lb_inicio')}: "+obj['data_inicio']+' às '+obj['hora_inicio'] : '', color: Colors.black, size: 15,),   
                                ],
                              ), 
                            SizedBox(height: 10),
                            Row(
                              children: [                                  
                                Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                                SizedBox(width: 5),                                 
                                LabelDefault(title: obj != null ? "${getText('lb_termino')}: "+obj['data_termino']+' às '+obj['hora_termino'] : '', color: Colors.black, size: 15,),   
                              ],
                            ),
                            SizedBox(height: 10),
                            DividerDefault(title: getText('lb_descricao')),    
                            LabelDefault(title: obj != null ? obj['descricao'] : '', color: Colors.black, maxLines: 99999)
                          ],
                        )
                      ),
                    ),
                ),
              ],
            ), 
          ),
          if(_isLoading)
            Container(
              height: 1000,
              width: 1000,
              child: const Loader(loadingTxt: '', opacity: 0.7, color: Colors.black, dismissibles: false)
            )
        ],
      ),
      floatingActionButton: (getUserType() == 'sindico') ?
        FloatButton(
          isEdit: true,
          onPressed: () { 
          Navigator.push(context,MaterialPageRoute(builder: (context) => NewAgenda(isEdit: true, myId: widget.id)),).then((_) {
            load();
          });
        },)
        : null
    );
  }
}
