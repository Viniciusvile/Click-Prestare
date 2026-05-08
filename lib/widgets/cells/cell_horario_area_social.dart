import 'package:click/pages/shared/areas%20sociais/new_area_social.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CellHorarioAreaSocial extends StatelessWidget {
  final HorarioModel horario;
  final VoidCallback? onDelete;
  final VoidCallback? onChangeDe;
  final VoidCallback? onChangeAte;

  const CellHorarioAreaSocial({
    Key? key,
    required this.horario, 
    required this.onDelete,
    required this.onChangeDe,
    required this.onChangeAte
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [               
                Icon(MdiIcons.clockOutline, size: 26, color: Theme.of(context).hintColor,),
                InkWell(
                  onTap: onChangeDe,
                  child: Row(
                    children: [
                      LabelDefault(title: "De: ", color: Theme.of(context).hintColor, size: 18, weight: FontWeight.w600, maxLines: 1,),
                      LabelDefault(title: horario.horarioDe, color: Theme.of(context).hintColor, size: 16, maxLines: 1,),
                      Icon(MdiIcons.chevronDown, size: 26, color: Theme.of(context).hintColor,),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onChangeAte,
                  child: Row(
                    children: [
                      LabelDefault(title: "Até: ", color: Theme.of(context).hintColor, size: 18, weight: FontWeight.w600, maxLines: 1,),
                      LabelDefault(title: horario.horarioAte, color: Theme.of(context).hintColor, size: 16, maxLines: 1,),
                      Icon(MdiIcons.chevronDown, size: 26, color: Theme.of(context).hintColor,),
                    ],
                  ),
                ), 
                InkWell(
                  onTap: onDelete,
                  child: Icon(MdiIcons.deleteOutline, size: 18, color: Colors.red)
                ),
              ],
            ),
        )
      ),
    );
  }
}
