
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/save_button.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
// import 'package:flutter/widgets.dart';

import '../../../widgets/dividers/divider_default.dart';

class NewComunicado extends StatefulWidget {
  const NewComunicado({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewComunicadoPageState createState() => _NewComunicadoPageState();
}

class _NewComunicadoPageState extends State<NewComunicado> {
  var _isLoading = false;
  final txtTitulo = TextEditingController();
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
    var obj = await apiGetDetails("comunicados", widget.myId!);
    txtTitulo.text = obj["titulo"];
    txtDescricao.text = obj["descricao"];
    changeLoading(false);
    if(obj == null){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  save() async{
    try{
      changeLoading(true);
      var obj = ComunicadoModel(id: widget.myId ?? -1, titulo: txtTitulo.text, descricao: txtDescricao.text);
      var res = await apiSaveObject("comunicados", "comunicado", obj, widget.isEdit);
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
      var res = await apiDeleteObject('comunicados', widget.myId!);
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
                NavigationDefault(title: widget.isEdit ? getText('comunicado_nav_edit') : getText('comunicado_nav_new')),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          DividerDefault(title: getText('comunicados_infos')),
                          TextFieldDefault(title: getText('lb_titulo'), controller: txtTitulo),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('lb_descricao'), controller: txtDescricao),                          
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

class ComunicadoModel{
  int? id;
  String? titulo;
  String? descricao;

  ComunicadoModel({
    this.id,
    this.titulo,
    this.descricao
  });

  Map toJson() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao
  };
}
                   
