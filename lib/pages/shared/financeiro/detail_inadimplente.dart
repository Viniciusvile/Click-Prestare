import 'package:click/controllers/controller_financeiro.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/dividers/divider_default.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class DetailInadimplente extends StatefulWidget {
  const DetailInadimplente({Key? key, required this.bloco, required this.apto}) : super(key: key);
  final String bloco;
  final String apto;

  @override
  _DetailInadimplentePageState createState() => _DetailInadimplentePageState();
}

class _DetailInadimplentePageState extends State<DetailInadimplente> {
   List<dynamic>  list = [];
  var _isLoading = false;

  @override
  void initState(){
      super.initState();
      load();
  }

  load() async{
    try{
     changeLoading(true);
      var locals = await apiGetDetailsInadimplente('financeiro/inadimplente', widget.bloco, widget.apto);
      list = locals;
      changeLoading(false);
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
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
                NavigationDefault(title: getText('financeiro_inadimplente')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), 
                    height: MediaQuery.of(context).size.height - 110,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                        Center(child: LabelTitle(title: 'Apartamento ${widget.apto}')),
                        SizedBox(height: 20),
                        if(list.length == 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LabelDefault(title: getText('alert_list_empty_generic')),
                            ],
                          ),
                        DividerDefault(title: getText('financeiro_meses_aberto')),
                        SizedBox(height: 10),
                        for(var item in list)                           
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabelTitle(title: item['mes']+'/'+item['ano'], size: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // LabelDefault(title: 'Venceu em '+item['vencimento']),
                                  // LabelDefault(title: item['valor']),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
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
    );
  }
}
