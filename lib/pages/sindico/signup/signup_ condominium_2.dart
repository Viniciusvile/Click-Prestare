
import 'dart:io';

import 'package:click/pages/sindico/signup/signup_%20condominium_1.dart';
import 'package:click/pages/sindico/signup/signup_%20condominium_3.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/buttons/default_button_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class SignupCondominuim2 extends StatefulWidget {
  const SignupCondominuim2({Key? key, required this.condominio}) : super(key: key);
  final CondominioRegister condominio;

  @override
  _SignupCondominuim2PageState createState() => _SignupCondominuim2PageState();
  
}

class _SignupCondominuim2PageState extends State<SignupCondominuim2> {
  final txtCep = TextEditingController();
  final txtPais = TextEditingController();
  final txtUF = TextEditingController();
  final txtCidade = TextEditingController();
  final txtBairro = TextEditingController();
  final txtRua = TextEditingController();
  final txtNumero = TextEditingController();
  final txtComplemento = TextEditingController();

  nextPage(){
    var err = "";
    err += validateFieldIsEmpty(txtCep.value.text, getText('signup_cond_error_cep'));
    err += validateFieldIsEmpty(txtPais.value.text, getText('signup_cond_error_pais'));
    err += validateFieldIsEmpty(txtUF.value.text, getText('signup_cond_error_estado'));
    err += validateFieldIsEmpty(txtCidade.value.text, getText('signup_cond_error_estado'));
    err += validateFieldIsEmpty(txtBairro.value.text, getText('signup_cond_error_bairro'));
    err += validateFieldIsEmpty(txtRua.value.text, getText('signup_cond_error_rua'));
    err += validateFieldIsEmpty(txtNumero.value.text, getText('signup_cond_error_numero'));

    widget.condominio.cep = txtCep.value.text;
    widget.condominio.pais = txtPais.value.text;
    widget.condominio.uf = txtUF.value.text;
    widget.condominio.cidade = txtCidade.value.text;
    widget.condominio.bairro = txtBairro.value.text;
    widget.condominio.rua = txtRua.value.text;
    widget.condominio.numero = txtNumero.value.text;
    widget.condominio.complemento = txtComplemento.value.text;

    if(err.isNotEmpty){
      displayMessage(context, getText('alert_error'), err);
      return;
    }
    
    Navigator.push(context,MaterialPageRoute(builder: (context) => SignupCondominuim3(condominio: widget.condominio)),);
  }

  @override
  Widget build(BuildContext context) {

    var _pageSize = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(  
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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          LabelTitle(title: widget.condominio.nome! , size:22)
                        ],
                      ),    
                      SizedBox(height: 10),                     
                      TextFieldDefault(title: getText('signup_cond_cep'), keyboard: TextInputType.number, controller: txtCep),
                      SizedBox(height: 10),   
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: TextFieldDefault(title: getText('signup_cond_pais'), controller: txtPais, textCapitalization: TextCapitalization.characters,),
                          ),
                          SizedBox(width: 10),   
                          Flexible(
                            child: TextFieldDefault(title: getText('signup_cond_uf'), controller: txtUF, textCapitalization: TextCapitalization.characters),
                          ),
                        ],
                      ),
                      TextFieldDefault(title: getText('signup_cond_cidade'), controller: txtCidade, textCapitalization: TextCapitalization.words),
                      SizedBox(height: 10),  
                      TextFieldDefault(title: getText('signup_cond_bairro'), controller: txtBairro, textCapitalization: TextCapitalization.words),
                      SizedBox(height: 10),   
                      TextFieldDefault(title: getText('signup_cond_rua'), controller: txtRua, textCapitalization: TextCapitalization.words),
                      SizedBox(height: 10),   
                      TextFieldDefault(title: getText('signup_cond_numero'), keyboard: TextInputType.number, controller: txtNumero),
                      SizedBox(height: 10),   
                      TextFieldDefault(title: getText('signup_cond_complemento'), controller: txtComplemento),
                      SizedBox(height: 20),
                      LabelTitle(title: "2 ${getText('label_of')} 3", size: 19,),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.yellow,
                          ),
                          minHeight: 10,
                          value: 0.66,
                        ),
                      ),
                      SizedBox(height: 10),
                      DefaultButtonNormal(title: getText('btn_proximo'), hasArrow: false,
                        onPressed: () {
                          nextPage();
                        }
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              )
            ),
          ],
        ), 
      )
    );
  }
}
