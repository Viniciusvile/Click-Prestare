import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellComunicado extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellComunicado({
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
          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
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
                  SizedBox(width: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(
                        image: AssetImage('assets/icon/ic_comunicados.png'),
                        fit: BoxFit.cover,
                        height: 20,
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(Icons.watch_later_outlined, size: 20, color: Theme.of(context).hintColor,),
                          SizedBox(width: 5),
                          LabelDefault(title: item['created_at'], size: 14),
                        ],
                      ),
                    ],
                  ),   
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(child: Align(alignment: Alignment.centerLeft, child: LabelDefault(title: item['titulo'], color: Colors.black, size: 16, maxLines: 1))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                      children: <Widget>[
                        Expanded(child: LabelDefault(title: item['descricao'], size: 15, maxLines: 1,))
                      ],
                    ),
                  SizedBox(width: 5),
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
