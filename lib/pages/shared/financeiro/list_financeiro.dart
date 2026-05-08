import 'dart:async';

import 'package:click/controllers/controller_financeiro.dart';
import 'package:click/pages/shared/financeiro/finan_relatorio.dart';
import 'package:click/pages/shared/financeiro/list_inadimplentes.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_despesa.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_morador.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_receita.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button_extended.dart';
import 'package:click/widgets/card/card_financeiro.dart';
import 'package:click/widgets/cells/cell_financeiro.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/navigation/navigation_financeiro.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ListFinanceiro extends StatefulWidget {
  const ListFinanceiro({Key? key}) : super(key: key);

  @override
  _ListFinanceiroPageState createState() => _ListFinanceiroPageState();
}

class _ListFinanceiroPageState extends State<ListFinanceiro> {
  var _isLoading = false;

  List<dynamic> titlesTabs = [];
  ScrollController scrollController = new ScrollController();

  late Map<String, dynamic>  lancamentos = {};

  var tabSelected = "";
  var saldoAtual = '${Singleton.instance.getCurrentMoeda()} 0,00';
  var dia = '--/--/----';
  var mes = '';
  var ano = '';

  @override
  void initState(){
      super.initState();
      loadList();
  }

  loadList() async{
    try{
     _isLoading = true;
      setState(() {});
      var locals = await apiGetAllFinanceiro("financeiro", mes, ano);
      lancamentos = locals['lancamentos'];
      saldoAtual = locals['saldo'];
      saldoAtual = saldoAtual.replaceAll("R\$", Singleton.instance.getCurrentMoeda());    
      dia = locals['dia'];
      titlesTabs = locals['meses'];
      if(tabSelected == '' && titlesTabs.length >= 1){
        tabSelected = titlesTabs[titlesTabs.length-1]['periodo'];
        Timer(Duration(milliseconds: 400), () => scrollController.jumpTo(scrollController.position.maxScrollExtent));
      }
      _isLoading = false;
      setState(() {});
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  changeMonth(month, newMes, newAno){
    tabSelected = month;
    mes = newMes;
    ano = newAno;
    loadList();
    setState(() {});
  }

  getCountStatus(int pago){
    var count = 0;
    try{      
      for(var data in lancamentos.values){
        for(var lancamento in data){
          if(lancamento["pago"] == pago){
            count ++;
          };
        }
      }
    }catch(e){
      print(e);
    }finally{
      return count;
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
                NavigationFinanceiro(title: getText('lb_financeiro'), onPressed: (String selected) { 
                    if(selected == getText('financeiro_inadimplentes')){
                      Navigator.push(context,MaterialPageRoute(builder: (context) => ListInadimplestes()),).then((_) {
                        // loadList();
                      });
                    }else if(selected == getText('financeiro_nav_relatorio')){
                      Navigator.push(context,MaterialPageRoute(builder: (context) => FinanceiroRelatorio()),).then((_) {
                        // loadList();
                      });
                    }
                 },),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), 
                    height: MediaQuery.of(context).size.height - 110,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxMainRounded(),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 25,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            children: [
                              for(var item in titlesTabs)
                                Row(
                                  children: [
                                    tabSelected == item['periodo']
                                      ? LabelDefault(title: item['periodo'], size: 19, weight: FontWeight.bold, decoration: TextDecoration.underline)
                                      : GestureDetector(
                                        onTap: (){changeMonth(item['periodo'], item['mes'], item['ano']);},
                                        child: LabelDefault(title: item['periodo'], size: 17)
                                      ),
                                    SizedBox(width: 20)
                                  ],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        CardFinanceiro(saldoAtual: saldoAtual, dia: dia, mes: tabSelected),  
                        SizedBox(height: 10),
                        if(getUserType() == "sindico")
                          Row(
                            children: [
                              Icon(MdiIcons.checkCircle, color: Colors.green, size: 18,),
                              SizedBox(width: 4),
                              LabelDefault(title: "${getCountStatus(1).toString()} ${getText('pagos')}", size: 15,),
                              SizedBox(width: 7),
                              Icon(MdiIcons.alertCircle, color: Colors.orange, size: 18,),
                              SizedBox(width: 4),
                              LabelDefault(title: "${getCountStatus(0).toString()} ${getText('lb_pendentes')}", size: 15,),                                            
                            ],
                          ),
                        SizedBox(height: 20),
                        Container(
                          height: MediaQuery.of(context).size.height - 315,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[       
                              if(lancamentos.isEmpty) 
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 11, 10, 10),
                                    width: MediaQuery.of(context).size.width,
                                    height: 40,
                                    color: Colors.grey[300],
                                    child: Text('financeiro_sem_lancamentos'),
                                  ),
                              for(var data in lancamentos.keys) 
                                Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: LabelDefault(title: data, size: 18, color: Colors.black)
                                    ),
                                    SizedBox(height: 5),
                                    for(var item in lancamentos[data]) 
                                      GestureDetector(
                                        onTap: (){
                                          if(getUserType() != 'sindico'){return;}
                                          item['tipo'] == 'C' 
                                            ? item['categoria'] == 'Arrecadação'
                                              ? Navigator.push(context,MaterialPageRoute(builder: (context) => NewFinanceiroMorador(id: item['id'], apto: null,)),).then((_) {
                                                  loadList();
                                                })
                                              :  Navigator.push(context,MaterialPageRoute(builder: (context) => NewFinanceiroReceita(id: item['id'])),).then((_) {
                                                  loadList();
                                                })
                                            : Navigator.push(context,MaterialPageRoute(builder: (context) => NewFinanceiroDespesa(id: item['id'])),).then((_) {
                                                loadList();
                                              });                                    
                                        },
                                        child: CellFinanceiro(item: item)
                                      ),
                                    SizedBox(height: 10)
                                  ],
                                ),
                              ]
                            ),
                          ),
                        ),
                      ],
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
        FloatButtonExtended(onPressed: () { 
          // Navigator.push(context,MaterialPageRoute(builder: (context) => NewFinanceiro(isEdit: false)),).then((_) {
            loadList();
          // });
        },)
        : null
    );
  }
}
