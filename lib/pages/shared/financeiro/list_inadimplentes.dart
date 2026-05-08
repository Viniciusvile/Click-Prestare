import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/financeiro/detail_inadimplente.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/cells/cell_apto_inadimplente.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:badges/badges.dart' as badges;


class ListInadimplestes extends StatefulWidget {
  const ListInadimplestes({Key? key}) : super(key: key);

  @override
  _ListInadimplestesPageState createState() => _ListInadimplestesPageState();
}

class _ListInadimplestesPageState extends State<ListInadimplestes> {
  late List<dynamic> blocos = [];
  var _isLoading = false;

  @override
  void initState(){
      super.initState();
      loadList();
  }

  loadList() async{
    try{
     changeLoading(true);
      var list = await apiGetAll("financeiro/inadimplentes");
      blocos = list['blocos'];   
      setState(() {});
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      changeLoading(false);
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
                NavigationDefault(title: getText('financeiro_inadimplentes')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                    height: MediaQuery.of(context).size.height - 110,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if(blocos.length == 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LabelDefault(title: getText('financeiro_nenhum_inadimplente')),
                              ],
                            ),
                          for(var bloco in blocos)
                            Padding(
                              padding: const EdgeInsets.only(bottom:8.0),
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  collapsedBackgroundColor: Colors.red[50],
                                  backgroundColor: Colors.red[100],                     
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      LabelDefault(title: '${getText('lb_bloco')} ${bloco['bloco']}', color: Colors.black, size: 15, weight: FontWeight.w500,),
                                      badges.Badge(
                                        badgeContent: LabelDefault(title: bloco['aptos'].length.toString(), color: Colors.white, size: 14), 
                                        badgeStyle: const badges.BadgeStyle(
                                          badgeColor: Colors.red,
                                        ),
                                      )
                                    ],
                                  ),
                                  children: <Widget>[                                  
                                    for(var apto in bloco['aptos'])
                                      InkWell(
                                        onTap: (){
                                          Navigator.push(context,MaterialPageRoute(builder: (context) => DetailInadimplente(apto: apto['apto'], bloco: apto['bloco'])),);
                                        },
                                        child: CellAptoInadimplente(item: apto)
                                      ),
                                  ],
                                ),
                              ),
                            ),
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
