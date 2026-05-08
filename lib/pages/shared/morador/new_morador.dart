
import 'dart:convert';
import 'dart:io';

import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_cupertino.dart';
import 'package:click/widgets/buttons/save_button.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../widgets/dividers/divider_default.dart';
// import 'package:flutter/widgets.dart';

class NewMorador extends StatefulWidget {
  const NewMorador({Key? key, required this.isEdit, this.obj, required this.apto, required this.bloco, required this.tipo, required this.id_apto}) : super(key: key);
  final bool isEdit;
  final dynamic obj;
  final String apto;
  final String bloco;
  final String tipo;
  final String id_apto;

  @override
  _NewMoradorPageState createState() => _NewMoradorPageState();
}

class _NewMoradorPageState extends State<NewMorador> {
  var _isLoading = false;
  final txtNome = TextEditingController();
  final txtDocumento = TextEditingController();
  final txtDN = TextEditingController();
  final txtEmail = TextEditingController();
  final txtTelefone = TextEditingController();
  final txtBloco = TextEditingController();
  final txtApto = TextEditingController();
  final txtExtra1 = TextEditingController();
  final txtExtra2 = TextEditingController();
  final txtExtra3 = TextEditingController();
  final txtExtra4 = TextEditingController();
  File? imageFile;
  var imageChanged = false;

  var typeSelected = '';
  var myId = -1;

  @override
  void initState(){
    super.initState();
    txtBloco.text = widget.bloco;
    txtApto.text = widget.apto;
    if(widget.isEdit){
      load();
    }
  }

  load() async{
    txtNome.text = widget.obj["nome"];
    txtDocumento.text = widget.obj["documento"];
    txtEmail.text = widget.obj["email"];
    txtDN.text = convertDateToString(widget.obj["data_nascimento"]);
    txtTelefone.text = widget.obj["telefone"];   
    txtExtra1.text = widget.obj["extra1"] ?? '';   
    txtExtra2.text = widget.obj["extra2"] ?? '';   
    txtExtra3.text = widget.obj["extra3"] ?? '';   
    txtExtra4.text = widget.obj["extra4"] ?? '';   
    myId =  widget.obj["id"];   
    imageFile = await fileFromImageUrl(widget.obj['photo'] ?? '');
    setState(() {});
  }

  save() async{
    try{
      var base64 = null;
      if(imageFile != null && imageChanged == true){
        List<int> imageBytes = imageFile!.readAsBytesSync();
        base64 = "data:image/png;base64,"+base64Encode(imageBytes);
      }

      var morador = MoradorModel(id: myId, nome: txtNome.text, documento: txtDocumento.text,
                email: txtEmail.text, telefone: txtTelefone.text, tipo: widget.tipo, data_nascimento: txtDN.text, 
                id_apto: widget.id_apto, extra1: txtExtra1.text, extra2: txtExtra2.text, extra3: txtExtra3.text, extra4: txtExtra4.text, photo: base64);
      var res = await apiSaveObject("moradores", "morador", morador, widget.isEdit);      

      if(res.toString().isEmpty){
        if(!widget.isEdit){
          await displayMessage(context, getText('alert_success'), getText('apto_usuario_criado_msg'));
        }
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), res.toString());
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), e.toString());
    }
  }

  delete() async {
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('moradores', widget.obj['id']);
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

  setType(String type){
    typeSelected = type;
    setState(() {});
  }

  void selectCamera()async {
    var res = await getPhoto(context);
    imageFile = File(res.path);
    imageChanged = true;
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
                NavigationDefault(title: widget.tipo),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                    width: MediaQuery.of(context).size.width,
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 110,
                    ),
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: (){selectCamera();},
                                child: Stack(
                                  children: [
                                    CircleAvatar(                      
                                      radius: 55,
                                      backgroundImage: imageFile == null
                                        ? const AssetImage('assets/images/defaultUser.png')
                                        : (kIsWeb ? NetworkImage(imageFile!.path) : FileImage(File(imageFile!.path))) as ImageProvider,
                                    ),
                                    Container(
                                      padding: EdgeInsets.fromLTRB(80, 80, 0, 0),
                                      child: Icon(MdiIcons.camera, color: Theme.of(context).primaryColor),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15), 
                          DividerDefault(title: getText('lb_infos_apto')),
                          SizedBox(height: 15), 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TextFieldDefault(title: getText('lb_bloco'), controller: txtBloco, enabled: false),
                              ),
                              SizedBox(width: 10),   
                              Flexible(
                                child: TextFieldDefault(title: getText('lb_apartamento'), controller: txtApto, enabled: false),
                              ),
                            ],
                          ),    
                          SizedBox(height: 25),  
                          DividerDefault(title: getText('funcionario_infos_pessoais')),
                          SizedBox(height: 15),                           
                          TextFieldDefault(title: getText('user_nome_completo'), controller: txtNome),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('user_documento'), controller: txtDocumento, mask: FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),),
                          SizedBox(height: 10), 
                          InkWell(
                            onTap: (){
                              showCupertinoModalPopup(context: context,
                                builder: (BuildContext context){
                                  return ModalCupertino(
                                    onPressed: (text) { setState(() { txtDN.text = text; });  
                                  }, initialDate: null, type: 'date',);
                                }
                              );
                            },
                            child: TextFieldDefault(title: getText('data_nascimento'), controller: txtDN, enabled: false)
                          ),
                          SizedBox(height: 25),  
                          DividerDefault(title: getText('signup_infos_contato')),
                          SizedBox(height: 15), 
                          TextFieldDefault(title: getText('email'), controller: txtEmail),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('telefone'), controller: txtTelefone),
                          SizedBox(height: 10), 
                          SizedBox(height: 25),  
                          DividerDefault(title: getText('funcionario_infos_extra')),
                          SizedBox(height: 15),
                          TextFieldDefault(title: getText('funcionario_infos_extra_1'), controller: txtExtra1, keyboard: TextInputType.multiline),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('funcionario_infos_extra_2'), controller: txtExtra2, keyboard: TextInputType.multiline),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('funcionario_infos_extra_3'), controller: txtExtra3, keyboard: TextInputType.multiline),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('funcionario_infos_extra_4'), controller: txtExtra4, keyboard: TextInputType.multiline),
                          SizedBox(height: 10),                                                                     
                        ]
                      ),
                    ),
                  ),
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

class MoradorModel{
  int? id;
  String? nome;
  String? documento;
  String? data_nascimento;
  String? email;
  String? telefone;
  String? tipo;
  String? id_apto;
  String? extra1;
  String? extra2;
  String? extra3;
  String? extra4;
  String? photo;

  MoradorModel({
    this.id,
    this.nome,
    this.documento,
    this.data_nascimento,
    this.email,
    this.telefone,
    this.tipo,
    this.id_apto,
    this.extra1,
    this.extra2,
    this.extra3,
    this.extra4,
    this.photo
  });

  Map toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'data_nascimento': data_nascimento,
    'documento': documento,
    'telefone': telefone,
    'tipo': tipo,
    'id_apto': id_apto,
    'extra1': extra1,
    'extra2': extra2,
    'extra3': extra3,
    'extra4': extra4,
    'photo': photo
  };
}





                   
