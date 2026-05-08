import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellVisitante extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellVisitante({
    Key? key,
    required this.item, 
    this.hasArrow,
  }) : super(key: key);

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
                  children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.house_outlined, size: 20, color: Theme.of(context).hintColor,),
                          SizedBox(width: 5),
                          LabelDefault(title: item["apto"] ?? "", size: 14),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                          SizedBox(width: 5),
                          LabelDefault(title: item['data_hora'], size: 14),
                        ],
                      )
                      
                    ],
                  ),   
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      LabelDefault(title: "${getText('nome')}:", color: Colors.black, size: 16, weight: FontWeight.w600),
                      SizedBox(width: 5),
                      LabelDefault(title: item['nome'], color: Theme.of(context).hintColor, size: 16)
                    ],
                  ),
                  if(item['login'] != null && item['login'].toString().isNotEmpty)
                    Row(
                      children: <Widget>[
                        LabelDefault(title: "${getText('lb_autorizado_por')}:", color: Colors.black, size: 16, weight: FontWeight.w600),
                        SizedBox(width: 5),
                        LabelDefault(title: item['login'] ?? "", color: Theme.of(context).hintColor, size: 16)
                      ],
                    ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      LabelDefault(title: item['is_visitante'] == 1 ? getText('visitante').toUpperCase() : getText('prestador').toUpperCase(), color: Theme.of(context).hintColor, size: 18, weight: FontWeight.w600),
                    ],
                  ),
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
