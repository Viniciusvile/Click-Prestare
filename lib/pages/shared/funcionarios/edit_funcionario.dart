
import 'dart:convert';
import 'dart:io';

import 'package:click/controllers/controller_funcionario.dart';
import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/funcionarios/new_funcionario_1.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EditFuncionario extends StatefulWidget {
  const EditFuncionario({Key? key}) : super(key: key);

  @override
  _EditFuncionarioPageState createState() => _EditFuncionarioPageState();
}

class _EditFuncionarioPageState extends State<EditFuncionario> {
  var _isLoading = false;
  final txtNome = TextEditingController();
  final txtDocumento = TextEditingController();
  final txtEmail = TextEditingController();
  final txtTelefone = TextEditingController();

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
      var obj = await apiGetDetails("funcionarios", 0); 
      myId = obj["id"] ?? -1;
      txtNome.text = obj["nome"] ?? "";
      txtDocumento.text = obj["documento"] ?? "";
      txtEmail.text = obj["email"] ?? "";
      txtTelefone.text = obj["telefone"] ?? "";   
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

      var funcionario = FuncionarioModel(id: myId, nome: txtNome.text, documento: txtDocumento.text, 
                      email: txtEmail.text, telefone: txtTelefone.text, photo: base64
                    );

      var res = await updateFuncionarioApi(funcionario);

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
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 110,
                    ),
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
                                      : (kIsWeb ? NetworkImage(imageFile!.path) : FileImage(File(imageFile!.path))) as ImageProvider,
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
                          TextFieldDefault(title: getText('user_nome_completo'), controller: txtNome),
                          SizedBox(height: 10),   
                          TextFieldDefault(title: getText('user_documento'), controller: txtDocumento),
                          SizedBox(height: 10),   
                          TextFieldDefault(title: getText('email'), controller: txtEmail),
                          SizedBox(height: 10),   
                          TextFieldDefault(title: getText('telefone'), keyboard: TextInputType.number, controller: txtTelefone),
                          SizedBox(height: 15),    
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
      ),
    );
  }
}





                   
