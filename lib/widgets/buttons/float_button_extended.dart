import 'package:click/pages/shared/financeiro/list_finan_moradores.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_despesa.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_receita.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FloatButtonExtended extends StatelessWidget {
  final VoidCallback onPressed;
  final bool? isEdit;

  const FloatButtonExtended({
    Key? key,
    required this.onPressed, 
    this.isEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDialOpen = ValueNotifier(false);

    return 
      SpeedDial(
        backgroundColor: Theme.of(context).primaryColor,
        animatedIcon: AnimatedIcons.menu_close,
        openCloseDial: isDialOpen,
        children: [         
          SpeedDialChild(
            child: Icon(MdiIcons.cashMinus, color: Colors.red.shade300),
            label: getText('financeiro_despesas'),
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => NewFinanceiroDespesa(id: -1)),).then((_) {
                onPressed();
              });
            },
          ),
          SpeedDialChild(
            child: Icon(MdiIcons.cashPlus, color: Colors.green.shade300),
            label: getText('financeiro_arrecadacoes'),
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => ListFinanceiroMoradores()),).then((_) {
                onPressed();
              });
            },
          ),
          SpeedDialChild(
            child: Icon(MdiIcons.cash, color: Colors.green.shade300),
            label: getText('financeiro_receita_outras'),
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => NewFinanceiroReceita(id: -1)),).then((_) {
                onPressed();
              });
            },
          )
        ],
      );
  }
}
