
import 'dart:io';
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/buttons/upload_button.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';

class NewDocument extends StatefulWidget {
  const NewDocument({Key? key, required this.is_ata}) : super(key: key);
  final bool is_ata;

  @override
  _NewDocumentPageState createState() => _NewDocumentPageState();
}

class _NewDocumentPageState extends State<NewDocument> {
  List<File> list = [];
  var _isLoading = false;
  final txtTitulo = TextEditingController();

  save() async{
    try{
      var base64 = convertToBase64(list[0], 'application/pdf');
      var doc = DocumentoModel(
        nome: txtTitulo.text, 
        is_ata: widget.is_ata, 
        doc: base64
      );
      changeLoading(true);
      var message = await apiSaveObject('documentos', 'documento', doc, false);

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
                NavigationDefault(title: getText('docs_nav_new')),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          TextFieldDefault(title: getText('docs_title'), controller: txtTitulo),
                          SizedBox(height: 10), 
                          uploadFile(title: getText('docs_upload'), types: ["pdf"], maxDocs:1,
                            onPressed: (listFiles){
                              list = listFiles;
                            },
                          ),
                      ],
                    ),
                  )
                ),   
                Container(
                  padding: EdgeInsets.fromLTRB(10,0,10,10),
                  decoration: BoxDecoration(color: Colors.white),
                  child: SizedBox(
                    height: 50,
                    child: DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                      onPressed: () {
                        save();
                      }
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
      )
    );
  }
}


class DocumentoModel{
  String? nome;
  String? doc;
  bool? is_ata;

  DocumentoModel({
    this.nome,
    this.doc,
    this.is_ata,
  });

  Map toJson() => {
    'nome': nome,
    'doc': doc,
    'is_ata': is_ata,
  };
}

                   
