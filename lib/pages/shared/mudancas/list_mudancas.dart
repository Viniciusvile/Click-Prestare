import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/mudancas/new_mudanca.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/cells/cell_mudanca.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class ListMudancas extends StatefulWidget {
  const ListMudancas({Key? key}) : super(key: key);

  @override
  _ListMudancasPageState createState() => _ListMudancasPageState();
}

class _ListMudancasPageState extends State<ListMudancas> {
  late List<dynamic> list = [];
  var _isLoading = false;

  @override
  void initState(){
      super.initState();
      loadList();
  }

  loadList() async{
    try{
     changeLoading(true);
      var locals = await apiGetAll("mudancas");
      list = locals;
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      changeLoading(false);
    }
  }

  updateStatus(idItem, status, motivo) async{
    try{
      changeLoading(true);
      var res = await apiUpdateStatus("mudancas", idItem, status, motivo);
      
      if(res.toString().isEmpty){
        loadList();
      }else{
        displayMessage(context, getText('alert_error'), res.toString());
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      changeLoading(false);
    }
  }

  changeLoading(bool value){
    _isLoading = value;
    setState(() {});
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
                NavigationDefault(title: getText('mudanca_nav')),
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
                              LabelDefault(title: getText('alert_list_empty_generic'), maxLines: 2),
                            ],
                          ),
                        for(var item in list) 
                          GestureDetector(
                              onTap: (){
                                if((getUserType() != 'funcionario' || getUserPermission('agendar_mudanca') == 1) && item['status'] != 'pendente'){
                                  displayMessage(context, getText('alert'), getText('mudanca_pendente_aprovacao'));
                                  return;
                                }
                                (getUserType() != 'funcionario' || getUserPermission('agendar_mudanca') == 1) && item['status'] == 'pendente' ?
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => NewMudanca(isEdit: true, myId: item['id'])),).then((_) {
                                    loadList();
                                  })
                                : null;
                              },
                              child: CellMudanca(item: item, hasArrow: true,
                                changeStatus: (id, status, motivo){
                                  updateStatus(id, status, motivo);
                                },
                              ),
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
            
      floatingActionButton: (getUserType() != 'funcionario') || getUserPermission('agendar_mudanca') == 1 ?
        FloatButton(onPressed: () { 
          Navigator.push(context,MaterialPageRoute(builder: (context) => NewMudanca(isEdit: false)),).then((_) {
            loadList();
          });
        },)
        : null
    );
  }
}
