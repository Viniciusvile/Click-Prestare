
import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/checkbox/checkbox_default.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';

class NewFinanceiro extends StatefulWidget {
  const NewFinanceiro({Key? key, required this.isEdit, this.myId, this.obj}) : super(key: key);
  final bool isEdit;
  final int? myId;
  final dynamic obj;

  @override
  _NewFinanceiroPageState createState() => _NewFinanceiroPageState();
}

class _NewFinanceiroPageState extends State<NewFinanceiro> {
  
  var _isLoading = false;
  var tipo = 'D';
  final txtNome = TextEditingController();
  final txtData = TextEditingController();
  final txtValor = TextEditingController();
  final txtCategoria = TextEditingController();

  @override
  void initState(){
    super.initState();           
    if(widget.isEdit) {
      load();
    }
  }

  load() async{
    tipo = widget.obj['tipo'];
    txtNome.text = widget.obj['nome'];
    txtData.text = widget.obj['dia']+'/'+widget.obj['mes']+'/'+widget.obj['ano'];
    txtValor.text = widget.obj['valor'].toString().replaceAll('-', '');
    txtCategoria.text = widget.obj['categoria'];
    setState(() {});
  }

  save() async{
    // return;
    try{
      changeLoading(true);
      var obj = FinanceiroModel(
        id: widget.myId ?? -1, 
        nome: txtNome.text, 
        tipo: tipo,
        categoria: txtCategoria.text,
        data: convertStringToDate(txtData.text),
        valor: double.parse(txtValor.text.replaceAll(',', '.'))
      );
      var res = await apiSaveObject("financeiro", "financeiro", obj, widget.isEdit);
      changeLoading(false);
      if(res.toString().isEmpty){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), res.toString());
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  delete() async {
    var choice = await showConfirmDialog(context);
    if(choice != null && choice){
      changeLoading(true);
      var res = await apiDeleteObject('financeiro', widget.myId!);
      changeLoading(false);
      if(res){
        Navigator.of(context).pop(true);
      }else{
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  changeTipo(newTipo){
    tipo = newTipo;
    setState(() {});
  }

  changeLoading(bool value){
    _isLoading = value;
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {

    var _pageSize = MediaQuery.of(context).size.height;
     
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
                NavigationDefault(title: widget.isEdit ? getText('financeiro_nav_edit') : getText('financeiro_nav_new')),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: _pageSize >= 610 ? MediaQuery.of(context).size.height - 110 : 500,
                    decoration: BoxMainRounded(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              checkbox_default(title: getText('financeiro_receita'), isChecked: tipo=='C', onPressed: (value){changeTipo('C');}),
                              checkbox_default(title: getText('financeiro_despesa'), isChecked: tipo=='D', onPressed: (value){changeTipo('D');}),
                            ],
                          ),
                          SizedBox(height: 10),               
                          TextFieldDefault(title: getText('nome'), controller:txtNome),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('data'), controller:txtData, mask: TextInputMask(mask: ['99/99/9999'],reverse: false), keyboard: TextInputType.number, placeholder: "dd/mm/aaaa"),
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('financeiro_valor'), controller:txtValor, keyboard: TextInputType.number),         
                          SizedBox(height: 10), 
                          TextFieldDefault(title: getText('lb_categoria'), controller:txtCategoria),
                          SizedBox(height: 10), 
                          // if(tipo=='D')
                          //   TextFieldDefault(title: "Número de Parcelas"),
                          Expanded(child: Container()),                        
                          DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                            onPressed: () {
                              save();
                            }
                          ),   
                          if(widget.isEdit)
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap:(){ delete(); },
                                child: Align(
                                  alignment: Alignment.center,
                                  child: LabelDefault(title: getText("btn_delete"), size: 18, color: Colors.red)
                                ),
                              ),
                            ),
                      ],
                    ),
                  )
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


class FinanceiroModel{
  int? id;
  String? nome;
  String? tipo;
  String? data;
  double? valor;
  String? categoria;

  FinanceiroModel({
    this.id,
    this.nome,
    this.tipo,
    this.data,
    this.valor,
    this.categoria
  });

  Map toJson() => {
    'id': id,
    'nome': nome,
    'tipo': tipo,
    'data': data,
    'valor': valor,
    'categoria': categoria
  };
}



                   
