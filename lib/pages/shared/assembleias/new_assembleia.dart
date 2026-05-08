
import 'dart:io';

import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_cupertino.dart';
import 'package:click/widgets/buttons/save_button.dart';
import 'package:click/widgets/buttons/upload_button.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/dividers/divider_default.dart';

class NewAssembleia extends StatefulWidget {
  const NewAssembleia({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewAssembleiaPageState createState() => _NewAssembleiaPageState();
}

class _NewAssembleiaPageState extends State<NewAssembleia> {

  List<File> list = [];
  var _isLoading = false;
  final txtTitulo = TextEditingController();
  final txtDescricao = TextEditingController();
  final txtData = TextEditingController();
  final txtHora = TextEditingController();
  final txtLocal = TextEditingController();
  final txtLink = TextEditingController();

  @override
  void initState(){
      super.initState();
      if(widget.isEdit){
        load();
      }
  }

  load() async{
    try{
      changeLoading(true);
      var obj = await apiGetDetails("assembleias", widget.myId!);
      if(obj == null){
        throw(getText('alert_generic_error'));
      }
      txtTitulo.text = obj["assembleia"]["titulo"];
      txtDescricao.text = obj["assembleia"]["descricao"];
      txtData.text = obj["assembleia"]["data"];
      txtHora.text = obj["assembleia"]["hora"];
      txtLocal.text = obj["assembleia"]["local"];
      txtLink.text = obj["assembleia"]["link"];
      for(var item in obj["assembleia"]['anexos'].split(';')){
        if(item.toString().isNotEmpty){
          list.add(await fileFromPdfUrl(item));
        }
      }            
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      changeLoading(false);
    }
  }

  save() async{
    // return;
    try{
      changeLoading(true);
      List<String> base64 = [];
        for(var item in list){
          base64.add(convertToBase64(item, 'application/pdf'));
        }
        
      var obj = AssembleiaModel(
        id: widget.myId ?? -1, 
        titulo: txtTitulo.text, 
        descricao: txtDescricao.text,
        data: convertStringToDate(txtData.text), 
        hora: convertStringToTime(txtHora.text), 
        local: txtLocal.text,
        link: txtLink.text,
        docs: base64
      );
      var res = await apiSaveObject("assembleias", "assembleia", obj, widget.isEdit);
      changeLoading(false);
      if(res.toString().isEmpty){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), res.toString());
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), e.toString());
    }finally{
      changeLoading(false);
    }
  }

  delete() async {
    // return;
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('assembleias', widget.myId!);
      changeLoading(false);
      if(res){
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
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
                NavigationDefault(title: widget.isEdit ? getText('assembleia_nav_edit') : getText('assembleia_nav_new')),
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
                            DividerDefault(title: getText('assembleia_infos')),
                            TextFieldDefault(title: getText('lb_titulo'), controller: txtTitulo),
                            SizedBox(height: 10), 
                            TextFieldDefault(title: getText('lb_descricao'), controller: txtDescricao),
                            SizedBox(height: 10),
                            DividerDefault(title: getText('assembleia_data_local')),
                            InkWell(
                              onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtData.text = text; });  
                                    }, initialDate: DateTime.now(), type: 'date',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('data'), controller: txtData, placeholder: "dd/mm/aaaa", enabled: false,)
                            ),
                            SizedBox(height: 10),
                            InkWell(
                              onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtHora.text = text; });  
                                    }, initialDate: null, type: 'time',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('hora'), controller: txtHora, placeholder: "hh:mm", enabled: false)
                            ),
                            SizedBox(height: 10),
                            TextFieldDefault(title: getText('assembleia_local'), controller: txtLocal),
                            SizedBox(height: 10),
                            DividerDefault(title: getText('lb_complementos').toUpperCase()),
                            TextFieldDefault(title: getText('assembleia_link_online'), controller: txtLink),
                            SizedBox(height: 10),   
                            uploadFile(title: getText('assembleia_arquivos'), types:['pdf'], maxDocs:3,
                              defaults: list,
                              onPressed: (listFiles){
                                list = listFiles;
                              },
                            ),
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

class AssembleiaModel{
  int? id;
  String? titulo;
  String? descricao;
  String? data;
  String? hora;
  String? local;
  String? link;
  List<String>? docs;

  AssembleiaModel({
    this.id,
    this.titulo,
    this.descricao,
    this.data,
    this.hora,
    this.local,
    this.link,
    this.docs,
  });

  Map toJson() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'data': data,
    'hora': hora,
    'local': local,
    'link': link,
    'docs': docs,
  };
}
  


                   
