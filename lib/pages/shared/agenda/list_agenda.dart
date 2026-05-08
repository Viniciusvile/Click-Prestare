import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/agenda/detail_agenda.dart';
import 'package:click/pages/shared/agenda/new_agenda.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/cells/cell_agenda.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class ListAgenda extends StatefulWidget {
  const ListAgenda({Key? key}) : super(key: key);

  @override
  _ListAgendaPageState createState() => _ListAgendaPageState();
}

class _ListAgendaPageState extends State<ListAgenda> {
  late List<dynamic> list = [];
  var _isLoading = false;

  @override
  void initState(){
      super.initState();
      loadList();
  }

  loadList() async{
    try{
     _isLoading = true;
      setState(() {});
      var locals = await apiGetAll("agenda");
      list = locals;
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
                NavigationDefault(title: getText('lb_manut_programadas')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                    height: MediaQuery.of(context).size.height - 110,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                        if(list.length == 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LabelDefault(title: getText('alert_list_empty_generic'), maxLines: 2, align: TextAlign.center),
                            ],
                          ),
                        for(var item in list) 
                          GestureDetector(
                              onTap: (){
                                Navigator.push(context,MaterialPageRoute(builder: (context) => DetailAgenda(id: item['id'])),).then((_) {
                                  loadList();
                                });
                              },
                              child: CellAgenda(item: item, hasArrow: true),
                            )
                        ]
                      ),
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
            
      floatingActionButton: (getUserType() == 'sindico' || getUserPermission("manutencoes_programadas") == 1) ?
        FloatButton(onPressed: () { 
          Navigator.push(context,MaterialPageRoute(builder: (context) => NewAgenda(isEdit: false)),).then((_) {
            loadList();
          });
        },)
        : null
    );
  }
}
