
import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/bottom_sheet_aptos.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_agenda_reserva.dart';
import 'package:click/widgets/buttons/save_button.dart';
import 'package:click/widgets/checkbox/checkbox_default.dart';
import 'package:click/widgets/dividers/divider_default.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class NewReserva extends StatefulWidget {
  const NewReserva({Key? key, required this.obj, this.objEditReserva}) : super(key: key);
  final dynamic obj;
  final dynamic objEditReserva;

  @override
  _NewReservaPageState createState() => _NewReservaPageState();
}

class _NewReservaPageState extends State<NewReserva> {
  final txtData = TextEditingController();
  final txtBloco = TextEditingController();
  final txtApto = TextEditingController();
  var _isLoading = false;
  var list = [];
  var listBlocos = [];
  var acceptTerms = false;
  DateTime? selectedDay = null;
  dynamic selectedHour = " - ";

  @override
  void initState(){
    super.initState();           
    if(widget.objEditReserva != null) {
      load();
    }
    if(getUserType()=="morador" ){
      txtBloco.text = Singleton.instance.bloco;
      txtApto.text = Singleton.instance.apartamento;
    }else{
      loadListAptos();
    }
  }

  load() async{
    txtData.text = widget.objEditReserva['data'];
    txtApto.text = widget.objEditReserva['apto'];
    txtBloco.text = widget.objEditReserva['bloco'];
    selectedHour = widget.objEditReserva['horaDe']+" - "+widget.objEditReserva['horaAte'];
    acceptTerms = true;
    setState(() {});
  }

  save() async{
    if(!acceptTerms){
      displayMessage(context, getText('alert'), getText('area_social_erro_normas'));
      return;
    }
    try{
      changeLoading(true);
      
      var obj = AreaSocialReservaModel(
        id: -1, 
        id_area_social: widget.obj['id'],
        data: convertStringToDate(txtData.text),
        horaDe: selectedHour.toString().split(" - ")[0],
        horaAte: selectedHour.toString().split(" - ")[1],
        id_apartamento: getAptoId()
      );

      var res = await apiSaveObject("areas-sociais/agendamento", "agendamento", obj, widget.objEditReserva != null);

      changeLoading(false);
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
      var res = await apiDeleteObject('areas-sociais/agendamento', widget.objEditReserva['id']);
      changeLoading(false);
      if(res){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
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

  getAllDias(){
    var list = Map();
    widget.obj['horarios_livres'].forEach((k, v) {
      var date = convertStringToDateFormat(k);
      list[date] = 0;
    });
    return list;
  }

  getHorariosFromDia(){
    if(widget.objEditReserva != null){
      return [selectedHour];
    }
    try{
      if(txtData.text.isEmpty){ print('aa');return []; }     
      var list = [];
      for(var horario in widget.obj['horarios_livres'][txtData.text]){
        var string = horario["horarioDe"]+" - "+horario["horarioAte"];
        list.add(string);
      }      
      return list;
    }catch(e){
      return [];
    }                
  }

  getAptoId(){
    if(getUserType()=="morador"){
      return Singleton.instance.id_apartamento.toString();
    }
    for(var apto in list){
      if(apto['bloco'] == txtBloco.text && apto['apto'] == txtApto.text){
        return apto['id'].toString();
      }
    }
    return "";
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
                NavigationDefault(title: widget.objEditReserva != null ? getText('area_social_nav_edit_reserva') : getText('area_social_nav_reservar')),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DividerDefault(title: getText('lb_area_social').toUpperCase()),
                        Row(children: [
                          Icon(MdiIcons.mapMarker),
                          SizedBox(width: 10),
                          LabelDefault(title: widget.obj['nome'])
                        ],),
                        SizedBox(height: 10), 
                        Row(children: [
                          Icon(MdiIcons.accountGroup),
                          SizedBox(width: 10),
                          LabelDefault(title: widget.obj['capacidade'].toString() + " ${getText('pessoas')}")
                        ],),
                        SizedBox(height: 10),
                        DividerDefault(title: getText('lb_infos_apto')),
                        SizedBox(height: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: (){ 
                                    if(widget.objEditReserva != null){return;}
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
                                    if(widget.objEditReserva != null){return;}
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
                        SizedBox(height: 10),
                        DividerDefault(title: getText('dia_e_hora').toUpperCase()),
                        InkWell(
                          onTap: (){
                            if(widget.objEditReserva != null){return;}
                            showDialog(context: context,
                              builder: (BuildContext context){
                                return ModalAgendaReserva(
                                  allowedDays: getAllDias(),
                                  selected: selectedDay,
                                  onPressed: (selectedDate) { 
                                    selectedDay = selectedDate;
                                    txtData.text = convertDateFormatToString(selectedDate);
                                    setState(() { });
                                    Navigator.pop(context);
                                  },
                                );
                              }
                            );
                          },
                          child: TextFieldDefault(title: getText('dia'), controller: txtData, mask: TextInputMask(mask: ['99/99/9999'],reverse: false), placeholder: "dd/mm/aaaa", enabled: false)
                        ),
                        SizedBox(height: 10),                        
                        Wrap(
                          spacing: 10,
                          children: [
                            for(var horario in getHorariosFromDia())                                    
                              InkWell(
                                onTap: (){                                   
                                  setState(() { selectedHour = horario;}); 
                                },
                                child: Chip(label: LabelDefault(title: horario, size: 14, weight: FontWeight.w500, color: Colors.white), backgroundColor: selectedHour != null && selectedHour == horario ? Theme.of(context).primaryColor : Colors.grey.shade400)
                              ),
                          ],
                        ),  
                        SizedBox(height: 10),                       
                        checkbox_default(title: getText('lb_li_concordo'), notPress: widget.objEditReserva != null, isChecked: acceptTerms, onPressed: (value){ acceptTerms = value; },),                                     
                        if(widget.objEditReserva != null)
                          Column(
                            children: [
                              SizedBox(height: 70),
                              InkWell(
                                onTap: (){delete();},
                                child: Align(
                                  alignment: Alignment.center,
                                  child: LabelDefault(title: getText('btn_delete'), size: 18, color: Colors.red)
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  )
                ),
                if(widget.objEditReserva == null)
                  SaveButton(isEdit: false, 
                    onPressedDelete:  (){ delete(); } , 
                    onPressedSave:  (){ save(); } 
                  )
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


class AreaSocialReservaModel{
  int? id;
  int? id_area_social;
  String? data;
  String? horaDe;
  String? horaAte;
  String? id_apartamento;
  
  AreaSocialReservaModel({
    this.id,
    this.id_area_social,
    this.data,
    this.horaDe,
    this.horaAte,
    this.id_apartamento,
  });

  Map toJson() => {
    'id': id,
    'id_area_social': id_area_social,
    'data': data,
    'horaDe': horaDe,
    'horaAte': horaAte,
    'id_apartamento': id_apartamento,
  };
}



                   
