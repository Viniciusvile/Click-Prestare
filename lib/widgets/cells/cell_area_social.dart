import 'package:click/widgets/label/label_title.dart';
import 'package:flutter/material.dart';

class CellAreaSocial extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellAreaSocial({
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
                     height: 150,
                     width: 5,
                     color: Theme.of(context).primaryColor,
                   ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        item["imagem"], 
                        width: MediaQuery.of(context).size.width, 
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    ),
                    SizedBox(height: 10),
                    LabelTitle(title: item["nome"], size: 16),
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
