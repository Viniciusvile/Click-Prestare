
import 'dart:convert';
import 'dart:io';

import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../widgets/dividers/divider_default.dart';

class NewFuncionario1 extends StatefulWidget {
  const NewFuncionario1({Key? key, required this.isEdit, this.myId}) : super(key: key);
    final bool isEdit;
    final int? myId;

  @override
  _NewFuncionario1PageState createState() => _NewFuncionario1PageState();
}

class _NewFuncionario1PageState extends State<NewFuncionario1> {
  File? imageFile;
  var _isLoading = false;

  final txtNome = TextEditingController();
  final txtDocumento = TextEditingController();
  final txtEmail = TextEditingController();
  final txtTelefone = TextEditingController();
  final txtFuncao = TextEditingController();
  final txtCH = TextEditingController();
  final txtPassword = TextEditingController();
  final txtSegunda = TextEditingController();
  final txtTerca = TextEditingController();
  final txtQuarta = TextEditingController();
  final txtQuinta = TextEditingController();
  final txtSexta = TextEditingController();
  final txtSabado = TextEditingController();
  final txtDomingo = TextEditingController();
  final txtExtra1 = TextEditingController();
  final txtExtra2 = TextEditingController();

  List<String> permissoes = [];
  var opcoesCategorias = [{
                            "display": getText('lb_areas_sociais'),
                            "value": "areas_sociais",
                          },
                          {
                            "display": getText('lb_comunicados'),
                            "value": "comunicados",
                          },
                          {
                            "display": getText('lb_ocorrencias'),
                            "value": "ocorrencias",
                          },
                          {
                            "display": getText('lb_manut_programadas'),
                            "value": "manutencoes_programadas",
                          },
                          {
                            "display": getText('lb_prestadores_servico'),
                            "value": "prestadores_servico",
                          },
                          {
                            "display": getText('lb_agendar_mudanca'),
                            "value": "agendar_mudanca",
                          },
                          {
                            "display": getText('lb_cadastrar_visitante'),
                            "value": "cadastrar_visitante",
                          },
                          {
                            "display":  getText('lb_apartamentos'),
                            "value": "apartamentos",
                          }
                        ];

  @override
  void initState(){
      super.initState();
      if(widget.isEdit){
        load();
      }
  }

