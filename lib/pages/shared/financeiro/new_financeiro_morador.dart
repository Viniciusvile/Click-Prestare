
import 'package:click/controllers/controller_generic.dart';
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
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';

class NewFinanceiroMorador extends StatefulWidget {
  const NewFinanceiroMorador({Key? key, required this.apto, this.id}) : super(key: key);
  final dynamic apto;
  final int? id;

  @override
  _NewFinanceiroMoradorPageState createState() => _NewFinanceiroMoradorPageState();
}

class _NewFinanceiroMoradorPageState extends State<NewFinanceiroMorador> {
  
  var id = -1;
  var _isLoading = false;
  final txtBloco = TextEditingController();
  final txtApto = TextEditingController();
  final txtReferencia = TextEditingController();
  final txtVencimento = TextEditingController();
  final txtPagamento = TextEditingController();  
  final txtValor = TextEditingController();
  final txtConta = TextEditingController();
  final txtDescricao = TextEditingController();

  @override
  void initState(){
    super.initState();
    if(widget.apto != null) {  
      var pago = widget.apto["pago"] ?? 1;
      id = widget.apto["financeiro_id"] ?? -1;
      txtBloco.text = widget.apto['bloco'];
      txtApto.text = widget.apto['apto'];
      txtReferencia.text = "${widget.apto['mes'].toString()}/${widget.apto['ano'].toString()}";
      txtVencimento.text = widget.apto['data_vencimento'] ?? '';
      txtPagamento.text = pago == 1 ? widget.apto['data'] ?? '' : '';
      txtValor.text = widget.apto['valor'].toString();
      txtDescricao.text = widget.apto['descricao'] ?? '';
      txtConta.text = widget.apto['conta'] ?? '';
    } else if(widget.id != null){
      load();
    }
  }

  load() async {
    try{
    changeLoading(true);
      var obj = await apiGetDetails('financeiro', widget.id!);     
      var nome = obj['nome'].toString().split("-")[0];
      var apto = nome.split(getText('lb_bloco'))[0].split('Apto')[1].trim();
      var pago = obj["pago"] ?? 1;
      txtBloco.text = nome.toString().split('Bloco')[1].trim();
      txtApto.text = apto;
      txtReferencia.text = obj['nome'].toString().split("Ref.")[1].trim();
      txtVencimento.text = obj['data_vencimento'] ?? '';
      txtPagamento.text = pago == 1 ? obj['data'] ?? '' : '';
      txtValor.text = obj['valor'].toString();
      txtDescricao.text = obj['descricao'].toString();
      txtConta.text = obj['conta'].toString();
      id = obj['id'];
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }finally{
       changeLoading(false);
    }    
  }

  save() async{
    try{
      changeLoading(true);
      
      var dt_pag = txtPagamento.text.isNotEmpty ? convertStringToDate(txtPagamento.text)
                                                : null;

      var obj = FinanceiroModel(
        id: id, 
        nome: "Apto ${txtApto.text} Bloco ${txtBloco.text} - Ref. ${txtReferencia.text}", 
        tipo: 'C',
        categoria: 'Arrecadação',
        data: dt_pag,
        data_vencimento: convertStringToDate(txtVencimento.text),
        conta: txtConta.text,
        descricao: txtDescricao.text,
        valor: double.parse(txtValor.text.replaceAll(',', '.'))
      );
      var res = await apiSaveObject("financeiro", "financeiro", obj, id != -1);
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
      var res = await apiDeleteObject('financeiro', id);
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
                NavigationDefault(title: getText('financeiro_lancamento')),
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
                          DividerDefault(title: getText('lb_infos_apto')),                                   
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: TextFieldDefault(title: getText('lb_bloco'), controller: txtBloco, enabled: false),
                                ),
                                SizedBox(width: 10),   
                                Flexible(
                                  child: TextFieldDefault(title: getText('lb_apartamento'), controller: txtApto, enabled: false),
                                ),
                              ],
                            ), 
                            SizedBox(height: 10), 
                            DividerDefault(title: getText('datas')),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: TextFieldDefault(title: getText('financeiro_mes_referencia'), controller:txtReferencia, mask: TextInputMask(mask: ['99/9999'],reverse: false), keyboard: TextInputType.number, placeholder: "mm/aaaa"),
                                ),
                                SizedBox(width: 10),   
                                Flexible(
                                  child: InkWell(
                                    onTap: (){
                                      showCupertinoModalPopup(context: context,
                                        builder: (BuildContext context){
                                          return ModalCupertino(
                                            onPressed: (text) { setState(() { txtVencimento.text = text; });  
                                          }, initialDate: DateTime.now(), minimumDate: DateTime.now().add(Duration(days: -700)), type: 'date',);
                                        }
                                      );
                                    },
                                    child: TextFieldDefault(title: getText('financeiro_data_vencimento'), controller: txtVencimento, placeholder: "dd/mm/aaaa", enabled: false,)
                                  ),
                                ),
                              ],
                            ), 
                            SizedBox(height: 10), 
                            InkWell(
                              onTap: (){
                                showCupertinoModalPopup(context: context,
                                  builder: (BuildContext context){
                                    return ModalCupertino(
                                      onPressed: (text) { setState(() { txtPagamento.text = text; });  
                                    }, initialDate: DateTime.now(), minimumDate: DateTime.now().add(Duration(days: -700)), type: 'date',);
                                  }
                                );
                              },
                              child: TextFieldDefault(title: getText('financeiro_dt_pag'), controller: txtPagamento, placeholder: "dd/mm/aaaa", enabled: false,)
                            ),
                            SizedBox(height: 10), 
                            DividerDefault(title: getText('financeiro_valores')),                          
                            TextFieldDefault(title: getText('financeiro_valor'), controller:txtValor, keyboard: TextInputType.number, mask: CurrencyTextInputFormatter.currency(decimalDigits: 2, symbol: '', locale: 'pt_BR')),         
                            SizedBox(height: 10), 
                            InkWell(
                              child: TextFieldDefault(title: "Conta bancária", controller:txtConta, enabled: false),
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
                            if(id != -1)
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


class FinanceiroModel{
  int? id;
  String? nome;
  String? tipo;
  String? data;
  String? data_vencimento;
  double? valor;
  String? categoria;
  String? conta;
  String? descricao;
  String? cliente;
  String? forma_pagamento;
  int? parcelas;
  String? photo;

  FinanceiroModel({
    this.id,
    this.nome,
    this.tipo,
    this.data,
    this.data_vencimento,
    this.valor,
    this.categoria,
    this.conta,
    this.descricao,
    this.cliente,
    this.forma_pagamento,
    this.parcelas,
    this.photo
  });

  Map toJson() => {
    'id': id,
    'nome': nome,
    'tipo': tipo,
    'data': data,
    'data_vencimento': data_vencimento,
    'valor': valor,
    'categoria': categoria,
    'conta': conta,
    'descricao': descricao,
    'cliente': cliente,
    'forma_pagamento': forma_pagamento,
    'parcelas': parcelas,
    'photo': photo
  };
}



                   
