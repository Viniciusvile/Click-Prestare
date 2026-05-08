
import 'dart:io';
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/save_button.dart';
import 'package:click/widgets/buttons/upload_button.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class NewManutencao extends StatefulWidget {
  const NewManutencao({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewManutencaoPageState createState() => _NewManutencaoPageState();
}

class _NewManutencaoPageState extends State<NewManutencao> {

  List<File> list = [];
  var _isLoading = false;
  final txtDescricao = TextEditingController();

  @override
  void initState(){
      super.initState();
      if(widget.isEdit){
        load();
      }
  }

  load() async{
    changeLoading(true);
    var obj = await apiGetDetails("manutencoes", widget.myId!);
    txtDescricao.text = obj["descricao"];
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

  save() async{
    List<String> base64 = [];
    for(var item in list){
      base64.add(convertToBase64(item, 'image/png'));
    }
     
    var doc = ManutencaoModel(
      id: widget.myId ?? -1, 
      descricao: txtDescricao.text, 
      docs: base64
    );
    changeLoading(true);
    var message = await apiSaveObject('manutencoes', 'manutencao', doc, widget.isEdit);
    changeLoading(false);
    if(message == ""){
      Navigator.pop(context);
    }else{
      displayMessage(context, getText('alert_error'), message);
    }
  }

  delete() async {
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('manutencoes', widget.myId!);
      changeLoading(false);
      if(res){
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
                NavigationDefault(title: widget.isEdit ? getText('manut_edit') : getText('manut_new')),
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

class ManutencaoModel{
  int? id;
  String? descricao;
  List<String>? docs;

  ManutencaoModel({
    this.id,
    this.descricao,
    this.docs
  });

  Map toJson() => {
    'id': id,
    'descricao': descricao,
    'docs': docs
  };
}


                   
