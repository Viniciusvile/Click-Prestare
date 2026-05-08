import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellAgenda extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellAgenda({
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
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                      SizedBox(width: 5),
                      LabelDefault(title: item['data_inicio']+' às '+item['hora_inicio'], size: 14),
                    ],
                  ),   
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(child: Align(alignment: Alignment.centerLeft, child: LabelDefault(title: item['titulo'], color: Colors.black, size: 16))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                      children: <Widget>[
                        Expanded(child: LabelDefault(title: item['descricao'], size: 15, maxLines: 5,))
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
