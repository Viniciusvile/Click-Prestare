
import 'dart:io';

import 'package:click/controllers/controller_condominio.dart';
import 'package:click/pages/sindico/signup/signup_%20condominium_1.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_signup_success.dart';
import 'package:click/widgets/buttons/default_button_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
// import 'package:flutter/widgets.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';

class SignupCondominuim3 extends StatefulWidget {
  const SignupCondominuim3({Key? key, required this.condominio}) : super(key: key);
  final CondominioRegister condominio;

  @override
  _SignupCondominuim3PageState createState() => _SignupCondominuim3PageState();
}

class _SignupCondominuim3PageState extends State<SignupCondominuim3> {
  final txtBlocos = TextEditingController();
  final txtAptos = TextEditingController();
  var _isLoading = false;

  register() async{
    
    var err = "";
    try{
      var blocos = 0;
      var aptos = 0;

      // if(blocos.isNaN || blocos <= 0){
      //   err += "Número de blocos inválido\n";
      // }
      
      // if(aptos.isNaN || aptos <= 0){
      //   err += "Número de apartamentos inválido\n";
      // }

      if(err.isNotEmpty){
        displayMessage(context, getText('alert_error'), err);
        return;
      }
      
      widget.condominio.blocos = blocos;
      widget.condominio.aptos = aptos;

      _isLoading = true;
      setState(() {});
      var message = await registerCondominio(widget.condominio);
      _isLoading = false;
      setState(() {});
      if(message == ""){
        showDialog(context: context,
          builder: (BuildContext context){
            return CustomDialogBox();
          }
        );
      }else{
        displayMessage(context, getText('alert_error'), message);
      }

    }catch (e){
      displayMessage(context, getText('alert_error'), getText('alert_invalid_value'));
    }
    
  }

  @override
  Widget build(BuildContext context) {

    var _pageSize = MediaQuery.of(context).size.height;

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
                NavigationDefault(title: getText('signup_cond_nav')),
                Flexible(
                    child: SingleChildScrollView(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(25, 20, 25, 20), 
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 110,
                        ),
                        decoration: BoxMainRounded(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(  
                                  backgroundColor: Colors.white,                    
                                  radius: 45,
                                  backgroundImage: 
                                    widget.condominio.photo != null
                                    ? (kIsWeb ? NetworkImage(widget.condominio.photo!) : FileImage(File(widget.condominio.photo!))) as ImageProvider
                                    : const AssetImage('assets/images/business_default.png'),
                                ),
                                SizedBox(width: 15),   
                                LabelTitle(title: widget.condominio.nome!, size:22)
                              ],
                            ),    
                            SizedBox(height: 10),   
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Flexible(
                            //       child: TextFieldDefault(title: "Blocos", keyboard: TextInputType.number, controller: txtBlocos),
                            //     ),
                            //     SizedBox(width: 10),   
                            //     Flexible(
                            //       child: TextFieldDefault(title: "APTOS", keyboard: TextInputType.number, controller: txtAptos),
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(height: 40), 
                            Row(
                              children: [
                                LabelTitle(title: getText('signup_cond_valor_total')),
                                SizedBox(width: 5), 
                                LabelDefault(title: getText('signup_cond_valor_mensal')),
                              ],
                            ),
                            SizedBox(height: 20),                      
                            LabelDefault(title: getText('signup_cond_dias_gratuitos')),
                            SizedBox(height: 20),                  
                            LabelDefault(title: getText('signup_cond_cancele_label')),                   
                            SizedBox(height: 30),
                            LabelTitle(title: "3 ${getText('label_of')} 3", size: 19,),
                            SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.yellow,
                                ),
                                minHeight: 10,
                                value: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            DefaultButtonNormal(title: getText('btn_save'), hasArrow: false,
                              onPressed: () {
                               register();
                              }
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ), 
          ),
          if(_isLoading)
            const SizedBox.expand(
              child: Loader(loadingTxt: '', opacity: 0.7, color: Colors.black, dismissibles: false),
            ),
        ],
      )
    );
  }

}
