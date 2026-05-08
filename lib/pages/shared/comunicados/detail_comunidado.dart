import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:flutter/widgets.dart';
import '../../../widgets/dividers/divider_default.dart';
import '../../../widgets/label/label_default.dart';
import 'new_Comunicado.dart';

class DetailComunicado extends StatefulWidget {
  const DetailComunicado({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _DetailComunicadoPageState createState() => _DetailComunicadoPageState();
}

class _DetailComunicadoPageState extends State<DetailComunicado> {
  var _isLoading = false;
  late dynamic obj = null;

  @override
  void initState(){
      super.initState();
      load();
  }

  load() async{
    try{
     _isLoading = true;
      setState(() {});
      obj = await apiGetDetails('comunicados', widget.id);
      _isLoading = false;
      setState(() {});
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
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
                NavigationDefault(title: getText('lb_comunicado')),
                Flexible(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20), 
                      height: MediaQuery.of(context).size.height - 110,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxMainRounded(),
                      child: SingleChildScrollView(
                        child: obj != null ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [                            
                            DividerDefault(title: getText('lb_titulo')),   
                            LabelDefault(title: obj['titulo'], color: Colors.grey.shade800, weight: FontWeight.w500,),
                            SizedBox(height: 10),
                            DividerDefault(title: getText('data_hora_criacao')),                               
                            Row(
                              children: [                                  
                                Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                                SizedBox(width: 5),
                                LabelDefault(title: obj['created_at'], color: Colors.black, size: 15,),   
                              ],
                            ),
                            SizedBox(height: 15), 
                            DividerDefault(title: getText('lb_descricao')),   
                            LabelDefault(title: obj['descricao'], size: 16, color: Colors.black, maxLines: 9999),
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
            
      floatingActionButton: (getUserType() == 'sindico') || getUserPermission('comunicados') == 1 ?
        FloatButton(
          onPressed: () { 
            Navigator.push(context,MaterialPageRoute(builder: (context) => NewComunicado(isEdit: true, myId: widget.id,)),).then((_) {
              load();
            });
          },
          isEdit: true,
        )
        : null
    );
  }
}
