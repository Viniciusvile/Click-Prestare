import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/checkbox/checkbox_filled.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class Cellmanutencao extends StatefulWidget {
  final bool? hasArrow;
  final item;

  const Cellmanutencao({
    Key? key,
    required this.item, 
    this.hasArrow,
  }) : super(key: key);

  @override
  _CellManutencaoState createState() => _CellManutencaoState();
}

class _CellManutencaoState extends State<Cellmanutencao> {

  var statusSelected = "";

  @override
  void initState(){
    super.initState();
    statusSelected = widget.item['status'];
  }

  changeStatus(status) async{
    try{
      statusSelected = status;
      setState(() {});
      var res = await apiUpdateStatusOcorrManut("manutencoes", widget.item['id'], status);
      if(res.toString().isEmpty){
        setState(() {});
      }else{
        displayMessage(context, getText('alert_error'), res.toString());
      }
    }catch(e){
      displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 190,
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 20, 10, 20),
          child: Row(
            children: [
              Container(
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(4.0),
                   child: Container(
                     height: 100,
                     width: 5,
                     color: Theme.of(context).primaryColor,
                   ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.house_outlined, size: 20, color: Theme.of(context).hintColor,),
                            SizedBox(width: 5),
                            LabelDefault(title: "${getText('lb_apto')} 701", size: 14),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                            SizedBox(width: 5),
                            LabelDefault(title: widget.item['created_at'], size: 14),
                          ],
                        )
                        
                      ],
                    ),
                    SizedBox(height: 10),
                    LabelDefault(title: widget.item['descricao'], color: Theme.of(context).hintColor, size: 16, maxLines: 50),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        for(var anexo in widget.item['anexos'].split(';')) 
                          Container(
                            padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
                            child: InkWell(
                              onTap: () { 
                                launchInBrowser(
                                  anexo,
                                  context,
                                );
                              },
                              child: Icon(Icons.download, size: 24, color: Theme.of(context).hintColor,)
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap:(){
                            changeStatus('ciente');
                          },
                          child: checkbox_filled(title: getText('lb_ciente'), isChecked: statusSelected=='ciente')
                        ),
                        SizedBox(width: 5),
                        InkWell(
                          onTap:(){
                            changeStatus('pendente');
                          },
                          child: checkbox_filled(title: getText('lb_pendente'), isChecked: statusSelected=='pendente'),
                        ),
                        SizedBox(width: 5),
                        InkWell(
                          onTap:(){
                            changeStatus('solucionado');
                          },
                          child: checkbox_filled(title: getText('lb_solucionado'), isChecked: statusSelected=='solucionado'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
