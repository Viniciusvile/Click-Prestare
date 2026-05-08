
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

import '../../../controllers/controller_moradores.dart';
import '../../../utils/local_storage.dart';
import '../../../widgets/buttons/rounded_button.dart';
import '../../../widgets/cells/cell_morador_apto.dart';
import '../../../widgets/dividers/divider_default.dart';
import '../../../widgets/label/label_title.dart';
import 'new_morador.dart';

class NewApto extends StatefulWidget {
  const NewApto({Key? key, required this.isEdit, this.obj}) : super(key: key);
  final bool isEdit;
  final dynamic obj;

  @override
  _NewAptoPageState createState() => _NewAptoPageState();
}

class _NewAptoPageState extends State<NewApto> {
  var isEdit = false;
  var _isLoading = false;
  var idObj = -1;
  final txtBloco = TextEditingController();
  final txtApto = TextEditingController();
  final txtFracao = TextEditingController();
  var typeSelected = '';
  List<dynamic> listProprietarios = [];
  List<dynamic> listInquilinos = [];

  @override
  void initState(){
    super.initState();
    if(widget.isEdit){
      isEdit = widget.isEdit;
      idObj = widget.obj['id'];
      load();
    }
  }

  load(){
    txtApto.text = widget.obj['apto'];
    txtBloco.text = widget.obj['bloco'];
    txtFracao.text = widget.obj['fracao'];
    loadMoradores();
  }

  loadMoradores() async {
    try{
     changeLoading(true);
      var resProps = await apiGetAllMoradores("Proprietário", idObj.toString());
      var resInqui = await apiGetAllMoradores("Inquilino", idObj.toString());
      listProprietarios = resProps;
      listInquilinos = resInqui;
      changeLoading(false);
    }catch(e){
      changeLoading(false);
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  save() async{
    try{
      changeLoading(true);
      var obj = AptoModel(id: idObj, bloco: txtBloco.text, apto: txtApto.text, fracao: txtFracao.text);
      var res = await apiSaveApto("apartamentos", getText('lb_apartamento'), obj, isEdit);
      displayMessage(context, getText('alert_success'), "Apartamento salvo com sucesso!");
      idObj = res['id'];
      isEdit = true;        
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

  delete() async {
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('apartamentos', idObj);
      changeLoading(false);
      if(res){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  setType(String type){
    typeSelected = type;
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
                NavigationDefault(title: getText('lb_apartamento')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20), 
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 110,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[                          
                          SizedBox(height: 10),
                          if(isEdit == false)
                            LabelDefault(title: getText('apto_desc'), maxLines: 3),
                          if(isEdit == false)
                            SizedBox(height: 30),
                          DividerDefault(title: getText('lb_infos_apto')),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TextFieldDefault(title: getText('lb_bloco'), controller: txtBloco, enabled: getUserType() == 'sindico' || getUserPermission('apartamentos') == 1),
                              ),
                              SizedBox(width: 10),   
                              Flexible(
                                child: TextFieldDefault(title: getText('lb_apartamento'), controller: txtApto, enabled: getUserType() == 'sindico' || getUserPermission('apartamentos') == 1),
                              ),
                            ],
                          ),  
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('apto_fracao'), controller: txtFracao, enabled: getUserType() == 'sindico' || getUserPermission('apartamentos') == 1),
                          SizedBox(height: 10), 
                          if(isEdit == true)
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,                          
                              children: <Widget>[
                                LabelTitle(title: "${getText('apto_proprietarios')} (${listProprietarios.length})", size: 20, color: Theme.of(context).primaryColor,),
                                if(getUserType() == 'sindico' || getUserPermission('apartamentos') == 1)
                                  RoundedButton(
                                    size: 30,
                                    onPressed: () {
                                      Navigator.push(context,MaterialPageRoute(builder: (context) => NewMorador(isEdit: false, apto: txtApto.text, bloco: txtBloco.text, tipo: "Proprietário", id_apto: idObj.toString(),))).then((_) {
                                        loadMoradores();
                                      });
                                    },
                                  )
                              ],
                            ), 
                          if(isEdit == true)
                            for(var item in listProprietarios) 
                              GestureDetector(
                                onTap: (){
                                  if(getUserType() == 'sindico' || getUserPermission('apartamentos') == 1)
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => NewMorador(obj:item, isEdit: true, apto: txtApto.text, bloco: txtBloco.text, tipo: "Proprietário", id_apto: idObj.toString()))).then((_) {
                                      loadMoradores();
                                    });
                                },
                                child: CellMoradorApto(item: item),
                              ),
                          SizedBox(height: 10), 
                          if(isEdit == true)
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                LabelTitle(title: "${getText('apto_inquilinos')} (${listInquilinos.length})", size: 20, color: Theme.of(context).primaryColor,),
                                if(getUserType() == 'sindico' || getUserPermission('apartamentos') == 1)
                                  RoundedButton(
                                    size: 30,
                                    onPressed: () {                                      
                                      Navigator.push(context,MaterialPageRoute(builder: (context) => NewMorador(isEdit: false, apto: txtApto.text, bloco: txtBloco.text, tipo: "Inquilino", id_apto: idObj.toString()))).then((_) {
                                        loadMoradores();
                                      });
                                    },
                                 )
                              ],
                            ), 
                          if(isEdit == true)
                            for(var item in listInquilinos) 
                              GestureDetector(
                                onTap: (){
                                  if(getUserType() == 'sindico' || getUserPermission('apartamentos') == 1)
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => NewMorador(obj:item, isEdit: true, apto: txtApto.text, bloco: txtBloco.text, tipo: "Inquilino", id_apto: idObj.toString()))).then((_) {
                                      load();
                                    });
                                },
                                child: CellMoradorApto(item: item),
                              ),
                        ]
                      ),
                    ),
                  ),
                ),
                if(getUserType() == 'sindico' || getUserPermission('apartamentos') == 1)
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

class AptoModel{
  int? id;
  String? bloco;
  String? apto;
  String? fracao;

  AptoModel({
    this.id,
    this.bloco,
    this.apto,
    this.fracao,
  });

  Map toJson() => {
    'id': id,
    'bloco': bloco,
    'apto': apto,
    'fracao': fracao,
  };
}







                   
