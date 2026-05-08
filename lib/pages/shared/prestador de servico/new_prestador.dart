
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/save_button.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import '../../../widgets/dividers/divider_default.dart';

class NewPrestador extends StatefulWidget {
  const NewPrestador({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewPrestadorPageState createState() => _NewPrestadorPageState();
}

class _NewPrestadorPageState extends State<NewPrestador> {

  var _isLoading = false;
  final txtNome = TextEditingController();
  final txtTelefone = TextEditingController();
  final txtOutrasCategorias = TextEditingController();
  var categorias = [];
  var opcoesCategorias = [{
                            "display": getText('prestador_eletricista'),
                            "value": "Eletricista",
                          },
                          {
                            "display": getText('prestador_hidraulica'),
                            "value": "Hidraulica",
                          },
                          {
                            "display": getText('prestador_pintor'),
                            "value": "Pintor",
                          },
                          {
                            "display": getText('prestador_pedreiro'),
                            "value": "Pedreiro",
                          },
                          {
                            "display": getText('prestador_limpeza'),
                            "value": "Limpeza",
                          },
                          {
                            "display":getText('prestador_dedetizacao'),
                            "value": "Dedetizacao",
                          }
                        ];


  @override
  void initState(){
      super.initState();     
      if(widget.isEdit){
        load();
      }else{
        categorias = [];
      }
  }

  load() async{
    changeLoading(true);
    var obj = await apiGetDetails("prestadores", widget.myId!);
    txtNome.text = obj["nome"];
    txtTelefone.text = obj["telefone"];
    categorias = obj["categorias"].split(",");    
    changeLoading(false);
    if(obj == null){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  save() async{
    try{
      if(txtOutrasCategorias.text.isNotEmpty){
        categorias.add(txtOutrasCategorias.text);
      }      
      List<String> categsToAdd = [...categorias];
      categsToAdd.remove('');
      var obj = PrestadorModel(id: widget.myId ?? -1, nome: txtNome.text, telefone: txtTelefone.text, categorias: categsToAdd);
      changeLoading(true);
      var res = await apiSaveObject("prestadores", "prestador", obj, widget.isEdit);      
      if(res.toString().isEmpty){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), res.toString());
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
      var res = await apiDeleteObject('prestadores', widget.myId!);
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
                NavigationDefault(title: widget.isEdit ? getText('prestador_nav_edit') : getText('prestador_nav_new')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            DividerDefault(title: getText('prestador_infos')),
                            TextFieldDefault(title: getText('user_nome_completo'), controller: txtNome),
                            SizedBox(height: 10), 
                            TextFieldDefault(title: getText('telefone'), controller: txtTelefone, placeholder:'+5511998765432', keyboard: TextInputType.number,),
                            SizedBox(height: 10), 
                            DividerDefault(title: getText('prestador_funcoes')),
                            LabelDefault(title: getText('prestador_selecione_categoria'), size: 13, color: Colors.grey.shade600),
                            SizedBox(height: 10), 
                            Wrap(
                              spacing: 8.0, 
                              runSpacing: 4.0, 
                              children: [
                                for(var categ in opcoesCategorias)
                                  InkWell(
                                    onTap: (){
                                      if(categorias.contains(categ["display"])){
                                        categorias.remove(categ["display"]);
                                      }else{
                                        categorias.add(categ["display"]);
                                      }
                                      setState(() {});
                                    },
                                    child: Chip(   
                                      label: LabelDefault(title: categ["display"]!, size: 11, 
                                                        color: categorias.contains(categ["display"])
                                                          ? Colors.white
                                                          : Colors.black),
                                      deleteIcon: Icon(Icons.cancel),
                                      backgroundColor: categorias.contains(categ["display"])
                                                        ? Colors.green.shade300
                                                        : Colors.grey.shade300,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      
                                    ),
                                  ),
                              ]
                            ),
                            TextFieldDefault(title: getText('prestador_categoria_desc'), controller: txtOutrasCategorias),                                                        
                            SizedBox(height: 15),                           
                        ],
                      ),
                    ),
                  )
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


class PrestadorModel{
  int? id;
  String? nome;
  String? telefone;
  List<String>? categorias;

  PrestadorModel({
    this.id,
    this.nome,
    this.telefone,
    this.categorias,
  });

  Map toJson() => {
    'id': id,
    'nome': nome,
    'telefone': telefone,
    'categorias': categorias,
  };
}


                   
