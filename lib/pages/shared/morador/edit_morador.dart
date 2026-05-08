
import 'dart:convert';
import 'dart:io';

import 'package:click/controllers/controller_generic.dart';
import 'package:click/controllers/controller_moradores.dart';
import 'package:click/pages/shared/morador/new_morador.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_cupertino.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../widgets/dividers/divider_default.dart';

class EditMorador extends StatefulWidget {
  const EditMorador({Key? key}) : super(key: key);

  @override
  _EditMoradorPageState createState() => _EditMoradorPageState();
}

class _EditMoradorPageState extends State<EditMorador> {
  var _isLoading = false;
  final txtNome = TextEditingController();
  final txtDocumento = TextEditingController();
  final txtDN = TextEditingController();
  final txtEmail = TextEditingController();
  final txtTelefone = TextEditingController();
  final txtExtra1 = TextEditingController();
  final txtExtra2 = TextEditingController();
  final txtExtra3 = TextEditingController();
  final txtExtra4 = TextEditingController();

  File? imageFile;
  var changed = false;

  var typeSelected = '';
  var myId = -1;

  @override
  void initState(){
    super.initState();
    load();
  }

  load() async{
    try{
      changeLoading(true);
      var obj = await apiGetDetails("moradores", 0); 
      myId = obj["id"] ?? -1;
      txtNome.text = obj["nome"] ?? "";
      txtDocumento.text = obj["documento"] ?? "";
      txtEmail.text = obj["email"] ?? "";
      txtDN.text = obj["data_nascimento"] ?? "";
      txtTelefone.text = obj["telefone"] ?? "";   
      txtExtra1.text = obj["extra1"] ?? '';   
      txtExtra2.text = obj["extra2"] ?? '';   
      txtExtra3.text = obj["extra3"] ?? '';   
      txtExtra4.text = obj["extra4"] ?? '';    
      imageFile = await fileFromImageUrl(obj['photo'] ?? '');
      setState(() {});
    }catch(e){
      await displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      changeLoading(false);
    }    
  }

  save() async{
    try{
      changeLoading(true);
      
      var base64 = null;
      if(imageFile != null && changed == true){
        List<int> imageBytes = imageFile!.readAsBytesSync();
        base64 = "data:image/png;base64,"+base64Encode(imageBytes);
      }

      var morador = MoradorModel(id: myId, nome: txtNome.text, documento: txtDocumento.text, data_nascimento: txtDN.text, 
                email: txtEmail.text, telefone: txtTelefone.text, 
                extra1: txtExtra1.text, extra2: txtExtra2.text, extra3: txtExtra3.text, extra4: txtExtra4.text,
                photo: base64
              );

      var res = await updateMoradorApi(morador);

      if(res.toString().isEmpty){
        await displayMessage(context, getText('alert_success'), getText('alert_dados_alterados'));
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), res.toString());
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), e.toString());
    } finally {
      changeLoading(false);
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
    changed = true;
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
                NavigationDefault(title: getText('editar_infos')),
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
                          DividerDefault(title: getText('funcionario_infos_pessoais')),
                          SizedBox(height: 15), 
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
                          TextFieldDefault(title: getText('user_nome_completo'), controller: txtNome),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('user_documento'), controller: txtDocumento),
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
                          DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                            onPressed: () {
                              save();
                            }
                          ),
                          SizedBox(height: 10),                                         
                        ]
                      ),
                    ),
                  ),
                ),
              ],
            ), 
          ),
          if(_isLoading)
            const Loader(loadingTxt: '', opacity: 0.7, color: Colors.black, dismissibles: false)
        ],
      )
    );
  }
}





                   
