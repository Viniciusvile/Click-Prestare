import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/manutencao/new_manutencao.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/cells/cell_manutencao.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class ListManutencoes extends StatefulWidget {
  const ListManutencoes({Key? key}) : super(key: key);

  @override
  _ListManutencoesPageState createState() => _ListManutencoesPageState();
}

class _ListManutencoesPageState extends State<ListManutencoes> {
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
      var locals = await apiGetAll("manutencoes");
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
                NavigationDefault(title: getText('manut_nav')),
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
                              LabelDefault(title: getText('alert_list_empty_generic')),
                            ],
                          ),
                        for(var item in list) 
                          GestureDetector(
                              onTap: (){
                                Navigator.push(context,MaterialPageRoute(builder: (context) => NewManutencao(isEdit: true, myId: item['id'])),).then((_) {
                                  loadList();
                                });
                                },
                              child: Cellmanutencao(item: item, hasArrow: true),
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
            const Loader(loadingTxt: '', opacity: 0.7, color: Colors.black, dismissibles: false)
        ],
      ),
      floatingActionButton: FloatButton(onPressed: () { 
        Navigator.push(context,MaterialPageRoute(builder: (context) => NewManutencao(isEdit: false)),).then((_) {
            loadList();
          });
      },)
    );
  }
}
