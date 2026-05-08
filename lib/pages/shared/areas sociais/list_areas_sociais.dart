import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/areas%20sociais/agendamentos_cells.dart';
import 'package:click/pages/shared/areas%20sociais/meus_agendamentos_cells.dart';
import 'package:click/pages/shared/areas%20sociais/new_area_social.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'areas_sociais_cells.dart';


class ListAreasSociais extends StatefulWidget {
  const ListAreasSociais({Key? key}) : super(key: key);

  @override
  _ListAreasSociaisPageState createState() => _ListAreasSociaisPageState();
}

class _ListAreasSociaisPageState extends State<ListAreasSociais> {
  late List<dynamic> list = [];
  late List<dynamic> listAgendamentos = [];
  late List<dynamic> listMeusAgendamentos = [];
  var _currentTab = 0;
  var _isLoading = false;

  void initState(){
      super.initState();
      loadList();
      loadMeusAgendamentos();
      if(getUserType() == 'sindico')
        loadAgendamentos();

  }

  loadList() async{
    try{
     changeLoading(true);
      var locals = await apiGetAll("areas-sociais");
      list = locals;
      changeLoading(false);
    }catch(e){
      changeLoading(false);
      // displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  loadAgendamentos() async{
    try{
     changeLoading(true);
      var locals = await apiGetAll("areas-sociais/agendamentos");
      listAgendamentos = locals;
      changeLoading(false);
    }catch(e){
      changeLoading(false);
      // displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  loadMeusAgendamentos() async{
    try{
     changeLoading(true);
      var locals = await apiGetAll("areas-sociais/meus-agendamentos");
      listMeusAgendamentos = locals;
      changeLoading(false);
    }catch(e){
      changeLoading(false);
      // displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  reload(){
     loadList();
      loadMeusAgendamentos();
      if(getUserType() == 'sindico')
        loadAgendamentos();
    
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
                NavigationDefault(title: getText('lb_areas_sociais')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                    height: MediaQuery.of(context).size.height - 110,
                    decoration: BoxMainRounded(),
                    child: 
                      ContainedTabBarView(
                        tabs: [
                          Text(getText('lb_areas_sociais'), textScaleFactor: 1.0, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          if(getUserType() == 'sindico')
                            Text(getText('area_social_agendamentos'), textScaleFactor: 1.0, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          if(getUserType() == 'morador')
                            Text(getText('area_social_meus_agendamentos'),textScaleFactor: 1.0, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                        ],
                        views: [
                          AreasSociaisCells(list: list, reload: () { reload(); }),
                          if(getUserType() == 'sindico')
                            AgendamentosCells(list: listAgendamentos, reload: () { reload(); }),
                          if(getUserType() == 'morador')
                            MeusAgendamentosCells(list: listMeusAgendamentos, reload: () { reload(); })
                        ],
                        tabBarProperties: TabBarProperties(
                          indicatorColor: Theme.of(context).primaryColor,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Theme.of(context).hintColor,
                        ),
                        onChange: (index) {
                          setState(() {
                            _currentTab = index;
                          });
                        },
                    ),
                  ),
                )
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
     
      floatingActionButton: _currentTab == 0 && (getUserType() == 'sindico' || getUserPermission("areas_sociais") == 1) ?
        FloatButton(onPressed: () { Navigator.push(context,MaterialPageRoute(builder: (context) => NewAreaSocial(isEdit: false)),).then((_) {
            loadList();
          });
        },)
        : null
    );
  }
}
