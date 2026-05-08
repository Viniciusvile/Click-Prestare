import 'dart:async';
import 'package:click/controllers/controller_visitantes.dart';
import 'package:click/pages/shared/visitantes/new_visitante.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/cells/cell_visitante.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_search.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class ListVisitantes extends StatefulWidget {
  const ListVisitantes({Key? key}) : super(key: key);

  @override
  _ListVisitantesPageState createState() => _ListVisitantesPageState();
}

class _ListVisitantesPageState extends State<ListVisitantes> {
  final txtSearch = TextEditingController();
  Timer? timerSearch = null;

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
      var locals = await apiGetAllVisitantes(txtSearch.text);
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
                NavigationDefault(title: getText('visitantes_list')),
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
                        TextFieldSearch(isPassword: false, controller: txtSearch, icon:  Icons.search_outlined, placeholder: getText('lb_buscar'),
                          onChanged: (text){
                            timerSearch?.cancel();
                            timerSearch = Timer(const Duration(milliseconds: 1000),(){
                              loadList();
                            });
                          },
                        ),
                        if(list.length == 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LabelDefault(title: getText('alert_list_empty_generic')),
                            ],
                          ),
                        for(var item in list) 
                          GestureDetector(
                              onTap: (){
                                (getUserType() != 'funcionario') || getUserPermission('cadastrar_visitante') == 1 ?
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => NewVisitante(isEdit: true, myId: item['id'])),).then((_) {
                                    loadList();
                                  })
                                : null;
                              },
                              child: CellVisitante(item: item, hasArrow: true),
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
            
      floatingActionButton: 
        (getUserType() != 'funcionario') || getUserPermission('cadastrar_visitante') == 1 ?
          FloatButton(onPressed: () { 
            Navigator.push(context,MaterialPageRoute(builder: (context) => NewVisitante(isEdit: false)),).then((_) {
              loadList();
            });
          },)
        : null
    );
  }
}
