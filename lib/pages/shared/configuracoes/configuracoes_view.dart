import 'package:click/controllers/controller_condominio.dart';
import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/configuracoes/modal_new_password.dart';
import 'package:click/pages/shared/morador/assinatura_morador.dart';
import 'package:click/pages/sindico/assinatura_sindico.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/localstorage_config.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/modal_bottom_sheet_data.dart';
import 'package:click/widgets/alerts/sidemenu_list_bottom_sheet.dart';
import 'package:click/widgets/card/card_configuracoes.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';

class ConfiguracoesView extends StatefulWidget {
  final dynamic condominio;
  const ConfiguracoesView({Key? key, required this.condominio}) : super(key: key);

  @override
  _ListDocsPageState createState() => _ListDocsPageState();
}

class _ListDocsPageState extends State<ConfiguracoesView> {
  late List<dynamic> list = [];
  String appVersion = "";

  @override
  void initState(){
    super.initState();
    load();
  }

  load() async {
    appVersion = await getAppVersion();
    setState(() {});
  }

  deleteCondominio() async {
    var choice = await showConfirmDialog(context, text: getText('cond_confirm_delete'));
    if(choice != null && choice){
      var res = await apiDeleteObject('condominio', Singleton.instance.id_condominio);
      if(res){
        await displayMessage(context, getText('alert_success'), "Condomínio removido!");
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      }else{
        await displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  deleteMinhaConta() async {
    var choice = await showConfirmDialog(context, text: getText('signup_confirm_delete'));
    if(choice != null && choice){
      displayMessage(context, getText('label_exclusao'), getText('config_delete_account_sucesso'));;
    }
  }

  updateMoeda(String moeda) async {
    try{
      await updateMoedaCondominioApi(widget.condominio["id"].toString(), moeda);
      Singleton.instance.moeda = moeda;
      displayMessage(context, getText('alert_success'), getText('alert_dados_alterados'));
    }catch(e){
      //do nothing       
    }    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [               
              Container(
                width: MediaQuery.of(context).size.width,
                height: 220,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/bg_configs.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    NavigationDefault(title: getText('config_nav'), bgDecoration: BoxDecoration(),),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              widget.condominio["photo"], 
                              width: MediaQuery.of(context).size.width*0.22, 
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          ),
                          SizedBox(width: 20),
                          Flexible(child: LabelDefault(title: widget.condominio["nome"], color: Colors.white, size: 20, weight: FontWeight.w500, maxLines: 2,))
                        ],
                      ),
                    ),
                  ],
                )
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 10, 20), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[  
                    InkWell(
                      onTap: (){launchInBrowser("https://click-app.co/termos-de-uso.html", context);},
                      child: CardConfiguracoes(title: getText('config_termos_uso'),)
                    ),
                    InkWell(
                      onTap: (){launchInBrowser("https://click-app.co/politica-de-privacidade.html", context);},
                      child: CardConfiguracoes(title: getText('config_politica_privacidade'),)
                    ),
                    InkWell(
                      onTap: (){
                        displayMessage(context, getText('config_fale_conosco'), getText('config_fale_conosco_descricao'));
                      },
                      child: CardConfiguracoes(title: getText('config_fale_conosco'))
                    ),
                    InkWell(
                      onTap: () async {
                        var listLanguages = [
                          SidemenuListBottomSheetData(title: getText('language_pt_br'), isChecked: LocalStorageConfig.instance.getPreferenceLanguage()=="pt_BR", onPressed: (){ LocalStorageConfig.instance.savePreferenceLanguage("pt_BR");}),
                          SidemenuListBottomSheetData(title: getText('language_en'), isChecked: LocalStorageConfig.instance.getPreferenceLanguage()=="en", onPressed: (){ LocalStorageConfig.instance.savePreferenceLanguage('en'); }),
                          SidemenuListBottomSheetData(title: getText('language_es'), isChecked: LocalStorageConfig.instance.getPreferenceLanguage()=="es", onPressed: (){ LocalStorageConfig.instance.savePreferenceLanguage('es'); }),
                          SidemenuListBottomSheetData(title: getText('language_pt_pt'), isChecked: LocalStorageConfig.instance.getPreferenceLanguage()=="pt_PT", onPressed: (){ LocalStorageConfig.instance.savePreferenceLanguage('pt_PT');}),
                          SidemenuListBottomSheetData(title: getText('language_al'), isChecked: LocalStorageConfig.instance.getPreferenceLanguage()=="de", onPressed: (){ LocalStorageConfig.instance.savePreferenceLanguage('de'); }),
                        ];
                        await openSideMenuBottomSheet(context, listLanguages, true);
                        setState(() {});
                      },
                      child: CardConfiguracoes(title: getText('language_idioma'))
                    ),
                    if(getUserType() == 'sindico')
                      InkWell(
                        onTap: () async{
                          var listLanguages = [
                            SidemenuListBottomSheetData(title: getText('moeda_real'), isChecked: Singleton.instance.checkCurrentMoeda("R\$"), onPressed: (){ updateMoeda("R\$"); }),
                            SidemenuListBottomSheetData(title: getText('moeda_dolar_americano'), isChecked: Singleton.instance.checkCurrentMoeda("US\$"), onPressed: (){ updateMoeda("US\$");  }),                            
                            SidemenuListBottomSheetData(title: getText('moeda_euro'), isChecked: Singleton.instance.checkCurrentMoeda("€"), onPressed: (){ updateMoeda("€"); }),
                            SidemenuListBottomSheetData(title: getText('moeda_libra'), isChecked: Singleton.instance.checkCurrentMoeda("£"), onPressed: (){ updateMoeda("£"); }),
                            SidemenuListBottomSheetData(title: getText('moeda_peso_mexicano'), isChecked: Singleton.instance.checkCurrentMoeda("Mex\$"), onPressed: (){ updateMoeda("Mex\$"); }),
                            SidemenuListBottomSheetData(title: getText('moeda_generico'), isChecked: Singleton.instance.checkCurrentMoeda("\$"), onPressed: (){ updateMoeda("\$"); }),
                          ];
                          await openSideMenuBottomSheet(context, listLanguages, true);
                          setState(() {});
                        },
                        child: CardConfiguracoes(title: getText('moeda'))
                      ),
                    if(getUserType() != 'funcionario')
                      InkWell(
                        onTap: (){
                          if(getUserType() == "sindico"){
                            Navigator.push(context,MaterialPageRoute(builder: (context) => AssinaturaSindico(condominio: widget.condominio,),));
                          }
                          if(getUserType() == "morador"){
                            Navigator.push(context,MaterialPageRoute(builder: (context) => AssinaturaMorador(condominio: widget.condominio,),));
                          }                          
                        },
                        child: CardConfiguracoes(title: getText('assinatura'))
                      ),
                      InkWell(
                        onTap: (){
                          showDialog(context: context,
                              builder: (BuildContext context){
                                return const ModalNewPassword();
                              }
                            );                      
                        },
                        child: CardConfiguracoes(title: getText('config_alt_senha'))
                      ),
                      if(getUserType() == 'sindico')
                        InkWell(
                          onTap: (){
                            deleteCondominio();
                          },
                          child: CardConfiguracoes(title: getText('config_delete_cond'))
                        ),
                      if(getUserType() != 'funcionario')
                        InkWell(
                          onTap: (){
                            deleteMinhaConta();                 
                          },
                          child: CardConfiguracoes(title: getText('config_delete_account'))
                        ),
                  ]
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LabelDefault(title: "${getText('vesaoApp')} "+appVersion, color: Colors.grey, size: 13,),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: InkWell(
                  onTap: (){
                    storageLogout();
                    Navigator.of(context).pushNamed('/');
                  },
                  child: LabelDefault(title: getText('lb_logout'), color: Colors.red, size: 18,)
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
