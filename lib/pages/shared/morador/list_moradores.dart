import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import '../../../widgets/cells/cell_apto.dart';
import 'new_apto.dart';

class ListMoradores extends StatefulWidget {
  const ListMoradores({Key? key}) : super(key: key);

  @override
  _ListMoradoresPageState createState() => _ListMoradoresPageState();
}

class _ListMoradoresPageState extends State<ListMoradores> {
  late List<dynamic> list = [];
  var _isLoading = false;
  var loaded = false;

  @override
  void initState(){
      super.initState();
      loadList();
  }

  loadList() async{
    try{
     _isLoading = true;
      setState(() {});
      var locals = await apiGetAll("apartamentos");
      list = locals;
      loaded = true;
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
                NavigationDefault(
                  title: getText('lb_apartamentos'), 
                  // onPressed: (){displayMessage(context, "Disponível em breve!", "Em breve você conseguirá importar os moradores via planilha.");},
                  // buttonRightIcon: getUserType() == 'sindico' ? MdiIcons.upload : null
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 110,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                        if(loaded && list.isEmpty)
                          Center(child: LabelDefault(title: getText('moradores_empty'), maxLines:3, align:TextAlign.center)),
                        for(var item in list) 
                          GestureDetector(
                              onTap: (){
                                // if(getUserType() == 'sindico')
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => NewApto(isEdit: true, obj: item)),).then((_) {
                                    loadList();
                                  });
                              },
                              child: CellApto(item: item, hasArrow: true),
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
            
      floatingActionButton: (getUserType() == 'sindico') || getUserPermission('apartamentos') == 1 ?
        FloatButton(onPressed: () { 
          Navigator.push(context,MaterialPageRoute(builder: (context) => NewApto(isEdit: false)),).then((_) {
            loadList();
          });
          },)
        : null
    );
  }
}
