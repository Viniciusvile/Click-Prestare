import 'package:click/controllers/controller_financeiro.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/dividers/divider_default.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FinanceiroRelatorio extends StatefulWidget {
  const FinanceiroRelatorio({Key? key}) : super(key: key);

  @override
  _FinanceiroRelatorioPageState createState() => _FinanceiroRelatorioPageState();
}

class _FinanceiroRelatorioPageState extends State<FinanceiroRelatorio> {
  late List<dynamic> categorias = [];
  late dynamic resultObj = [];
  ScrollController scrollController = new ScrollController();
  var _isLoading = false;

  List<dynamic> titlesTabs = [];
  List<TextEditingController> txtValor = [];
  List<TextEditingController> txtData = [];

  var tabSelected = "";
  var mes = '';
  var ano = '';

  final List<ChartData> chartData = [];

  @override
  void initState(){
    super.initState();
    loadList();
  }

  loadList() async{
    try{
     _isLoading = true;
      setState(() {});
      chartData.clear();
      var locals = await apiGetAllFinanceiro("financeiro/grafico", mes, ano);
      resultObj = locals;
      categorias = locals['categorias']; 
      titlesTabs = locals['meses'];
      if(tabSelected == '' && titlesTabs.length >= 1){
        tabSelected = titlesTabs[titlesTabs.length-1]['periodo'];
        changeMonth(titlesTabs[titlesTabs.length-1]['periodo'], titlesTabs[titlesTabs.length-1]['mes'], titlesTabs[titlesTabs.length-1]['ano']);
      }      
      for(var categ in categorias){
        var valor = categ['saldo'] ?? 0.0;
        if(valor < 0){valor*-1;}
        chartData.add(ChartData(categ['categoria'], categ['percentual'].toDouble()));
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      _isLoading = false;
      setState(() {});
    }
  }

  changeMonth(month, newMes, newAno){
    tabSelected = month;
    mes = newMes;
    ano = newAno.substring(newAno.length - 2);;
    loadList();
    setState(() {});
  }

  getIcon(item){
    if(item["tipo"] == "D"){
      return Icon(MdiIcons.cashMinus, color: Colors.red.shade300, size: 30);
    }else{
      if(item["tipo"] == "C" && item['categoria'] == "Arrecadação"){
        return Icon(MdiIcons.homeOutline, color: Colors.green.shade300, size: 30);
      }
      return Icon(MdiIcons.cashPlus, color: Colors.green.shade300, size: 30);
    }
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
                NavigationDefault(title: getText('financeiro_nav_relatorio')),
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
                            // SizedBox(height: 20),
                            SfCircularChart(
                              margin: EdgeInsets.zero,
                              legend: Legend(isVisible: true),
                              series: [
                                PieSeries<ChartData, String>(
                                    dataSource:chartData,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                    dataLabelSettings:DataLabelSettings(isVisible : true)
                                )
                              ]
                            ),
                            // SizedBox(height: 20),
                            resultObj != null && resultObj.length > 0
                             ? Column(
                                children: [
                                  DividerDefault(title: getText('financeiro_nav_resultado')),   
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      LabelDefault(title: getText('financeiro_total_receitas'), size: 15),
                                      Row(
                                        children: [
                                          LabelDefault(title: resultObj['totalReceitaReal'].replaceAll("R\$", Singleton.instance.getCurrentMoeda()), color: Colors.green.shade300, weight: FontWeight.w500,),
                                          SizedBox(width: 15),
                                          LabelDefault(title: resultObj['percentualReceita'], size: 11,),
                                        ],
                                      ), 
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      LabelDefault(title: getText('financeiro_total_despesas'), size: 15),
                                      Row(
                                        children: [
                                          LabelDefault(title: resultObj['totalDespesaReal'].replaceAll("R\$", Singleton.instance.getCurrentMoeda()), color: Colors.red.shade300, weight: FontWeight.w500,),
                                          SizedBox(width: 15),
                                          LabelDefault(title: resultObj['percentualDespesa'], size: 11,),
                                        ],
                                      ), 
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      LabelDefault(title: getText('financeiro_resultado_periodo'), color: Colors.black, size: 18, weight: FontWeight.w500,),
                                      LabelDefault(title: resultObj['saldoReal'].replaceAll("R\$", Singleton.instance.getCurrentMoeda()), size: 20, color: Colors.black, weight: FontWeight.w500,),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  DividerDefault(title: getText('lb_categorias').toUpperCase()),   
                                  for(var categ in categorias)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [                                      
                                        Row(
                                          children: [
                                            getIcon(categ),
                                            SizedBox(width: 10),
                                            LabelDefault(title: categ['categoria'], size: 15),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            LabelDefault(title: categ['saldoReal'].replaceAll("R\$", Singleton.instance.getCurrentMoeda()),  weight: FontWeight.w500,),
                                            SizedBox(width: 15),
                                            LabelDefault(title: categ['percentualString'], size: 11,),
                                          ],
                                        ),
                                      ],
                                    )
                                ],
                              )
                              : Text('')
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

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double? y;
}
