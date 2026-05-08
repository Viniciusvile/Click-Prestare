
import 'dart:convert';
import 'dart:io';

import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_cupertino.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/cells/cell_horario_area_social.dart';
import 'package:click/widgets/checkbox/checkbox_default.dart';
import 'package:click/widgets/dividers/divider_default.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:badges/badges.dart' as badges;
// import 'package:flutter/widgets.dart';

class NewAreaSocial extends StatefulWidget {
  const NewAreaSocial({Key? key, required this.isEdit, this.myId, this.obj}) : super(key: key);
  final bool isEdit;
  final int? myId;
  final dynamic obj;

  @override
  _NewAreaSocialPageState createState() => _NewAreaSocialPageState();
}

class _NewAreaSocialPageState extends State<NewAreaSocial> {
    var _isLoading = false;
    final txtNome = TextEditingController();
    final txtCapacidade = TextEditingController();
    var autorizacao = "0";
    var pagamento = "0";
    var agendamento = "0";
    File? imageFile;

    late List<DiasDaSemanaAreaSocialModel> daysOfWeek = [
      DiasDaSemanaAreaSocialModel(nome: getText('segunda'), horarios: []),
      DiasDaSemanaAreaSocialModel(nome: getText('terca'), horarios: []),
      DiasDaSemanaAreaSocialModel(nome: getText('quarta'), horarios: []),
      DiasDaSemanaAreaSocialModel(nome: getText('quinta'), horarios: []),
      DiasDaSemanaAreaSocialModel(nome: getText('sexta'), horarios: []),
      DiasDaSemanaAreaSocialModel(nome: getText('sabado'), horarios: []),
      DiasDaSemanaAreaSocialModel(nome: getText('domingo'), horarios: []),
    ];

  @override
  void initState(){
      super.initState();           
      if(widget.isEdit) {
        changeLoading(true);
        load();
      }
  }

  load() async{
    daysOfWeek.clear();
    for(var horario in widget.obj['horarios']){    
      List<HorarioModel> list = [];
      for(var disponibilidade in horario["horarios"]){
        list.add(HorarioModel(horarioDe: disponibilidade["horarioDe"], horarioAte: disponibilidade["horarioAte"]));
      }      
      daysOfWeek.add(DiasDaSemanaAreaSocialModel(nome: horario["nome"], horarios: list));
    }
    txtNome.text = widget.obj['nome'];
    txtCapacidade.text = widget.obj['capacidade'].toString();
    autorizacao = widget.obj['precisa_autorizacao'].toString();
    pagamento = widget.obj['precisa_pagamento'].toString();
    agendamento = widget.obj['precisa_agendar'].toString();
    imageFile = await fileFromImageUrl(widget.obj["imagem"]);
    changeLoading(false);
  }

  selectHorario(index, add){
    // if(index < 7){return;}
    // print(list[index % 7]);
    // if(add){
    //   list[index] = list[index].split(':')[0]+':1';
    // }else{
    //   list[index] = list[index].split(':')[0]+':0';
    // }
    // setState(() {});
  }

