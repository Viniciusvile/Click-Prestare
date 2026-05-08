import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/ocorrencias/detail_ocorrencia.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/cells/cell_ocorrencia.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class ListOcorrenciasTodos extends StatefulWidget {
  const ListOcorrenciasTodos({Key? key}) : super(key: key);

  @override
  _ListOcorrenciasTodosPageState createState() => _ListOcorrenciasTodosPageState();
}

class _ListOcorrenciasTodosPageState extends State<ListOcorrenciasTodos> {
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
      var locals = await apiGetAll("ocorrencias/todos");
      list = locals;
      _isLoading = false;
      setState(() {});
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    loadList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(                
            child: Column(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0), 
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
                                Navigator.push(context,MaterialPageRoute(builder: (context) => DetailOcorrencia(id: item['id'])),).then((_) {
                                  loadList();
                                });
                              },
                              child: CellOcorrencia(item: item, hasArrow: true),
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
            Loader(loadingTxt: '', opacity: 0, color: Colors.black, dismissibles: false)
        ],
      ),
    );
  }
}
