import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/assembleias/new_votacao.dart';
import 'package:click/pages/shared/enquetes/detail_enquete.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/cells/cell_enquete.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';

class ListEnquetes extends StatefulWidget {
  const ListEnquetes({Key? key}) : super(key: key);

  @override
  _ListEnquetesPageState createState() => _ListEnquetesPageState();
}

class _ListEnquetesPageState extends State<ListEnquetes> {
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
      var locals = await apiGetAll("assembleias/votacoes/enquetes");
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
                NavigationDefault(title: getText('lb_votacoes')),
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
                                Navigator.push(context,MaterialPageRoute(builder: (context) => DetailEnquete(id: item['id'])),).then((_) {
                                  loadList();
                                });
                              },
                              child: CellEnquete(item: item, hasArrow: true),
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
      
      floatingActionButton: (getUserType() == 'sindico') ?
        FloatButton(onPressed: () { 
          Navigator.push(context,MaterialPageRoute(builder: (context) => NewVotacao(isEnquete: true)),).then((_) {
            loadList();
          });
        },)
        : null
    );
  }
}
