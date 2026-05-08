
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/alerts/modal_cupertino.dart';
import 'package:click/widgets/checkbox/checkbox_default.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';

import '../../../controllers/controller_generic.dart';
import '../../../utils/local_storage.dart';
import '../../../utils/utils.dart';
import '../../../widgets/alerts/bottom_sheet_aptos.dart';
import '../../../widgets/alerts/loader.dart';
import '../../../widgets/buttons/save_button.dart';
import '../../../widgets/dividers/divider_default.dart';
import '../../singleton.dart';

class NewVisitante extends StatefulWidget {
  const NewVisitante({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewVisitantePageState createState() => _NewVisitantePageState();
}

class _NewVisitantePageState extends State<NewVisitante> {

  final txtNome = TextEditingController();
  final txtDocumento = TextEditingController();
  final txtDataInicio = TextEditingController();
  final txtDataTermino = TextEditingController();
  final txtBloco = TextEditingController();
  final txtApto = TextEditingController();
  final txtObs = TextEditingController();

  var idMyApartment = null;
  var currentTipo = '';
  var _isLoading = false;
  var list = [];
  var listBlocos = [];

  @override
  void initState(){
    super.initState();
    if(widget.isEdit){
      load();
    }else{
      currentTipo = 'visitante';
    }
    if(getUserType()=="morador" ){
      txtBloco.text = Singleton.instance.bloco;
      txtApto.text = Singleton.instance.apartamento;
      idMyApartment = Singleton.instance.id_apartamento;
    }else{
      loadListAptos();
    }
  }

  load() async{
    try{
      changeLoading(true);
      var obj = await apiGetDetails("visitantes", widget.myId!);
      txtNome.text = obj["nome"] ?? "";
      txtDocumento.text = obj["doc_identificacao"] != null ? obj["doc_identificacao"].toString() : "";
      txtDataInicio.text = obj["data_inicio"] ?? "";
      txtDataTermino.text = obj["data_termino"] ?? "";
      txtApto.text = obj["apto"] ?? "";
      txtBloco.text = obj["apto_bloco"] ?? "";
      txtObs.text = obj["observacoes"] ?? "";
      currentTipo = obj["is_visitante"] == 1 ? 'visitante' : 'prestador';
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      changeLoading(false);
    }       
  }

  loadListAptos() async{
    try{
      changeLoading(true);
      var aptos = await apiGetAll("condominio/aptos");
      list = aptos;
      listBlocos.clear();
      for(var item in list){
        if(!listBlocos.contains(item['bloco'])){
          listBlocos.add(item['bloco']);
        }
      }
      
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      changeLoading(false);
    }
  }

  save() async {
    try{            
      var visitante = VisitanteModel(
        id: widget.myId ?? -1, 
        nome: txtNome.text,
        doc_identificacao: txtDocumento.text,
        data_inicio: convertStringToDateTime(txtDataInicio.text),
        data_termino: convertStringToDateTime(txtDataTermino.text),
        avisar: true, 
        observacoes: txtObs.text,
        id_apartamento: idMyApartment ?? getIdApto(),
        is_visitante: currentTipo == 'visitante',
        is_prestador: currentTipo == 'prestador',
      );
      changeLoading(true);
      var message = await apiSaveObject('visitantes', 'visitante', visitante,  widget.isEdit);

      if(message == ""){
        Navigator.pop(context);
      }else{
        displayMessage(context, getText('alert_error'), message);
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), e.toString());
    }finally{
      changeLoading(false);
    } 
  }

  delete() async {
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('visitantes', widget.myId!);
      changeLoading(false);
      if(res){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  getListAptos(){
    var listAptos = [];
    for (var item in list){
      if (item['bloco'] == txtBloco.text && !list.contains(item["apto"])){
        listAptos.add(item["apto"]);
      }
    }
    return listAptos;
  }

  getIdApto(){
    for(var item in list){
      if(item['bloco'] == txtBloco.text && item["apto"] == txtApto.text){
        return item["id"];
      }
    }
    throw("Selecione o apartamento desejado");
  }

  changeTipo(tipo) async{
    currentTipo = tipo;
    setState(() {});     
  }

  changeLoading(bool value){
    _isLoading = value;
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
                NavigationDefault(title: widget.isEdit ? getText('visitantes_nav_edit') : 'visitantes_nav_new'),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DividerDefault(title: getText('funcionario_infos_pessoais')),
                          TextFieldDefault(title: getText('user_nome_completo'), controller: txtNome,),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('user_documento'), controller: txtDocumento),
                          SizedBox(height: 10), 
                          DividerDefault(title: getText('visitantes_infos')),
                          InkWell(
                            onTap: () =>
                              showCupertinoModalPopup(context: context,
                                builder: (BuildContext context){
                                  return ModalCupertino(
                                    onPressed: (text) { setState(() { txtDataInicio.text = text; });  
                                  }, initialDate: DateTime.now(), type: 'datetime',);
                                }
                              ),                                                                                                               
                            child: TextFieldDefault(title: getText('visitantes_data_hora_inicio'), controller: txtDataInicio, placeholder: "dd/mm/aaaa hh:mm", enabled: false)
                          ),
                          SizedBox(height: 10), 
                          InkWell(
                            onTap: (){
                              showCupertinoModalPopup(context: context,
                                builder: (BuildContext context){
                                  return ModalCupertino(
                                    onPressed: (text) { setState(() { txtDataTermino.text = text; });  
                                  }, initialDate: convertStringToDateTimeFormat(txtDataInicio.text) ?? DateTime.now(), type: 'datetime',);
                                }
                              );
                            },
                            child: TextFieldDefault(title: getText('visitantes_data_hora_termino'), controller: txtDataTermino, placeholder: "dd/mm/aaaa hh:mm", enabled: false)
                          ),
                          SizedBox(height: 10), 
                          LabelDefault(title: getText('lb_tipo'), size: 12, color: Colors.grey.shade600,),
                          SizedBox(height: 10), 
                          checkbox_default(
                            title: getText('visitante'), 
                            isChecked: currentTipo=='visitante',
                            onPressed: (value){ changeTipo('visitante'); }
                          ),
                          checkbox_default(
                            title: getText('visitante_prestador_servico'), 
                            isChecked: currentTipo=='prestador', 
                            onPressed: (value){ changeTipo('prestador'); }
                          ),
                          SizedBox(height: 10), 
                          // LabelDefault(title: getText('lb_aviso').toUpperCase(), size: 12, color: Colors.grey.shade600,),                          
                          // SizedBox(height: 30),   
                          DividerDefault(title: getText('lb_infos_apto')),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: InkWell(
                                    onTap: (){ 
                                      if(getUserType()=="morador"){return;}
                                      if(listBlocos.isEmpty){
                                        return displayMessage(context, getText('alert_ops'), getText('alert_nenhum_bloco'));
                                      }
                                      bottomSheetAptos(context, listBlocos, txtBloco.text, (blocoSelected){
                                        if(txtBloco.text != blocoSelected){
                                          txtApto.text = "";
                                        }
                                        txtBloco.text = blocoSelected;                                   
                                        Navigator.of(context).pop();
                                        FocusManager.instance.primaryFocus?.unfocus();
                                      });
                                    },
                                    child: TextFieldDefault(title: getText('lb_bloco'), controller: txtBloco, enabled: false)
                                  ),
                                ),
                                SizedBox(width: 10),   
                                Flexible(
                                  child: InkWell(
                                    onTap: (){ 
                                      if(getUserType()=="morador"){return;}
                                      if(getListAptos().isEmpty){
                                        return displayMessage(context, getText('alert_ops'), getText('visitante_erro_bloco'));
                                      }
                                      bottomSheetAptos(context, getListAptos(), txtApto.text, (aptoSelected){
                                        txtApto.text = aptoSelected;
                                        Navigator.of(context).pop();
                                        FocusManager.instance.primaryFocus?.unfocus();
                                      });
                                      },
                                    child: TextFieldDefault(title: getText('lb_apartamento'), controller: txtApto, enabled: false)
                                  ),
                                ),
                              ],
                            ),
                          ), 
                          SizedBox(height: 25),  
                          DividerDefault(title: getText('lb_observacoes_opcional')),
                          TextFieldDefault(title: getText('lb_observacoes'), controller: txtObs, keyboard: TextInputType.multiline),
                          SizedBox(height: 10),                                                            
                        ],
                      ),
                    ),
                  )
                ),
                SaveButton(isEdit: widget.isEdit, 
                  onPressedDelete:  (){delete();} , 
                  onPressedSave:  (){save();} 
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


class VisitanteModel{
  int? id;
  String? nome;
  String? doc_identificacao;
  String? data_inicio;
  String? data_termino;
  String? observacoes;
  int? id_apartamento;
  bool? avisar;
  bool? is_visitante;
  bool? is_prestador;

  VisitanteModel({
    this.id,
    this.nome,
    this.doc_identificacao,
    this.data_inicio,
    this.data_termino,
    this.avisar,
    this.id_apartamento,
    this.is_visitante,
    this.is_prestador,
    this.observacoes,
  });

  Map toJson() => {
    'id': id,
    'nome': nome,
    'doc_identificacao': doc_identificacao,
    'data_inicio': data_inicio,
    'data_termino': data_termino,
    'observacoes': observacoes,
    'id_apartamento': id_apartamento,
    'avisar': avisar,
    'is_visitante': is_visitante,
    'is_prestador': is_prestador,
  };
}





            
