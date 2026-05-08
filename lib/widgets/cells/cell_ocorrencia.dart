import 'package:click/controllers/controller_generic.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CellOcorrencia extends StatefulWidget {
  final bool? hasArrow;
  final item;  

  const CellOcorrencia({
    Key? key,
    required this.item, 
    this.hasArrow,
  }) : super(key: key);

@override
  _CellOcorrenciaState createState() => _CellOcorrenciaState();
}

class _CellOcorrenciaState extends State<CellOcorrencia> {
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
      var res = await apiUpdateStatusOcorrManut("ocorrencias", widget.item['id'], status);
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
          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: Row(
            children: [
              Container(
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(4.0),
                   child: Container(
                     height: widget.item['resposta'].toString().isNotEmpty ? 160 : 100,
                     width: 5,
                     color: widget.item['status'] == 'pendente' ? Colors.yellow : Theme.of(context).primaryColor,
                   ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                        SizedBox(width: 5),
                        LabelDefault(title: widget.item['resposta_at'] ?? widget.item['created_at'], size: 14),
                      ],
                    ),  
                    if(widget.item['login'] != null && widget.item['login'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            LabelDefault(title:widget.item['login'] ?? "", size: 14),
                          ],
                        ),
                      ), 
                    SizedBox(height: 10),
                    LabelDefault(title: ""+widget.item['descricao']+"", color: Theme.of(context).hintColor, size: 16, maxLines: 1, limitChars: 100,),
                    SizedBox(height: 10),
                    if(widget.item['resposta'].toString().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabelDefault(title: "R:", color: Theme.of(context).hintColor, size: 16, weight: FontWeight.bold),
                          SizedBox(height: 10),
                          LabelDefault(title: ""+widget.item['resposta']+"", color: Theme.of(context).hintColor, size: 16, maxLines: 1, limitChars: 100,),
                          SizedBox(height: 10),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        LabelTitle(title: widget.item['status'], size: 15, color: widget.item['status'] == 'pendente' ? Theme.of(context).hintColor : Theme.of(context).primaryColor),  
                        LabelTitle(title: widget.item['tipo'], size: 15, color: widget.item['tipo'] == 'Urgente' ? Colors.red : Theme.of(context).hintColor),                          
                        if(widget.item['anexos'].toString().isNotEmpty)
                          Icon(Icons.download, size: 24, color: Theme.of(context).hintColor,)
                        else
                          SizedBox(width: 24,)
                      ],
                    ),  
                    SizedBox(height: 10),                                      
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
