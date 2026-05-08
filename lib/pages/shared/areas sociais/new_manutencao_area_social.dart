
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/checkbox/checkbox_default.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
// import 'package:flutter/widgets.dart';

class NewManutencaoAreaSocial extends StatefulWidget {
  const NewManutencaoAreaSocial({Key? key, required this.isEdit, this.myId, required this.idArea, this.obj}) : super(key: key);
  final bool isEdit;
  final int? myId;
  final int idArea;
  final dynamic obj;

  @override
  _NewManutencaoAreaSocialPageState createState() => _NewManutencaoAreaSocialPageState();
}

class _NewManutencaoAreaSocialPageState extends State<NewManutencaoAreaSocial> {

  var _isLoading = false;

  final txtDataInicio = TextEditingController();
  final txtDataTermino = TextEditingController();
  final txtHoraInicio = TextEditingController();
  final txtHoraTermino = TextEditingController();
  final txtDescricao = TextEditingController();

  @override
  void initState(){
      super.initState();           
      if(widget.isEdit) {
        load();
      }
  }

  load() async{
    txtDataInicio.text = widget.obj['data_inicio'];
    txtDataTermino.text = widget.obj['data_termino'];
    txtHoraInicio.text = widget.obj['hora_inicio'];
    txtHoraTermino.text = widget.obj['hora_termino'];
    txtDescricao.text = widget.obj['descricao'];
    setState(() {});
  }

  save() async{
    try{
      changeLoading(true);
      var obj = AreaSocialManutencaoModel(
        id: widget.myId ?? -1, 
        id_area_social: widget.idArea,
        data_inicio: convertStringToDate(txtDataInicio.text),
        hora_inicio: convertStringToTime(txtHoraInicio.text),
        data_termino: convertStringToDate(txtDataTermino.text),
        hora_termino: convertStringToTime(txtHoraTermino.text),
        descricao: txtDescricao.text
      );

      var res = await apiSaveObject("areas-sociais/manutencao", "manutencao", obj, widget.isEdit);

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
      var res = await apiDeleteObject('areas-sociais/manutencao', widget.myId!);
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

    var _pageSize = MediaQuery.of(context).size.height;

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
                NavigationDefault(title: widget.isEdit ? getText('editar_manutencao') : getText('nova_manutencao')),
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                      height: _pageSize >= 640 ? MediaQuery.of(context).size.height - 110 : 530,
                      decoration: BoxMainRounded(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [                      
                            TextFieldDefault(title: getText('data_inicio'), controller: txtDataInicio, mask: TextInputMask(mask: ['99/99/9999'],reverse: false), keyboard: TextInputType.number, placeholder: "dd/mm/aaaa"),
                            SizedBox(height: 10), 
                            TextFieldDefault(title: getText('hora_inicio'), controller: txtHoraInicio, mask: TextInputMask(mask: ['99:99'],reverse: false), keyboard: TextInputType.number, placeholder: "hh:mm"),
                            SizedBox(height: 10), 
                            TextFieldDefault(title: getText('data_termino'), controller: txtDataTermino, mask: TextInputMask(mask: ['99/99/9999'],reverse: false), keyboard: TextInputType.number, placeholder: "dd/mm/aaaa"),
                            SizedBox(height: 10), 
                            TextFieldDefault(title: getText('hora_termino'), controller: txtHoraTermino, mask: TextInputMask(mask: ['99:99'],reverse: false), keyboard: TextInputType.number, placeholder: "hh:mm"),
                            SizedBox(height: 10), 
                            TextFieldDefault(title: getText('lb_descricao'), controller: txtDescricao),
                            SizedBox(height: 10), 
                            checkbox_default(title: getText('gerar_alerta'),),   
                            SizedBox(height: 10),  
                            Expanded(child: Container()),   
                            DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                              onPressed: () {
                                save();
                              }
                            ),
                            if(widget.isEdit)
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap:(){ delete(); },
                                child: Align(
                                  alignment: Alignment.center,
                                  child: LabelDefault(title: getText("btn_delete"), size: 18, color: Colors.red)
                                ),
                              ),
                            ), 
                            
                            // SaveButton(isEdit: widget.isEdit, 
                            //   onPressedDelete:  (){ delete(); } , 
                            //   onPressedSave:  (){ save(); } 
                            // ),
                        ],
                      ),
                    ),
                  )
                ),
                // SaveButton(isEdit: widget.isEdit, 
                //   onPressedDelete:  (){ delete(); } , 
                //   onPressedSave:  (){ save(); } 
                // ),
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


class AreaSocialManutencaoModel{
  int? id;
  int? id_area_social;
  String? data_inicio;
  String? hora_inicio;
  String? data_termino;
  String? hora_termino;
  String? descricao;
  
  AreaSocialManutencaoModel({
    this.id,
    this.id_area_social,
    this.data_inicio,
    this.hora_inicio,
    this.data_termino,
    this.hora_termino,
    this.descricao
  });

  Map toJson() => {
    'id': id,
    'id_area_social': id_area_social,
    'data_inicio': data_inicio,
    'hora_inicio': hora_inicio,  
    'data_termino': data_termino,
    'hora_termino': hora_termino,  
    'descricao': descricao
  };
}




                   
