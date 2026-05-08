
import 'package:click/controllers/controller_condominio.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/checkbox/checkbox_default.dart';
import 'package:click/widgets/dividers/divider_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AssinaturaSindico extends StatefulWidget {
  final dynamic condominio;
  const AssinaturaSindico({Key? key, required this.condominio,}) : super(key: key);

  @override
  _AssinaturaSindicoPageState createState() => _AssinaturaSindicoPageState();
}

class _AssinaturaSindicoPageState extends State<AssinaturaSindico> {
  final txtEmail = TextEditingController();
  var _isLoading = false;
  ProductDetails? selected;
  List<ProductDetails> products = [];
  String loginType = "";

  @override
  void initState() {
    super.initState();
    monitorSubscriptions();
    loadProducts();
  }

  changeLoading(bool value){
    _isLoading = value;
    setState(() {});
  }
  
  String getText1(){
    if(getUserType()=="sindico"){
      return getText('assinatura_cond_renove_agora');
    }
    return getText('assinatura_cond_contato_sindico');
  }

  int getDias(){
    if(widget.condominio["dias_restantes_condominio"] != null){
      return widget.condominio["dias_restantes_condominio"];
    }
    return 0;
  }

  String getDiasRestantes(){
    if(widget.condominio["dias_restantes_condominio"] != null){
      if(widget.condominio["dias_restantes_condominio"] < 0){
        return "0 ${getText('dias')}";
      }
      if(widget.condominio["dias_restantes_condominio"] == 1){
        return "1 ${getText('dia')}";
      }
      return "${widget.condominio["dias_restantes_condominio"].toString()} dias";
    }
    return "0 ${getText('dias')}";
  }

  buy() async {
    if(selected != null){
      save("codigoApple123", selected!.id);
    }    
    // try{
    //   final bool available = await InAppPurchase.instance.isAvailable();
    //   if (available) {        
    //     if(selected == null){
    //       throw(getText('assinatura_produto_nao_localizado'));
    //     } else {
    //       final PurchaseParam purchaseParam = PurchaseParam(productDetails: selected!);
    //       InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    //     }
    //   }
    // } catch(e) {
    //   displayMessage(context, getText('alert_error'), e.toString()); 
    // }
  }

