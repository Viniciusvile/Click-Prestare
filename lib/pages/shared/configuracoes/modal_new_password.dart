import 'package:click/controllers/controller_funcionario.dart';
import 'package:click/controllers/controller_moradores.dart';
import 'package:click/controllers/controller_sindico.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ModalNewPassword extends StatefulWidget {

  const ModalNewPassword({Key? key}) : super(key: key);

  @override
  _ModalNewPasswordState createState() => _ModalNewPasswordState();
}

class _ModalNewPasswordState extends State<ModalNewPassword> {
  final txtNewPassword = TextEditingController();
  final txtConfirmPassword = TextEditingController();

  var _isLoading = false;

  @override
  void initState(){
    super.initState();
    initializeDateFormatting();
  }

  save() async {
    try{
      changeLoading(true);   
      if(txtNewPassword.text != txtNewPassword.text){
        throw(getText('senhas_nao_conferem'));
      } 
      if(txtNewPassword.text.length < 6){
        throw(getText('senha_minimo_caracteres'));
      } 
      if(getUserType() == "sindico"){
        updatePasswordSindicoApi(txtNewPassword.text);
      } 
      if(getUserType() == "morador"){
        updatePasswordMoradorApi(txtNewPassword.text);
      } 
      if(getUserType() == "funcionario"){
        updatePasswordFuncionarioApi(txtNewPassword.text);
      }  
      await displayMessage(context, getText('alert_success'), getText('config_alt_senha_sucesso'));
      Navigator.pop(context);
    }catch(e){
      displayMessage(context, getText('alert_error'), e.toString());
    }finally{
      changeLoading(false);
    }  
  }
    
  changeLoading(bool value){
    _isLoading = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context){
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(30,10,30,20),
          height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black,offset: Offset(0,5),
                blurRadius: 15
                ),
              ]
            ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: (){ Navigator.pop(context); }, 
                    child: Container(
                      padding: const EdgeInsets.all(0.0),
                      width: 0,
                      child: Icon(                    
                        MdiIcons.close, 
                        color: Colors.black,                    
                      ),
                    )
                  ),
                ],
              ),
              TextFieldDefault(title: getText('config_nova_senha'), controller: txtNewPassword, isPassword: true,),
              const SizedBox(height: 10),
              TextFieldDefault(title: getText('config_confirm_nova_senha'), controller: txtConfirmPassword, isPassword: true,),
              const SizedBox(height: 15),
              DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                onPressed: () {
                  save();
                }
              ),
            ],
          )
        ),
        if(_isLoading)
          Loader(loadingTxt: '', opacity: 0, color: Colors.black, dismissibles: false)  
      ],
    );
  }
}
