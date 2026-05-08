import 'package:click/controllers/controller_financeiro.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_morador.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/cells/cell_apto_financeiro.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ListFinanceiroMoradores extends StatefulWidget {
  const ListFinanceiroMoradores({Key? key}) : super(key: key);

  @override
  _ListFinanceiroMoradoresPageState createState() => _ListFinanceiroMoradoresPageState();
}

class _ListFinanceiroMoradoresPageState extends State<ListFinanceiroMoradores> {
  late List<dynamic> blocos = [];
  ScrollController scrollController = new ScrollController();
  var _isLoading = false;

  List<dynamic> titlesTabs = [];
  List<TextEditingController> txtValor = [];
  List<TextEditingController> txtData = [];

  var tabSelected = "";
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
      var locals = await apiGetAllFinanceiro("financeiro/moradores", mes, "20"+ano);
      blocos = locals['blocos']; 
      titlesTabs = locals['meses'];
      if(tabSelected == '' && titlesTabs.length >= 1){
        tabSelected = titlesTabs[titlesTabs.length-1]['periodo'];
        changeMonth(titlesTabs[titlesTabs.length-1]['periodo'], titlesTabs[titlesTabs.length-1]['mes'], titlesTabs[titlesTabs.length-1]['ano']);
      }     
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      _isLoading = false;
      setState(() {});
    }
  }

  getCountStatus(var bloco, int pago){
    var count = 0;
    for(var apto in bloco["aptos"]){
      count += apto["pago"] == pago ? 1 : 0;
    }
    return count;
  }

  changeMonth(month, newMes, newAno){
    tabSelected = month;
    mes = newMes;
    ano = newAno.substring(newAno.length - 2);;
    loadList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(  
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),           
            ),
            child: Column(
              children: [
                NavigationDefault(title: getText('financeiro_nav_arrecadacoes')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), 
                    height: MediaQuery.of(context).size.height - 110,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxMainRounded(),
                    child: 
                    Container(
                      height: MediaQuery.of(context).size.height - 210,
                      child: SingleChildScrollView(
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
                            SizedBox(height: 20),
                            if(blocos.isEmpty && !_isLoading)
                              LabelDefault(title: getText('alert_nenhum_apto'), maxLines: 99,),
                            for(var bloco in blocos)
                              Padding(
                                padding: const EdgeInsets.only(bottom:8.0),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(   
                                    collapsedBackgroundColor: Colors.grey[100],
                                    backgroundColor: Colors.grey[200],                     
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        LabelDefault(title: '${getText('lb_bloco')} ${bloco['bloco']}', color: Colors.black, size: 15,),
                                        Row(
                                          children: [
                                            Icon(MdiIcons.checkCircle, color: Colors.green, size: 18,),
                                            SizedBox(width: 4),
                                            LabelDefault(title: getCountStatus(bloco,1).toString(), size: 15,),
                                            SizedBox(width: 7),
                                            Icon(MdiIcons.alertCircle, color: Colors.orange, size: 18,),
                                            SizedBox(width: 4),
                                            LabelDefault(title: getCountStatus(bloco,0).toString(), size: 15,),                                            
                                          ],
                                        ),
                                        LabelDefault(title: bloco['total'].replaceAll("R\$", Singleton.instance.getCurrentMoeda()), color: Colors.grey.shade700, size: 12,),
                                      ],
                                    ),
                                    children: <Widget>[                                  
                                      for(var apto in bloco['aptos'])
                                        InkWell(
                                          onTap: (){
                                            Navigator.push(context,MaterialPageRoute(builder: (context) => NewFinanceiroMorador(apto: apto)),).then((_) {
                                              loadList();
                                            });  
                                          },
                                          child: CellAptoFinanceiro(item: apto)
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        )
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
    );
  }
}
