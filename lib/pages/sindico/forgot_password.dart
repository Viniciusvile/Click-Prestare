
import 'package:click/controllers/controller_sindico.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/textfields/textfield_rounded.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';

class ForgotPassword extends StatefulWidget {
  final loginType;
  const ForgotPassword({Key? key, required this.loginType}) : super(key: key);

  @override
  _ForgotPasswordSindicoPageState createState() => _ForgotPasswordSindicoPageState();
}

class _ForgotPasswordSindicoPageState extends State<ForgotPassword> {
  final txtEmail = TextEditingController();
  var _isLoading = false;
  String loginType = "";

  @override
  void initState() {
    super.initState();
    if(widget.loginType == "sindico"){ loginType="sindico"; }
    if(widget.loginType == "morador"){ loginType="moradores"; }
    if(widget.loginType == "funcionario"){ loginType="funcionarios"; }
  }

  recovery() async {
    try{
      changeLoading(true);
      var msg = await passRecoveryApi(txtEmail.text, loginType);
      await displayMessage(context, getText('alert_success'), msg);  
      Navigator.pop(context);    
    }catch(e){
      displayMessage(context, getText('alert'), e.toString());
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
                NavigationDefault(title: getText('esqueci_senha_nav')),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        LabelTitle(title: getText('esqueci_senha_title'), size: 20),
                        SizedBox(height: 20),
                        LabelDefault(title: getText('esqueci_senha_description'), maxLines: 5,),
                        SizedBox(height: 50),
                        TextFieldRounded(title: getText('email'), isPassword: false, controller: txtEmail,),
                        SizedBox(height: 40),                     
                        DefaultButton(title: getText('btn_enviar'), hasArrow: false,                   
                          onPressed: () {
                            recovery();
                          }
                        ),
                      ],
                    ),
                  )
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
