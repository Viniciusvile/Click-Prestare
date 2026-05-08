import 'dart:io';
import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/ocorrencias/new_ocorrencia.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/checkbox/checkbox_filled.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../widgets/dividers/divider_default.dart';
// import 'package:flutter/widgets.dart';

class DetailOcorrencia extends StatefulWidget {
  const DetailOcorrencia({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _DetailOcorrenciaPageState createState() => _DetailOcorrenciaPageState();
}

class _DetailOcorrenciaPageState extends State<DetailOcorrencia> {
  var _isLoading = false;
  final txtResposta = TextEditingController();
  late dynamic obj = null;
  List<File> list = [];
  var currentStatus='';

  @override
  void initState(){
      super.initState();
      load();
  }

  load() async{
    changeLoading(true);
    obj = await apiGetDetails("ocorrencias", widget.id); 
    currentStatus = obj['status'];
    list.clear();
    for(var item in obj['anexos'].split(';')){
      if(item.toString().isNotEmpty){
        list.add(await fileFromImageUrl(item));
      }
    }
    setState(() {});
    changeLoading(false);
    if(obj == null){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  changeStatus(status) async{
    currentStatus = status;
    setState(() {});
  }

  saveResposta() async{   
    try{
      if(currentStatus != 'ciente' && currentStatus != 'solucionado'){
        displayMessage(context, getText('alert_ops'), 'Informe o status da ocorrência!');
        return;
      }
      var resposta = OcorrenciaRespostaModel(
        id: obj['id'], 
        descricao: txtResposta.text, 
        status: currentStatus,
        isResposta: true
      );
      changeLoading(true);
      var message = await apiSaveObject('ocorrencias', 'ocorrencia',resposta,  true);
      
      if(message == ""){
        Navigator.pop(context);
      }else{
        displayMessage(context, getText('alert_error'), message);
      }
    } catch(e){
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(  
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),           
            ),    
            child: Column(
              children: [
                NavigationDefault(title: getText('lb_ocorrencia')),
                Flexible(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20), 
                      height: MediaQuery.of(context).size.height - 110,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxMainRounded(),
                      child: SingleChildScrollView(                        
                        child: obj != null ?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [   
                              DividerDefault(title: getText('data_hora_criacao')),   
                              Row(
                                children: [                                  
                                  Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                                  SizedBox(width: 5),                                 
                                  LabelDefault(title:obj['created_at'], color: Colors.black, size: 15,),   
                                ],
                              ),      
                              SizedBox(height: 10),     
                              DividerDefault(title: getText('ocorrencia_sobre')),     
                              Row(
                                children: [
                                  LabelTitle(title: "${getText('lb_tipo')}: ", size: 15),  
                                  LabelDefault(title: obj['tipo'], size: 15, color: obj['tipo'] == 'Urgente' ? Colors.red : Theme.of(context).hintColor),                          
                                ],
                              ), 
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  LabelTitle(title: "Status: ", size: 15),  
                                  LabelDefault(title: obj['status'] ?? '', size: 15, color: Colors.black),                          
                                ],
                              ),  
                              SizedBox(height: 10), 
                              DividerDefault(title: getText('lb_descricao')),    
                              // LabelTitle(title: getText('lb_descricao'), size: 15),  
                              SizedBox(height: 5),        
                              LabelDefault(title: obj != null ? obj['descricao'] : '', color: Colors.black, maxLines: 99999, size: 16,),

                              // SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  for(var i=0; i<list.length; i++)
                                    InkWell(
                                      onTap: () {                                        
                                        openFile(list[i].path);
                                      },
                                      child: 
                                        list[i].path.contains('.jpg') || list[i].path.contains('.png') || list[i].path.contains('.jpeg')
                                        ? Image(image: Image.file(list[i]).image, width: 80, height:80)
                                        : Icon(MdiIcons.filePdfBox, color: Theme.of(context).primaryColor, size: 80)                              
                                      ,
                                    ),
                                ],
                              ),
                              if(obj['resposta'].toString().isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(color: Theme.of(context).primaryColor),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [                                  
                                      Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                                      SizedBox(width: 5),
                                      LabelTitle(title: "${getText('ocorrencia_respondido')}: ", size: 15),
                                      LabelDefault(title: obj['resposta_at'], size: 14),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  LabelTitle(title: getText('lb_resposta'), size: 15),  
                                  SizedBox(height: 10),        
                                  Text(obj != null ? obj['resposta'] : ''), 
                                ],
                              ),
                              if((getUserType() == 'sindico' || getUserPermission("ocorrencias") == 1) && obj['status'] == 'Pendente')
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 40),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        LabelTitle(title: getText('lb_resposta')),
                                      ],
                                    ),
                                    TextFieldDefault(title: "", controller: txtResposta, placeholder: getText('ocorrencia_resposta'),),
                                    SizedBox(height: 20),
                                    LabelDefault(title: getText('ocorrencia_status')),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap:(){
                                            changeStatus('ciente');
                                          },
                                          child: checkbox_filled(title: getText('ciente'), isChecked: currentStatus=='ciente')
                                        ),
                                        SizedBox(width: 5),                                  
                                        InkWell(
                                          onTap:(){
                                            changeStatus('solucionado');
                                          },
                                          child: checkbox_filled(title: getText('solucionado'), isChecked: currentStatus=='solucionado'),
                                        ) 
                                      ],
                                    ),
                                    SizedBox(height: 30),            
                                    DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                                      onPressed: () {
                                        saveResposta();
                                      }
                                    )
                                  ],
                                )
                            ],
                          )
                        : Text('')
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
      ),
      floatingActionButton: (getUserType() == 'morador') && obj != null && obj['status'] == 'Pendente' ?
        FloatButton(
          isEdit: true,
          onPressed: () { 
          Navigator.push(context,MaterialPageRoute(builder: (context) => NewOcorrencia(isEdit: true, myId: widget.id)),).then((_) {
            load();
          });
        },)
        : null
    );
  }
}

class OcorrenciaRespostaModel{
  int? id;
  String? descricao;
  String? status;
  bool? isResposta;

  OcorrenciaRespostaModel({
    this.id,
    this.descricao,
    this.status,
    this.isResposta
  });

  Map toJson() => {
    'id': id,
    'descricao': descricao,
    'status': status,
    'isResposta': isResposta
  };

}