  save() async{
    try{
      changeLoading(true);

      var base64 = null;
      if(imageFile != null){
        List<int> imageBytes = imageFile!.readAsBytesSync();
        base64 = "data:image/png;base64,"+base64Encode(imageBytes);
      }
      
      var obj = AreaSocialModel(
        id: widget.myId ?? -1, 
        nome: txtNome.text, 
        capacidade: int.parse(txtCapacidade.text.isNotEmpty ? txtCapacidade.text : "-1"),
        agendar: agendamento,
        pagar: pagamento,
        autorizacao: autorizacao,
        imagem: base64,
        horarios: daysOfWeek
      );

      var res = await apiSaveObject("areas-sociais", "areaSocial", obj, widget.isEdit);
      
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
      var res = await apiDeleteObject('areas-sociais', widget.myId!);
      changeLoading(false);
      if(res){
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  void selectCamera()async {
    var res = await getPhoto(context);
    imageFile = File(res.path);
    setState(() {});
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
                NavigationDefault(title: getText('area_social_nav_new')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 20), 
                    width: MediaQuery.of(context).size.width,
                    height: agendamento=="1" ? 570 + 900 : 
                     _pageSize >= 680 ? _pageSize - 110 : 570,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: (){selectCamera();},
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: 
                              Image(
                                  image: imageFile == null
                                      ? AssetImage('assets/images/no_image_area.png')
                                      : Image.file(File(imageFile!.path)).image,
                                  fit: BoxFit.cover,
                                  height: 180,
                                  width: MediaQuery.of(context).size.width,
                                )
                            ),
                          ),
                          SizedBox(height: 10), 
                          DividerDefault(title: getText('area_social_dados_iniciais')),
                          TextFieldDefault(title: getText('nome'), controller: txtNome),
                          SizedBox(height: 15), 
                          TextFieldDefault(title: getText('area_social_capacidade_maxima'), placeholder: getText('area_social_capacidade_vazio'), controller: txtCapacidade, mask: TextInputMask(mask: ['9999'],), keyboard: TextInputType.number,),
                          SizedBox(height: 15), 
                          DividerDefault(title: getText('area_social_obrigatoriedades')),
                          checkbox_default(title: getText('area_social_precisa_autorizacao'), isChecked: autorizacao=="1", onPressed: (value){autorizacao = autorizacao=="0" ? "1" : "0";setState((){});}),
                          SizedBox(height: 5), 
                          checkbox_default(title: getText('area_social_precisa_pagamento'), isChecked: pagamento=="1", onPressed: (value){pagamento = pagamento=="0" ? "1" : "0";setState((){});}),
                          SizedBox(height: 5),
                          checkbox_default(title: getText('area_social_precisa_agendamento'), isChecked: agendamento=="1", onPressed: (value){agendamento = agendamento=="0" ? "1" : "0";setState((){});}),
                          SizedBox(height: 20), 
                          if(agendamento=="1")
                          Column(
                            children: [
                              const DividerDefault(title: "FUNCIONAMENTO"),
                              for(var dia in daysOfWeek)
                                ExpansionTile(
                                  collapsedBackgroundColor: Colors.grey.shade100,
                                  backgroundColor: Colors.grey.shade100,                  
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      LabelDefault(title: dia.nome, color: Colors.black, size: 15, weight: FontWeight.w500,),
                                      badges.Badge(
                                        badgeContent: LabelDefault(title: dia.horarios.length.toString(), color: Colors.white, size: 14), 
                                        badgeStyle: badges.BadgeStyle(
                                          badgeColor: Theme.of(context).hintColor,
                                        ),
                                      )
                                    ],
                                  ),
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        setState(() { dia.horarios.add(HorarioModel(horarioDe: "08:00", horarioAte: "17:00")); });                                        
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [          
                                          LabelDefault(title: getText('area_social_novo_horario'), color: Theme.of(context).primaryColor,),
                                          SizedBox(width: 10),
                                          Icon(MdiIcons.plusCircle, size: 26, color: Theme.of(context).primaryColor,),
                                          SizedBox(width: 20),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    for(var i=0; i<dia.horarios.length; i++)
                                      CellHorarioAreaSocial(horario: dia.horarios[i], 
                                        onDelete: (){ setState(() { dia.horarios.removeAt(i); }); },
                                        onChangeDe: () {
                                          showCupertinoModalPopup(context: context,
                                              builder: (BuildContext context){
                                                return ModalCupertino(
                                                  onPressed: (text) { setState(() { dia.horarios[i].horarioDe = text; });  
                                                }, initialDate: null, type: 'time',);
                                              }
                                            );
                                        },
                                        onChangeAte: () {
                                          showCupertinoModalPopup(context: context,
                                              builder: (BuildContext context){
                                                return ModalCupertino(
                                                  onPressed: (text) { setState(() { dia.horarios[i].horarioAte = text; });  
                                                }, initialDate: null, type: 'time',);
                                              }
                                            );
                                        },
                                      )
                                  ],
                                ),
                            ]
                          ),
                          SizedBox(height: 10),  
                          // if(agendamento=="0")
                          //   Expanded(child: Container()),                                          
                          SizedBox(
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            child: DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                              onPressed: () {
                                save();
                              }
                            ),
                          ),
                          SizedBox(height: 15), 
                          if(widget.isEdit)
                            InkWell(
                              onTap:(){ delete(); },
                              child: Align(
                                alignment: Alignment.center,
                                child: LabelDefault(title: getText("btn_delete"), size: 18, color: Colors.red)
                              ),
                            ),
                        ]
                      ),
                    ),
                  ),
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
    );
  }
}


class AreaSocialModel{
  int? id;
  String? nome;
  int? capacidade;
  String? imagem;
  String? agendar;
  String? autorizacao;
  String? pagar;
  List<DiasDaSemanaAreaSocialModel>? horarios;

  AreaSocialModel({
    this.id,
    this.nome,
    this.capacidade,
    this.imagem,
    this.agendar,
    this.autorizacao,
    this.pagar,
    this.horarios
  });

  Map toJson() => {
    'id': id,
    'nome': nome,
    'capacidade': capacidade,
    'imagem': imagem,
    'agendar': agendar,
    'autorizacao': autorizacao,
    'pagar': pagar,
    'horarios': horarios
  };
}

class DiasDaSemanaAreaSocialModel{
  String nome;
  List<HorarioModel> horarios;

  DiasDaSemanaAreaSocialModel({
    required this.nome,
    required this.horarios
  });

  Map toJson() => {
    'nome': nome,
    'horarios': horarios,    
  };
}

class HorarioModel{
  String horarioDe;
  String horarioAte;

  HorarioModel({
    required this.horarioDe,
    required this.horarioAte
  });

  Map toJson() => {
    'horarioDe': horarioDe,
    'horarioAte': horarioAte,    
  };
}



                   
