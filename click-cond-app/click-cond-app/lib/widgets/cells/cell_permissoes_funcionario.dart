import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/checkbox/checkbox_multiple.dart';
import 'package:flutter/material.dart';

class CellPermissoesFuncionario extends StatelessWidget {
  final bool? hasArrow;
  final item;

  const CellPermissoesFuncionario({
    Key? key,
    required this.item, 
    this.hasArrow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [            
            checkbox_multiple(title: getText('visitante_prestador_servico'), isChecked: false)
          ],
        ),
      )
    );
  }
}
