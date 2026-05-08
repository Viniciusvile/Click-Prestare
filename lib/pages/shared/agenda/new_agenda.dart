
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/save_button.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/alerts/modal_cupertino.dart';
import '../../../widgets/dividers/divider_default.dart';

class NewAgenda extends StatefulWidget {
  const NewAgenda({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewAgendaPageState createState() => _NewAgendaPageState();
}

class _NewAgendaPageState extends State<NewAgenda> {
  var _isLoading = false;
  
  var ckAlertar = false;
  final txtTitulo = TextEditingController();
  final txtDataInicio = TextEditingController();
  final txtDataTermino = TextEditingController();
  final txtHoraInicio = TextEditingController();
  final txtHoraTermino = TextEditingController();
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
    var obj = await apiGetDetails("agenda", widget.myId!);
    txtTitulo.text = obj["titulo"];
    txtDataInicio.text = obj["data_inicio"];
    txtDataTermino.text = obj["data_termino"];
    txtHoraInicio.text = obj["hora_inicio"];
    txtHoraTermino.text = obj["hora_termino"];
    txtDescricao.text = obj["descricao"];
    ckAlertar = obj["alertar_moradores"];
    setState(() {});
    changeLoading(false);
    if(obj == null){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  save() async{
    try{
      var obj = AgendaModel(
        id: widget.myId ?? -1, 
        titulo: txtTitulo.text, 
        data_inicio: convertStringToDate(txtDataInicio.text), 
        data_termino: convertStringToDate(txtDataTermino.text), 
        hora_inicio: convertStringToTime(txtHoraInicio.text), 
        hora_termino: convertStringToTime(txtHoraTermino.text), 
        descricao: txtDescricao.text,
        alertar: true
      );
      changeLoading(true);
      var res = await apiSaveObject("agenda", "agenda", obj, widget.isEdit);
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
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('agenda', widget.myId!);
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(  
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),           
            ),    
            child: Column(
              children: [
                NavigationDefault(title: widget.isEdit ? getText('editar_manutencao') : getText('nova_manutencao')),
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
                            DividerDefault(title: getText('manut_about')),
                            TextFieldDefault(title: getText('lb_titulo'), controller: txtTitulo),
                            SizedBox(height: 10), 
                            TextFieldDefault(title: getText('lb_descricao'), controller: txtDescricao),
                            SizedBox(height: 10), 
                            DividerDefault(title: getText('data_e_hora').toUpperCase()),
                            InkWell(
                               onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtDataInicio.text = text; });  
                                    }, initialDate: DateTime.now(), type: 'date',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('data_inicio'), controller: txtDataInicio, placeholder: "dd/mm/aaaa", enabled: false)
                            ),
                            SizedBox(height: 10), 
                            InkWell(
                              onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtHoraInicio.text = text; });  
                                    }, initialDate: null, type: 'time',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('hora_inicio'), controller: txtHoraInicio, placeholder: "hh:mm", enabled: false)
                            ),
                            SizedBox(height: 10), 
                            InkWell(
                              onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtDataTermino.text = text; });  
                                    }, initialDate: convertStringToDateFormat(txtDataInicio.text) ?? DateTime.now(), type: 'date',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('data_termino'), controller: txtDataTermino, placeholder: "dd/mm/aaaa", enabled: false)
                            ),
                            SizedBox(height: 10), 
                            InkWell(
                              onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtHoraTermino.text = text; });  
                                    }, initialDate: null, type: 'time',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('hora_termino'), controller: txtHoraTermino, placeholder: "hh:mm", enabled: false)
                            ),
                            SizedBox(height: 15),                                        
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


class AgendaModel{
  int? id;
  String? titulo;
  String? data_inicio;
  String? data_termino;
  String? hora_inicio;
  String? hora_termino;
  String? descricao;
  bool? alertar;

  AgendaModel({
    this.id,
    this.titulo,
    this.data_inicio,
    this.data_termino,
    this.hora_inicio,
    this.hora_termino,
    this.descricao,
    this.alertar
  });

  Map toJson() => {
    'id': id,
    'titulo': titulo,
    'data_inicio': data_inicio,
    'data_termino': data_termino,
    'hora_inicio': hora_inicio,
    'hora_termino': hora_termino,
    'descricao': descricao,
    'alertar': alertar
  };
}





                   