  load() async{
    changeLoading(true);
    var obj = await apiGetDetails("funcionarios", widget.myId!);
    txtNome.text = obj["nome"];
    txtDocumento.text = obj["documento"];
    txtEmail.text = obj["email"];
    txtTelefone.text = obj["telefone"];
    txtFuncao.text = obj["funcao"];
    txtCH.text = obj["ch"];
    imageFile = await fileFromImageUrl(obj["photo"]);
    txtExtra1.text = obj["extra1"] ?? '';   
    txtExtra2.text = obj["extra2"] ?? ''; 

    if(obj["areas_sociais"] == 1){permissoes.add('areas_sociais');}
    if(obj["comunicados"] == 1){permissoes.add('comunicados');}
    if(obj["ocorrencias"] == 1){permissoes.add('ocorrencias');}
    if(obj["manutencoes_programadas"] == 1){permissoes.add('manutencoes_programadas');}
    if(obj["prestadores_servico"] == 1){permissoes.add('prestadores_servico');}
    if(obj["agendar_mudanca"] == 1){permissoes.add('agendar_mudanca');}
    if(obj["cadastrar_visitante"] == 1){permissoes.add('cadastrar_visitante');}
    if(obj["apartamentos"] == 1){permissoes.add('apartamentos');}

    changeLoading(false);
    if(obj == null){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }
  
  void selectCamera()async {
    var res = await getPhoto(context);
    imageFile = File(res.path);
    setState(() {});
  }

  save() async{
    try{
      changeLoading(true);
      var base64 = null;
      if(imageFile != null){
        List<int> imageBytes = imageFile!.readAsBytesSync();
        base64 = "data:image/png;base64,"+base64Encode(imageBytes);
      }

      var obj = FuncionarioModel(
        id: widget.myId ?? -1, 
        nome: txtNome.text, 
        documento: txtDocumento.text, 
        email: txtEmail.text, 
        telefone: txtTelefone.text, 
        funcao: txtFuncao.text, 
        ch: txtCH.text, 
        senha: txtPassword.text, 
        photo: base64,
        permissoes: permissoes,
        extra1: txtExtra1.text,
        extra2: txtExtra2.text
      );

      var message = await apiSaveObject('funcionarios', 'funcionario', obj, widget.isEdit);
      
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
      var res = await apiDeleteObject('funcionarios', widget.myId!);
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(  
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),           
            ),    
            child: Column(
              children: [
                NavigationDefault(title: widget.isEdit ? getText('funcionario_nav_edit') : getText('funcionario_nav_new')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                    height: MediaQuery.of(context).size.height - 110,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: (){selectCamera();},
                            child: Stack(
                              children: [
                                Center(
                                  child: CircleAvatar(                      
                                    radius: 55,
                                    backgroundImage: imageFile == null
                                      ? const AssetImage('assets/images/defaultUser.png')
                                      : Image.file(File(imageFile!.path)).image,
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(80, 80, 0, 0),
                                    child: Icon(MdiIcons.camera, color: Theme.of(context).primaryColor),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          DividerDefault(title: getText('funcionario_infos_pessoais')),
                          SizedBox(height: 15),
                          TextFieldDefault(title: getText('user_nome_completo'), controller: txtNome),
                          SizedBox(height: 10),   
                          TextFieldDefault(title: getText('user_documento'), controller: txtDocumento),
                          SizedBox(height: 10),   
                          TextFieldDefault(title: getText('email'), controller: txtEmail),
                          SizedBox(height: 10),   
                          TextFieldDefault(title: getText('telefone'), keyboard: TextInputType.number, controller: txtTelefone),
                          SizedBox(height: 15),  
                          DividerDefault(title: getText('funcionario_infos_funcao')), 
                          SizedBox(height: 15),  
                          TextFieldDefault(title: getText('funcionario_funcao'), controller: txtFuncao),
                          SizedBox(height: 10),  
                          TextFieldDefault(title: getText('funcionario_horario_trabalho'), controller: txtCH, keyboard: TextInputType.multiline),
                          SizedBox(height: 15),  
                          DividerDefault(title: getText('funcionario_permissoes')),
                          SizedBox(height: 15),  
                          LabelDefault(title: getText('funcionario_permissoes_sobre'), size: 14, color: Colors.red.shade400, maxLines: 4, weight: FontWeight.w500,),
                          SizedBox(height: 15),
                          Wrap(
                            spacing: 8.0, 
                            runSpacing: 4.0, 
                            children: [
                              for(var categ in opcoesCategorias)
                                InkWell(
                                  onTap: (){
                                    if(permissoes.contains(categ["value"])){
                                      permissoes.remove(categ["value"]);
                                    }else{
                                      permissoes.add(categ["value"].toString());
                                    }
                                    setState(() {});
                                  },
                                  child: Chip(   
                                    label: LabelDefault(title: categ["display"]!, size: 13, 
                                                      color: permissoes.contains(categ["value"])
                                                        ? Colors.white
                                                        : Colors.black),
                                    deleteIcon: Icon(Icons.cancel),
                                    backgroundColor: permissoes.contains(categ["value"])
                                                      ? Colors.green.shade300
                                                      : Colors.grey.shade300,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    
                                  ),
                                ),
                            ]
                          ),
                          SizedBox(height: 25),  
                          DividerDefault(title: getText('funcionario_infos_extra')),
                          SizedBox(height: 15),
                          TextFieldDefault(title: getText('funcionario_infos_extra_1'), controller: txtExtra1, keyboard: TextInputType.multiline),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('funcionario_infos_extra_2'), controller: txtExtra2, keyboard: TextInputType.multiline),
                          SizedBox(height: 15),  
                          DividerDefault(title: getText('funcionario_infos_acesso')),
                          SizedBox(height: 15),  
                          TextFieldDefault(title: getText('funcionario_senha'), isPassword: true, controller: txtPassword),
                          SizedBox(height: 10),                                         
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

class FuncionarioModel{
  int? id;
  String? nome;
  String? documento;
  String? email;
  String? telefone;
  String? funcao;
  String? ch;
  String? matricula;
  String? senha;
  String? photo;
  String? extra1;
  String? extra2;
  List<String>? permissoes;

  FuncionarioModel({
    this.id,
    this.nome,
    this.documento,
    this.email,
    this.telefone,
    this.funcao,
    this.ch,
    this.senha,
    this.photo,
    this.permissoes,
    this.extra1,
    this.extra2
  });

  Map toJson() => {
    'id': id,
    'nome': nome,
    'documento': documento,
    'email': email,
    'telefone': telefone,
    'funcao': funcao,
    'ch': ch,
    'senha': senha,
    'photo': photo,
    'permissoes': permissoes,
    'extra1': extra1,
    'extra2': extra2
  };
}
