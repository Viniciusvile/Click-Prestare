
import 'package:click/controllers/controller_enquetes.dart';
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_finalizar_assembleia.dart';
import 'package:click/widgets/cells/cell_votacao.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import '../../../widgets/dividers/divider_default.dart';

class DetailEnquete extends StatefulWidget {
  const DetailEnquete({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _DetailEnquetePageState createState() => _DetailEnquetePageState();
}

class _DetailEnquetePageState extends State<DetailEnquete> {
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
      obj = await apiGetDetails('assembleias/votacoes/enquetes', widget.id);
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
      var res = await apiDeleteObject('assembleias/votacoes', widget.id);
      changeLoading(false);
      if(res){
        load();
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  finish() async {
    try{
      var choice = await showConfirmDialog(context, text: getText('votacao_confirm_delete'));
      if(choice != null && choice){
        changeLoading(true);
        await apiFinishEnquete(widget.id.toString());        
        load();
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), e.toString());
    }finally{
      changeLoading(false);
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
                NavigationDefault(title: getText('votacao_enquete'), 
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
                            DividerDefault(title: getText('votacao_infos')),
                            LabelDefault(title: "${getText('lb_status')}:", color: Colors.grey.shade800, weight: FontWeight.w500,),   
                            SizedBox(height: 10),          
                            obj['votacao']["status"] == 0 ?
                              LabelDefault(title: getText('votacao_agendado'), size: 16)
                            : obj['votacao']["status"] == 1 ?
                              LabelDefault(title: getText('votacao_andamento'), color: Theme.of(context).primaryColor, size: 16,)
                            : obj['votacao']["status"] == 2 ?
                              LabelDefault(title: getText('votacao_finalizado'), color: Colors.red, size: 16)
                            : Container(),
                            SizedBox(height: 20),                                                               
                            LabelDefault(title: obj['votacao']['titulo'], color: Colors.grey.shade800, weight: FontWeight.w500,),                            
                            SizedBox(height: 10),
                            LabelDefault(maxLines: 100, title: obj['votacao']['descricao']),                            
                            SizedBox(height: 10),                             
                            CellVotacao(item: obj['votacao'], title: getText('escolha_opcao_desejada'), hasArrow: true, isRegister: false, meusVotos: obj['meuVoto'], 
                                  onPressedDelete:  (){delete('');} , 
                                  onPressedChoice:  (id){insertVoto(id, obj['votacao']['id']);} 
                            ),
                            SizedBox(height: 20),  
                            if(getUserType() == "sindico")
                              Visibility(
                                visible: obj['votacao']['status'] == 1,
                                child: InkWell(
                                  onTap: (){
                                    finish();
                                  },
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: LabelDefault(title: getText('votacao_finalizar'), size: 18, color: Colors.orange,)
                                  ),
                                ),
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
            const Loader(loadingTxt: '', opacity: 0.7, color: Colors.black, dismissibles: false)
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


                   
