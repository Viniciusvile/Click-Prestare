
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import '../../../controllers/controller_generic.dart';
import '../../../utils/local_storage.dart';
import '../../../utils/utils.dart';
import '../../../widgets/alerts/bottom_sheet_aptos.dart';
import '../../../widgets/alerts/loader.dart';
import '../../../widgets/alerts/modal_cupertino.dart';
import '../../../widgets/buttons/save_button.dart';
import '../../../widgets/dividers/divider_default.dart';
import '../../singleton.dart';
// import 'package:flutter/widgets.dart';

class NewMudanca extends StatefulWidget {
  const NewMudanca({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewMudancaPageState createState() => _NewMudancaPageState();
}

class _NewMudancaPageState extends State<NewMudanca> {
  final txtData = TextEditingController();
  final txtHora = TextEditingController();
  final txtBloco = TextEditingController();
  final txtApto = TextEditingController();

  var _isLoading = false;
  var idMyApartment = null;
  var list = [];
  var listBlocos = [];

  @override
  void initState(){
    super.initState();
    if(widget.isEdit){
      load();
    }
    if(getUserType()=="morador" ){
      txtBloco.text = Singleton.instance.bloco;
      txtApto.text = Singleton.instance.apartamento;
      idMyApartment = Singleton.instance.id_apartamento;
    }else{
      loadListAptos();
    }
  }

  load() async{
    try{
      changeLoading(true);
      var obj = await apiGetDetails("mudancas", widget.myId!);
      txtData.text = obj["data"];
      txtHora.text = obj["hora_inicio"];
      txtApto.text = obj["apto"];
      txtBloco.text = obj["apto_bloco"];
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      changeLoading(false);
    }       
  }

  save() async {
    try{            
      var mudanca = MudancaModel(
        id: widget.myId ?? -1, 
        data: convertStringToDate(txtData.text),
        hora_inicio: txtHora.text,
        id_apartamento: idMyApartment ?? getIdApto(),
      );
      changeLoading(true);
      var message = await apiSaveObject('mudancas', 'mudanca', mudanca,  widget.isEdit);

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

  delete() async {
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('mudancas', widget.myId!);
      changeLoading(false);
      if(res){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  loadListAptos() async{
    try{
      changeLoading(true);
      var aptos = await apiGetAll("condominio/aptos");
      list = aptos;
      listBlocos.clear();
      for(var item in list){
        if(!listBlocos.contains(item['bloco'])){
          listBlocos.add(item['bloco']);
        }
      }
      
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
      changeLoading(false);
    }
  }

  getListAptos(){
    var listAptos = [];
    for (var item in list){
      if (item['bloco'] == txtBloco.text && !list.contains(item["apto"])){
        listAptos.add(item["apto"]);
      }
    }
    return listAptos;
  }

  getIdApto(){
    for(var item in list){
      if(item['bloco'] == txtBloco.text && item["apto"] == txtApto.text){
        return item["id"];
      }
    }
    throw(getText('mudanca_selecione_apto'));
  }

  changeLoading(bool value){
    _isLoading = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(  
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),           
            ),    
            child: Column(
              children: [
                NavigationDefault(title: widget.isEdit ? getText('mudanca_nav_edit') : getText('mudanca_nav_new')),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DividerDefault(title: getText('mudanca_infos_mudanca')),
                        InkWell(
                           onTap: (){
                              showCupertinoModalPopup(context: context,
                                builder: (BuildContext context){
                                  return ModalCupertino(
                                    onPressed: (text) { setState(() { txtData.text = text; });  
                                  }, initialDate: DateTime.now(), type: 'date',);
                                }
                              );
                            },
                          child: TextFieldDefault(title: getText('data_hora_inicio'), controller: txtData, placeholder: "dd/mm/aaaa", enabled: false,)
                        ),
                        SizedBox(height: 10), 
                        InkWell(
                          onTap: (){
                              showCupertinoModalPopup(context: context,
                                builder: (BuildContext context){
                                  return ModalCupertino(
                                    onPressed: (text) { setState(() { txtHora.text = text; });  
                                  }, initialDate: null, type: 'time',);
                                }
                              );
                            },
                          child: TextFieldDefault(title: getText('hora_inicio'), controller: txtHora, placeholder: "hh:mm", enabled: false)
                        ),
                        SizedBox(height: 10), 
                        DividerDefault(title: getText('lb_infos_apto')),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: (){ 
                                    if(getUserType()=="morador"){return;}
                                    if(listBlocos.isEmpty){
                                      return displayMessage(context, getText('alert_ops'), getText('alert_nenhum_bloco'));
                                    }
                                    bottomSheetAptos(context, listBlocos, txtBloco.text, (blocoSelected){
                                      if(txtBloco.text != blocoSelected){
                                        txtApto.text = "";
                                      }
                                      txtBloco.text = blocoSelected;                                   
                                      Navigator.of(context).pop();
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    });
                                  },
                                  child: TextFieldDefault(title: getText('lb_bloco'), controller: txtBloco, enabled: false)
                                ),
                              ),
                              SizedBox(width: 10),   
                              Flexible(
                                child: InkWell(
                                  onTap: (){ 
                                    if(getUserType()=="morador"){return;}
                                    if(getListAptos().isEmpty){
                                      return displayMessage(context, getText('alert_ops'), getText('visitante_erro_bloco'));
                                    }
                                    bottomSheetAptos(context, getListAptos(), txtApto.text, (aptoSelected){
                                      txtApto.text = aptoSelected;
                                      Navigator.of(context).pop();
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    });
                                    },
                                  child: TextFieldDefault(title: getText('lb_apartamento'), controller: txtApto, enabled: false)
                                ),
                              ),
                            ],
                          ),
                        ),
                        // checkbox_default(title: "Li e concordo com as normas",),                                     
                      ],
                    ),
                  )
                ),
                SaveButton(isEdit: widget.isEdit, 
                  onPressedDelete:  (){delete();} , 
                  onPressedSave:  (){save();} 
                ),
              ],
            ), 
          )
        ),
        if(_isLoading)
          Container(
            height: 1000,
            width: 1000,
            child: const Loader(loadingTxt: '', opacity: 0.7, color: Colors.black, dismissibles: false)
          ) 
      ],
    );
  }
}


class MudancaModel{
  int? id;
  String? data;
  String? hora_inicio;
  int? id_apartamento;

  MudancaModel({
    this.id,
    this.data,
    this.hora_inicio,
    this.id_apartamento,
  });

  Map toJson() => {
    'id': id,
    'data': data,
    'hora_inicio': hora_inicio,
    'id_apartamento': id_apartamento,
  };
}



                   
