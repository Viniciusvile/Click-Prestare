
import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/areas%20sociais/new_reserva.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/buttons/rounded_button.dart';
import 'package:click/widgets/cells/cell_morador_agendamento.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';
import 'new_area_social.dart';

class AreaSocialDetail extends StatefulWidget {
  const AreaSocialDetail({Key? key, this.myId}) : super(key: key);
  final int? myId;

  @override
  _AreaSocialDetailPageState createState() => _AreaSocialDetailPageState();
}

class _AreaSocialDetailPageState extends State<AreaSocialDetail> {
  var _isLoading = false;
  late dynamic obj = null;

  @override
  void initState(){
      super.initState();           
      load();      
  }

  load() async{
    changeLoading(true);
    obj = await apiGetDetails("areas-sociais", widget.myId!);
    changeLoading(false);
    if(obj == null){
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
          if(obj != null)
          Container(  
            decoration: BoxDecoration(
              color: Colors.white,           
            ),    
            child: Column(
              children: [
                NavigationDefault(title: getText('lb_area_social'),  
                  onPressed: () {
                    // Navigator.push(context,MaterialPageRoute(builder: (context) => ModalFinalizarAssembleia()),);
                  },
                ),
                ClipRRect(
                  child: Image.network(
                    obj["imagem"], 
                    width: MediaQuery.of(context).size.width, 
                    height: 170,
                    fit: BoxFit.cover,
                  )
                ),
                Flexible(
                  child: Container(
                    transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 0), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: LabelDefault(title: obj["nome"], size: 22, weight: FontWeight.bold,)),
                          SizedBox(height: 15),
                          if(obj['precisa_agendar'] == 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_outlined, size: 24, color: Theme.of(context).hintColor,),
                                SizedBox(width: 10),                                
                                LabelDefault(title: getText('area_social_precisa_agendamento'), size: 16),
                              ],
                            ),
                          if(obj['precisa_autorizacao'] == 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_outlined, size: 24, color: Theme.of(context).hintColor,),
                                SizedBox(width: 10),                                
                                LabelDefault(title: "${getText('area_social_precisa_autorizacao')}   ", size: 16),
                              ],
                            ),
                          if(obj['precisa_pagamento'] == 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_outlined, size: 24, color: Theme.of(context).hintColor,),
                                SizedBox(width: 10),                                
                                LabelDefault(title: "${getText('area_social_precisa_pagamento')}     ", size: 16),
                              ],
                            ), 
                            SizedBox(height: 20), 
                            Row(
                              children: [
                                Icon(Icons.group, color: Colors.grey,),
                                SizedBox(width: 10),
                                LabelDefault(title: obj['capacidade'].toString() != "-1" ? obj['capacidade'].toString() + " ${getText('pessoas')}" : getText('capacidade_indeterminada')),
                              ],
                            ),
                            SizedBox(height: 20), 
                            if(obj['precisa_agendar'] == 1)
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  LabelTitle(title: "${getText('area_social_agendamentos')}:", size: 20, color: Theme.of(context).primaryColor,),
                                  if(getUserType() != 'funcionario')
                                    RoundedButton(
                                      size: 30,
                                      onPressed: () {                                      
                                        Navigator.push(context,MaterialPageRoute(builder: (context) => NewReserva(obj: obj,))).then((_) {
                                          load();
                                        });
                                      },
                                    )
                                ],
                              ),  
                            SizedBox(height: 10),  
                            for(var item in obj['agendamentos']) 
                              GestureDetector(
                                  onTap: (){
                                    if(getUserType() == "sindico" ||  getUserPermission("areas_sociais") == 1 || 
                                      (getUserType() == "morador" && Singleton.instance.bloco.toString() == item['bloco'] 
                                                                  && Singleton.instance.apartamento.toString() == item['apto'] ))
                                        Navigator.push(context,MaterialPageRoute(builder: (context) => NewReserva(obj: obj, objEditReserva: item,))).then((_) {
                                          load();
                                        });
                                  },
                                  child: CellMoradorAgendamento(item: item, canEdit: 
                                    (getUserType() == "sindico" ||  getUserPermission("areas_sociais") == 1 || 
                                      (getUserType() == "morador" && Singleton.instance.bloco.toString() == item['bloco'] 
                                                                  && Singleton.instance.apartamento.toString() == item['apto'] ))
                                  ,),
                                ),
                        ],
                      ),
                    ),
                  )
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
      floatingActionButton: (getUserType() == 'sindico' || getUserPermission("areas_sociais") == 1) ?
        FloatButton(
          onPressed: () { 
            Navigator.push(context,MaterialPageRoute(builder: (context) => NewAreaSocial(isEdit: true, obj: obj, myId: obj['id'],)),).then((_) {
              load();
            });
          },
          isEdit: true,
        )
        : null
    );
  }
}




                   
