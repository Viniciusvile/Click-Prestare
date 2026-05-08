import 'dart:io';
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/save_button.dart';
import 'package:click/widgets/buttons/upload_button.dart';
import 'package:click/widgets/checkbox/checkbox_filled.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class NewOcorrencia extends StatefulWidget {
  const NewOcorrencia({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewOcorrenciaPageState createState() => _NewOcorrenciaPageState();
}

class _NewOcorrenciaPageState extends State<NewOcorrencia> {
  List<File> list = [];
  var _isLoading = false;
  final txtDescricao = TextEditingController();
  var currentTipo = '';
  List<dynamic> categorias = [];

  @override
  void initState(){
      super.initState();
      if(widget.isEdit){
        load();
      }else{
        loadCategorias();
      }
  }

  load() async{
    changeLoading(true);
    var obj = await apiGetDetails("ocorrencias", widget.myId!);
    categorias = await apiGetAll("ocorrencias/categorias");
    txtDescricao.text = obj["descricao"];
    currentTipo = obj["tipoId"].toString();
    for(var item in obj['anexos'].split(';')){
      list.add(await fileFromImageUrl(item));
    }
    print(list);
    setState(() {});
    changeLoading(false);
    if(obj == null){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  loadCategorias() async{
    changeLoading(true);
    categorias = await apiGetAll("ocorrencias/categorias");
    setState(() {});
    changeLoading(false);
  }

  save() async{
    try{
      if(currentTipo.isEmpty){
        displayMessage(context, getText('alert_ops'), getText('ocorrencia_erro_tipo'));
        return;
      }
      List<String> base64 = [];
      for(var item in list){
        base64.add(convertToBase64(item, 'image/png'));
      }
      
      var doc = OcorrenciaModel(
        id: widget.myId ?? -1, 
        descricao: txtDescricao.text, 
        docs: base64,
        tipo: currentTipo,
        isResposta: false
      );
      changeLoading(true);
      var message = await apiSaveObject('ocorrencias', 'ocorrencia', doc,  widget.isEdit);

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
      var res = await apiDeleteObject('ocorrencias', widget.myId!);
      changeLoading(false);
      if(res){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(  
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),           
            ),    
            child: Column(
              children: [
                NavigationDefault(title: widget.isEdit ? getText('ocorrencia_nav_edit') : getText('ocorrencia_abertura_nav')),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          LabelDefault(title: getText('lb_anexos'), size: 12, color: Colors.grey.shade600,),
                          SizedBox(height: 10), 
                          uploadFile(title: getText('lb_insira_fotos'), types:['jpg', 'png'], maxDocs:3,
                            defaults: list,
                            onPressed: (listFiles){
                              list = listFiles;
                            },
                          ),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('lb_descricao'), controller: txtDescricao),                          
                          SizedBox(height: 15),  
                          LabelDefault(title: getText('ocorrencia_tipo'), size: 12, color: Colors.grey.shade600,),
                          SizedBox(height: 10),  
                          for(var categ in categorias)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap:(){
                                      changeTipo(categ["id"].toString());
                                    },
                                    child: checkbox_filled(title: categ["nome"], isChecked: currentTipo==categ["id"].toString())
                                  ),
                                  SizedBox(width: 5),
                                ],
                              ),
                            ),
                      ],
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


class OcorrenciaModel{
  int? id;
  String? descricao;
  String? tipo;
  List<String>? docs;
  bool? isResposta;

  OcorrenciaModel({
    this.id,
    this.descricao,
    this.docs,
    this.tipo,
    this.isResposta
  });

  Map toJson() => {
    'id': id,
    'descricao': descricao,
    'docs': docs,
    'tipo': tipo,
    'isResposta': isResposta
  };
}

                   
