
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_cupertino.dart';
import 'package:click/widgets/buttons/save_button.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';

import '../../../widgets/dividers/divider_default.dart';

class NewVotacao extends StatefulWidget {
  const NewVotacao({Key? key, this.idAssembleia, required this.isEnquete}) : super(key: key);
  final int? idAssembleia;
  final bool? isEnquete;

  @override
  _NewVotacaoPageState createState() => _NewVotacaoPageState();
}

class _NewVotacaoPageState extends State<NewVotacao> {
  var _isLoading = false;

  final txtNome = TextEditingController();
  final txtDescricao = TextEditingController();
  final txtDataInicio = TextEditingController();
  final txtDataTermino = TextEditingController();
  final txtOpcao1 = TextEditingController();
  final txtOpcao2 = TextEditingController();
  final txtOpcao3 = TextEditingController();
  final txtOpcao4 = TextEditingController();

  save() async{
    // return;
    try{
      changeLoading(true);
      List<String> ops = [];
      if(txtOpcao1.text.isNotEmpty){ops.add(txtOpcao1.text);};
      if(txtOpcao2.text.isNotEmpty){ops.add(txtOpcao2.text);};
      if(txtOpcao3.text.isNotEmpty){ops.add(txtOpcao3.text);};
      if(txtOpcao4.text.isNotEmpty){ops.add(txtOpcao4.text);};
        
      var obj = VotacaoModel(
        titulo: txtNome.text, 
        descricao: txtDescricao.text,
        data_inicio: convertStringToDate(txtDataInicio.text), 
        data_termino: convertStringToDate(txtDataTermino.text), 
        id_assembleia: widget.idAssembleia ?? 0,
        is_enquete: widget.isEnquete,
        opcoes: ops
      );

      if(ops.isEmpty){
        throw(getText('votacao_signup_informe_opcoes'));
      }

      var res = await apiSaveObject("assembleias/votacoes", "votacao", obj, false);
      changeLoading(false);
      if(res.toString().isEmpty){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), res.toString());
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), e.toString());
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(  
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),           
            ),    
            child: Column(
              children: [
                NavigationDefault(title: getText('votacao_signup_nav')),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            DividerDefault(title: getText('votacao_signup_infos')),
                            TextFieldDefault(title: getText('lb_titulo'), controller: txtNome),
                            SizedBox(height: 20), 
                            if(widget.isEnquete == true)
                              TextFieldDefault(title: getText('lb_descricao'), controller: txtDescricao),
                            if(widget.isEnquete == true)  
                              SizedBox(height: 20), 
                            
                            InkWell(
                               onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtDataInicio.text = text; });  
                                    }, initialDate: DateTime.now(), type: 'date',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('data_inicio'), placeholder: "dd/mm/aaaa", controller: txtDataInicio, enabled: false)
                            ),
                            SizedBox(height: 20),                             
                            InkWell(
                              onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtDataTermino.text = text; });  
                                    }, initialDate: convertStringToDateFormat(txtDataInicio.text) ?? DateTime.now(), type: 'date',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('votacao_signup_dt_encerramento'), placeholder: "dd/mm/aaaa", controller: txtDataTermino, enabled: false)
                            ),
                            SizedBox(height: 10), 
                            DividerDefault(title: getText('votacao_opcoes')),
                            TextFieldDefault(title: "${getText('votacao_opcao')} 1", controller: txtOpcao1),
                            SizedBox(height: 5), 
                            TextFieldDefault(title: "${getText('votacao_opcao')} 2", controller: txtOpcao2),
                            SizedBox(height: 5), 
                            TextFieldDefault(title: "${getText('votacao_opcao')} 3", controller: txtOpcao3),
                            SizedBox(height: 5), 
                            TextFieldDefault(title: "${getText('votacao_opcao')} 4", controller: txtOpcao4),
                            SizedBox(height: 5), 
                        ],
                      ),
                    ),
                  )
                ),
                SaveButton(isEdit: false, 
                  onPressedDelete:  (){} , 
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

class VotacaoModel{
  String? titulo;
  String? descricao;
  String? data_inicio;
  String? hora_inicio;
  String? data_termino;
  String? hora_termino;
  bool? is_enquete;
  int? id_assembleia;
  List<String>? opcoes;

  VotacaoModel({
    this.titulo,
    this.descricao,
    this.data_inicio,
    this.hora_inicio,
    this.data_termino,
    this.hora_termino,
    this.is_enquete,
    this.id_assembleia,
    this.opcoes,
  });

  Map toJson() => {
    'titulo': titulo,
    'descricao': descricao,
    'data_inicio': data_inicio,
    'hora_inicio': hora_inicio,
    'data_termino': data_termino,
    'hora_termino': hora_termino,
    'is_enquete': is_enquete,
    'id_assembleia': id_assembleia,
    'opcoes': opcoes,
  };
}


                   
