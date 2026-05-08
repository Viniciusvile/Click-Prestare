
import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/assembleias/new_assembleia.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_finalizar_assembleia.dart';
import 'package:click/widgets/buttons/rounded_button.dart';
import 'package:click/widgets/cells/cell_votacao.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/dividers/divider_default.dart';
import 'new_votacao.dart';

class DetailAssembleia extends StatefulWidget {
  const DetailAssembleia({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _DetailAssembleiaPageState createState() => _DetailAssembleiaPageState();
}

class _DetailAssembleiaPageState extends State<DetailAssembleia> {
  var list = [1,2,3];
  var _isLoading = false;
  late dynamic obj = null;
  late dynamic votacoes = [];
  late dynamic meus_votos = [];

  @override
  void initState(){
      super.initState();
      load();
  }

  load() async{
    try{
     _isLoading = true;
      setState(() {});
      obj = await apiGetDetails('assembleias', widget.id);
      votacoes = obj['votacoes'];
      meus_votos = obj['meusVotos'];
      obj = obj['assembleia'];
      _isLoading = false;
      setState(() {});
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  delete(idToRemove) async {
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('assembleias/votacoes', idToRemove);
      changeLoading(false);
      if(res){
        load();
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  insertVoto(opcao_id, votacao_id) async{
    try{
      changeLoading(true);
      var obj = VotoModel(
        opcao_id: opcao_id,
        votacao_id: votacao_id
      );
      var res = await apiSaveObject("assembleias/votacoes/voto", "voto", obj, false);
      changeLoading(true);
      if(res.toString().isEmpty){
        load();
      }else{
        displayMessage(context, getText('alert_error'), res.toString());
      }
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
          if(obj != null)
          Container(  
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),           
            ),    
            child: Column(              
              children: [
                NavigationDefault(title: getText('lb_assembleia'), buttonEnd: (getUserType() == 'sindico'), 
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => ModalFinalizarAssembleia(assembleia: obj)),);
                  },
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            DividerDefault(title: getText('assembleia_infos')),  
                            LabelDefault(title: obj['titulo'], color: Colors.grey.shade800, weight: FontWeight.w500,),                            
                            SizedBox(height: 10),       
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if(getUserType() == 'sindico')
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(context,MaterialPageRoute(builder: (context) => NewAssembleia(isEdit: true, myId: obj['id']))).then((_) {
                                        load();
                                      });
                                    },
                                    icon: Icon(Icons.edit, size: 25, color: Theme.of(context).hintColor),
                                  ),
                                Row(
                                  children: [
                                    Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                                    SizedBox(width: 5),
                                    LabelDefault(title: '${obj['data']} às ${obj['hora']}', size: 14),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 20), 
                            LabelTitle(title: getText('lb_descricao'), size: 15),
                            SizedBox(height: 10),
                            LabelDefault(maxLines: 100, title: obj['descricao']),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                for(var anexo in obj['anexos'].split(';')) 
                                  if(anexo != '')
                                    Container(
                                        padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                        child: InkWell(
                                          onTap: () { 
                                            launchInBrowser(
                                              anexo,
                                              context,
                                            );
                                          },
                                          child: Icon(Icons.download, size: 24, color: Theme.of(context).hintColor,)
                                        ),
                                      ),
                                  // Icon(Icons.download, size: 24, color: Theme.of(context).hintColor,),
                                  // SizedBox(width: 7),
                                  // Icon(Icons.download, size: 24, color: Theme.of(context).hintColor,),
                                  // SizedBox(width: 7),
                                  // Icon(Icons.download, size: 24, color: Theme.of(context).hintColor,),

                              ],
                            ),
                            SizedBox(height: 20),
                            LabelTitle(title: getText('assembleia_local'), size: 15),
                            SizedBox(height: 10),
                            LabelDefault(maxLines: 100, title: obj['local']),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(child: DividerDefault(title: getText('lb_votacoes'))),  
                                SizedBox(width: 10),
                                if(getUserType() == 'sindico')
                                  RoundedButton(
                                  onPressed: () {
                                      Navigator.push(context,MaterialPageRoute(builder: (context) => NewVotacao(idAssembleia: widget.id, isEnquete: false,))).then((_) {
                                        load();
                                      });
                                    },
                                  )
                              ],
                            ),
                            SizedBox(height: 10),
                            for(var item in votacoes) 
                              GestureDetector(
                                onTap: (){
                                  // Navigator.push(context,MaterialPageRoute(builder: (context) => DetailAssembleia()),);
                                },
                                child: CellVotacao(item: item, hasArrow: true, isRegister: false, meusVotos: meus_votos, 
                                      onPressedDelete:  (){delete(item['id']);} , 
                                      onPressedChoice:  (id){insertVoto(id, item['id']);} 
                                )
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
      )
    );
  }
}


class VotoModel{
  int? votacao_id;
  int? opcao_id;

  VotoModel({
    this.votacao_id,
    this.opcao_id,
  });

  Map toJson() => {
    'votacao_id': votacao_id,
    'opcao_id': opcao_id,
  };
}


                   
