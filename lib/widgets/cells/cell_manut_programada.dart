import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';

class CellManutProgramada extends StatelessWidget {
  final item;

  const CellManutProgramada({
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LabelDefault(title: item['descricao'], size: 14),
                LabelDefault(title: '${item["data_inicio"]} ${item["hora_inicio"]} - ${item["data_termino"]} ${item["hora_termino"]}', size: 13, maxLines: 2),
              ],
            )
        )
      ),
    );
  }
}
