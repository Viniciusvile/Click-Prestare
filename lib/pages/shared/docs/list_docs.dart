import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/docs/list_atas.dart';
import 'package:click/pages/shared/docs/new_document.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/cells/cell_doc.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';

class ListDocs extends StatefulWidget {
  const ListDocs({Key? key}) : super(key: key);

  @override
  _ListDocsPageState createState() => _ListDocsPageState();
}

class _ListDocsPageState extends State<ListDocs> {
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
      var locals = await apiGetAllDocs("documentos",0);
      list = locals;
      changeLoading(false);
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  delete(index) async {
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('documentos', index);
      changeLoading(false);
      if(res){
        loadList();
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
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
                NavigationDefault(title: getText('docs_nav')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                    height: MediaQuery.of(context).size.height - 110,
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
                              launchInBrowser(
                                item['link_doc'],
                                context,
                              );
                            },
                            child: CellDoc(item: item, 
                              onPressed: (index) { 
                                delete(index);
                               }, 
                            ),
                          ),
                        GestureDetector(
                            onTap: (){
                              Navigator.push(context,MaterialPageRoute(builder: (context) => ListAtas()),);
                            },
                            child: CellDoc(item: {"nome":"ATAS"}, hasArrow: true,
                              onPressed: (idx) {}
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
      floatingActionButton: (getUserType() == 'sindico') ? 
        FloatButton(onPressed: () { 
          Navigator.push(context,MaterialPageRoute(builder: (context) => NewDocument(is_ata: false)),).then((_) {
              loadList();
            });
          },)
        : null
    );
  }
}
