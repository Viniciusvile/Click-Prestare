
import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_morador.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/bottom_sheet_conta.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/alerts/modal_cupertino.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/dividers/divider_default.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';

class NewFinanceiroReceita extends StatefulWidget {
  final int id;
  const NewFinanceiroReceita({Key? key, required this.id}) : super(key: key);

  @override
  _NewFinanceiroReceitaPageState createState() => _NewFinanceiroReceitaPageState();
}

class _NewFinanceiroReceitaPageState extends State<NewFinanceiroReceita> {
  
  var _isLoading = false;
  final txtTipo = TextEditingController();
  final txtCliente = TextEditingController();
  final txtRecebimento = TextEditingController();  
  final txtValor = TextEditingController();
  final txtConta = TextEditingController();
  final txtDescricao = TextEditingController();

  @override
  void initState(){
    super.initState();    
    if(widget.id != -1){
      load();
    }       
  }

  load() async {
     try{
      changeLoading(true);
      var obj = await apiGetDetails('financeiro', widget.id);     
      txtTipo.text = obj['nome'] ?? '';
      txtCliente.text = obj['cliente'] ?? '';
      txtRecebimento.text =  obj['data'] ?? '';     
      txtValor.text = obj['valor'].toString();
      txtDescricao.text = obj['descricao'];
      txtConta.text = obj['conta'];
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
       changeLoading(false);
    }    
  }

  save() async{
    try{
      changeLoading(true);
      var obj = FinanceiroModel(
        id: widget.id, 
        nome: txtTipo.text, 
        tipo: 'C',
        categoria: "Receita",
        data: convertStringToDate(txtRecebimento.text),
        conta: txtConta.text,
        descricao: txtDescricao.text,
        valor: double.parse(txtValor.text.replaceAll('.', '').replaceAll(',', '.')),
        cliente: txtCliente.text
      );
      var res = await apiSaveObject("financeiro", "financeiro", obj, widget.id != -1);
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
      var res = await apiDeleteObject('financeiro', widget.id);
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
                NavigationDefault(title: getText('financeiro_receita')),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: _pageSize >= 610 ? MediaQuery.of(context).size.height - 110 : 500,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [                
                            DividerDefault(title: getText('financeiro_pagador').toUpperCase()),   
                            TextFieldDefault(title: getText('financeiro_tipo'), controller: txtTipo, keyboard: TextInputType.multiline),
                            SizedBox(height: 10), 
                            TextFieldDefault(title: getText('financeiro_forn_cliente'), controller: txtCliente, keyboard: TextInputType.multiline),
                            SizedBox(height: 10), 
                            DividerDefault(title: getText('data')),                            
                            InkWell(
                              onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtRecebimento.text = text; });  
                                    }, initialDate: DateTime.now(), minimumDate: DateTime.now().add(Duration(days: -700)), type: 'date',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('financeiro_data_recebimento'), controller: txtRecebimento, placeholder: "dd/mm/aaaa", enabled: false,)
                            ),
                            SizedBox(height: 10), 
                            DividerDefault(title: getText('financeiro_valores')),                          
                            TextFieldDefault(title: getText('financeiro_valor'), controller:txtValor, keyboard: TextInputType.number, mask: CurrencyTextInputFormatter.currency(decimalDigits: 2, symbol: '', locale: 'pt_BR')),         
                            SizedBox(height: 10), 
                            InkWell(
                              child: TextFieldDefault(title: getText('financeiro_conta_bancaria'), controller:txtConta, enabled: false),
                              onTap: (){
                                bottomSheetConta(context, (contaSelected){
                                  txtConta.text = contaSelected;
                                  Navigator.of(context).pop();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                });
                              },
                            ),
                            SizedBox(height: 10), 
                            DividerDefault(title: getText('lb_descricao_opcional')),
                            TextFieldDefault(title: getText('lb_descricao'), controller: txtDescricao, keyboard: TextInputType.multiline),
                            SizedBox(height: 30), 
                            // if(tipo=='D')
                            //   TextFieldDefault(title: "Número de Parcelas"),
                            // Expanded(child: Container()),                                                  
                            DefaultButton(title: getText('btn_save'), hasArrow: false,                   
                              onPressed: () {
                                save();
                              }
                            ),   
                            if(widget.id != -1)
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




                   