  monitorSubscriptions() async {
    await InAppPurchase.instance.isAvailable();
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
    }, onError: (error) {
    });
  }

  loadProducts() async {   
    products = [
      ProductDetails(id: "click_mensal_condominio", title: "mensal", description: "", price: "R\$ 35,90", rawPrice: 35.90, currencyCode: "BRL"),
      ProductDetails(id: "click_semestral_condominio", title: "semestral", description: "", price: "R\$ 197,95", rawPrice: 197.95, currencyCode: "BRL"),
      ProductDetails(id: "click_anual_condominio", title: "anual", description: "", price: "R\$ 385,89", rawPrice: 385.89, currencyCode: "BRL"),
    ];

    // try{      
    //   final bool available = await InAppPurchase.instance.isAvailable();
    //   if (available) {
    //     ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails({'click_mensal_condominio','click_semestral_condominio','click_anual_condominio'});                                        
    //     products = response.productDetails;
    //   }
    //   changeSelected("mensal");
    //   setState(() {});
    // }catch(e){
    //   print(e);
    //   //do nothing
    // }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // displayMessage(context, 'Pendente', 'Sua compra está pendente');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          displayMessage(context, getText('alert_error'), purchaseDetails.error?.details?["NSLocalizedDescription"] ?? getText('assinatura_erro'));
        } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          save(purchaseDetails.purchaseID ?? '', purchaseDetails.productID);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }  

  save(String purchaseID, String planoId) async {
    try {
      changeLoading(true);
      await updateAsinaturaCondominioApi(widget.condominio["id"].toString(), planoId, purchaseID);
      await displayMessage(context, getText('alert_success'), getText('assinatura_renovada'));
      Navigator.pop(context, true);
    } catch(e) {
      await displayMessage(context, getText('alert_error'), e.toString());
    } finally {
      changeLoading(false);
    }
  }

  String getPrice(String tipo) {
    for(var prod in products){
      if(prod.title.toLowerCase().contains(tipo)){
        return prod.price;
      }
    }
    return "";
  }

  changeSelected(String plano){
    for(var prod in products){
      if(prod.title.toLowerCase().contains(plano)){
        selected = prod;
      }
    }
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
                NavigationDefault(title: getText('assinatura')),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 25), 
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Image(image: AssetImage("assets/images/img-assinatura.png"), width: 220)),
                          SizedBox(height: 20),
                          DividerDefault(title: getText('assinatura_condominio'), fontSize: 16, align: TextAlign.center, height: 39,), 
                          SizedBox(height: 10),
                          Row(
                            children: [
                              CircleAvatar(                      
                                  radius: 28,
                                  backgroundImage: NetworkImage( widget.condominio['photo'])
                                ),
                              SizedBox(width: 20),
                              Flexible(child: LabelDefault(title: widget.condominio["nome"], size: 18, weight: FontWeight.w500, maxLines: 4,))
                            ],
                          ),
                          SizedBox(height: 10),
                          // Row(
                          //   children: [
                          //     LabelDefault(title: getText('assinatura_tipo_renovacao'), weight: FontWeight.w500, size: 16, color: Colors.grey.shade600,),
                          //     LabelDefault(title: getText('assinatura_mensal'), size: 15, color: Colors.black,),
                          //   ],
                          // ),
                          // SizedBox(height: 10),
                          Row(
                            children: [
                              LabelDefault(title: getText('assinatura_validade'), weight: FontWeight.w500, size: 16, color: Colors.grey.shade600,),
                              LabelDefault(title: widget.condominio["vencimento_condominio"], size: 15, color: Colors.black,),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              LabelDefault(title: getText('assinatura_dias_restantes'), weight: FontWeight.w500, size: 16, color: Colors.grey.shade600,),
                              LabelDefault(title: getDiasRestantes(), size: 15, color: Colors.black,),
                            ],
                          ),
                          if(widget.condominio["dias_restantes_condominio"] <= 0)
                            Padding(
                              padding: const EdgeInsets.only(top:10),
                              child: Row(
                                children: [
                                  Icon(MdiIcons.alertCircle, color: Colors.red, size: 20,),
                                  SizedBox(width: 10),
                                  LabelDefault(title: getText('assinatura_venceu'), size: 17, color: Colors.red, weight: FontWeight.w500,),
                                ],
                              ),
                            ),
                          SizedBox(height: 20),  
                          if(getDias() <= 7)
                            Column(
                              children: [
                                LabelDefault(title: getText1(), size: 15, maxLines: 10,),
                                if(getUserType()=="sindico")
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: LabelDefault(title: getText('assinatura_renove_agora_obs'), size: 15, maxLines: 10,),
                                  ),
                                SizedBox(height: 10),   
                                if(getUserType()=="sindico")                             
                                  Column(
                                    children: [
                                      checkbox_default(title: "${getText('assinatura_mensal')}: ${getPrice("mensal")}", isChecked: selected?.title.toLowerCase().contains("mensal"), onPressed: (value){ changeSelected("mensal"); }),
                                      checkbox_default(title: "${getText('assinatura_semestral')}: ${getPrice("semestral")}", isChecked: selected?.title.toLowerCase().contains("semestral"), onPressed: (value){ changeSelected("semestral"); }),
                                      checkbox_default(title: "${getText('assinatura_anual')}: ${getPrice("anual")}", isChecked: selected?.title.toLowerCase().contains("anual"), onPressed: (value){ changeSelected("anual"); }),
                                      SizedBox(height: 10),   
                                      DefaultButton(title: getText('assinatura_btn_mensal_cond'), hasArrow: false,                   
                                        onPressed: () {
                                          buy();
                                        }
                                      ),
                                    ],
                                  ),
                                if(getUserType()=="sindico")
                                SizedBox(height: 20),
                                if(getUserType()=="sindico")
                                  InkWell(
                                    onTap:(){ 
                                      Navigator.pop(context);
                                    },
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: LabelDefault(title: getText('assinatura_renovar_depois'), size: 18, color: Colors.red)
                                    ),
                                  ),
                              ],
                            ),
                          if(getDias() > 7)
                            LabelDefault(title: getText('assinatura_renovar_7_dias'), size: 15, maxLines: 10,),                            
                        ],
                      ),
                    ),
                  )
                ),
              ],
            ), 
          ),
          if(_isLoading)
            const Loader(loadingTxt: '', opacity: 0.7, color: Colors.black, dismissibles: false)  
        ],
      )
    );
  }
}
