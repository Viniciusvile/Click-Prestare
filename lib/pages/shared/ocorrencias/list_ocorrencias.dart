import 'package:click/pages/shared/ocorrencias/list_ocorrencias_pendentes.dart';
import 'package:click/pages/shared/ocorrencias/list_ocorrencias_todos.dart';
import 'package:click/pages/shared/ocorrencias/new_ocorrencia.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class ListOcorrencias extends StatefulWidget {
  const ListOcorrencias({Key? key}) : super(key: key);

  @override
  _ListOcorrenciasPageState createState() => _ListOcorrenciasPageState();
}

class _ListOcorrenciasPageState extends State<ListOcorrencias> {
  late List<dynamic> list = [];
  var _isLoading = false;

  @override
  void initState(){
      super.initState();
      // loadList();
  }

  // loadList() async{
  //   try{
  //    _isLoading = true;
  //     setState(() {});
  //     var locals = await apiGetAll("ocorrencias");
  //     list = locals;
  //     _isLoading = false;
  //     setState(() {});
  //   }catch(e){
  //     displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
  //   }
  // }

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
                NavigationDefault(title: getText('ocorrencia_abertura_nav')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                    height: MediaQuery.of(context).size.height - 110,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxMainRounded(),
                    child: ContainedTabBarView(
                      tabs: [
                        Text(getText('lb_todos'), textScaleFactor: 1.0, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(getText('lb_pendentes'), textScaleFactor: 1.0, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),                              
                      ],
                      views: [     
                        // Text('a')                         ,
                        // Text('a')                         ,
                        ListOcorrenciasTodos(),
                        ListOcorrenciasPendentes()
                      ],
                      tabBarProperties: TabBarProperties(
                        indicatorColor: Theme.of(context).primaryColor,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Theme.of(context).hintColor,
                      ),
                      onChange: (index) {
                        setState(() {
                         //todo
                        });
                    }),
                  ),
                ),
              ],
            ), 
          ),
          if(_isLoading)
            const Loader(loadingTxt: '', opacity: 0.7, color: Colors.black, dismissibles: false)
        ],
      ),
      floatingActionButton: FloatButton(onPressed: () { 
        Navigator.push(context,MaterialPageRoute(builder: (context) => NewOcorrencia(isEdit: false)),).then((_) {
          setState(() {});
        });
      },)
    );
  }
}
