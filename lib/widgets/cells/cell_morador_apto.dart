import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellMoradorApto extends StatelessWidget {
  final item;

  const CellMoradorApto({
    Key? key,
    required this.item, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 190,
      child: Card(
        elevation: 0,
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: 
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(                      
                  radius: 20,
                  backgroundImage: NetworkImage(item['photo'])
                ),
                SizedBox(width: 15),
                LabelDefault(title: item['nome'], size: 14),
                // LabelDefault(title: "-", size: 14),
                // LabelDefault(title: '${item['data']} às ${item['hora']}', size: 14),
              ],
            )           
        )         
      ),
    );
  }
}
